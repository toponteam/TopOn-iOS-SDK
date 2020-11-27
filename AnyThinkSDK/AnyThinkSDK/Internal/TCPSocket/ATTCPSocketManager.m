//
//  ATTCPSocketManager.m
//  AnyThinkSDK
//
//  Created by Topon on 7/3/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATTCPSocketManager.h"
#import "ATGCDAsyncSocket.h"
#import "ATAppSettingManager.h"
#import "ATLogger.h"
#import "Utilities.h"

@interface ATTCPSocketManager ()
@property (nonatomic, strong) ATTCPClientSocket *clientSocket;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic,assign)  NSInteger sendConnentTimes;
@end

@implementation ATTCPSocketManager

#pragma mark - init
+(instancetype)sharedManager {
    static ATTCPSocketManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATTCPSocketManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _clientSocket = [[ATTCPClientSocket alloc] initWithHost:[ATAppSettingManager sharedManager].trackingSetting.trackerTCPAddress onPort:[ATAppSettingManager sharedManager].trackingSetting.trackerTCPPort];
        _queue = dispatch_queue_create("com.anythink.TCPClientSocket", DISPATCH_QUEUE_SERIAL);
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)sendData:(NSData *)data completionHandler:(void (^)(NSError * _Nullable))handler {
    if (data.length == 0) {
        NSError *error = [NSError errorWithDomain:@"TCPSocket sendData is nil" code:-1 userInfo:nil];
        if (handler) {
            handler(error);
        }
        return;
    }
    
    ATTCPSocketManager *mg = [ATTCPSocketManager sharedManager];
    dispatch_async(mg.queue, ^{
        dispatch_semaphore_wait(mg.semaphore, DISPATCH_TIME_FOREVER);
        
        BOOL connected = [mg.clientSocket isConnected];
        if (connected) {
            [mg.clientSocket sendData:data completionHandler:^(NSError * _Nullable error) {
                if (handler) {
                    handler(error);
                    if (error) {
                        [ATLogger logMessage:[NSString stringWithFormat:@"Tcp sendData error:%@",error.description] type:ATLogTypeInternal];
                    }else {
                        [ATLogger logMessage:@"TCPSocket sendData success" type:ATLogTypeInternal];
                    }
                }
                [mg.clientSocket removeSendDataCompletion];
                dispatch_semaphore_signal(mg.semaphore);
            }];
        }else {
            [mg.clientSocket connectCompletion:^(NSError * _Nullable error) {
                if (error) {
                    if (handler) {
                        handler(error);
                    }
                    dispatch_semaphore_signal(mg.semaphore);
                }else{
                    [mg.clientSocket sendData:data completionHandler:^(NSError * _Nullable error) {
                        if (handler) {
                            handler(error);
                            if (error) {
                                [ATLogger logMessage:[NSString stringWithFormat:@"TCPSocket sendData error:%@",error.description] type:ATLogTypeInternal];
                            }else {
                                [ATLogger logMessage:@"TCPSocket sendData success" type:ATLogTypeInternal];
                            }
                        }
                        [mg.clientSocket removeSendDataCompletion];
                        dispatch_semaphore_signal(mg.semaphore);
                    }];
                }
            }];
        }
    });
}
@end

@interface ATTCPClientSocket ()<ATGCDAsyncSocketDelegate>
@property (nonatomic, strong) ATGCDAsyncSocket *clientSocket;
@property (nonatomic, copy)  NSString *host;
@property (nonatomic, assign)  uint16_t port;
@property (nonatomic, assign)  NSInteger retryConnentTimes;
@property (nonatomic, copy) void (^connectCompletion)(NSError *);
@property (nonatomic, copy) void (^sendDataCompletion)(NSError *);
@end

const int ATWriteTimeout = 30;

@implementation ATTCPClientSocket

-(instancetype)initWithHost:(NSString *)host onPort:(uint16_t)port{
    ATTCPClientSocket *clientSocket = [[ATTCPClientSocket alloc] init];
    clientSocket.host = host;
    clientSocket.port = port;
    clientSocket.clientSocket = [[ATGCDAsyncSocket alloc] initWithDelegate:clientSocket delegateQueue:dispatch_get_main_queue()];
    return clientSocket;
}

-(void)connectCompletion:(void (^)(NSError * _Nullable))completion {
    [self.clientSocket setIPv4PreferredOverIPv6:NO];
    self.connectCompletion = completion;
    
    NSError *error = nil;
    BOOL result = [self.clientSocket connectToHost:self.host onPort:self.port error:&error];
    /*
    connectToHost:这个方法会返回一个bool  但是每次都返回yes   原因是这个方法yes  与no  表示 是否尝试着去链接host  并不代表是否链接成功
    */
    if (result) {
        [ATLogger logMessage:@"TCPSocket is Connecting" type:ATLogTypeInternal];
    }else{
        [ATLogger logMessage:[NSString stringWithFormat:@"TCPSocket Connect fail，error:%@",error] type:ATLogTypeInternal];
    }
}

-(BOOL)isConnected{
    return self.clientSocket.isConnected;
}

-(void)disconnect{
    [self.clientSocket disconnect];
}

-(void)removeSendDataCompletion {
    self.sendDataCompletion = nil;
}

- (void)sendData:(NSData *)data completionHandler:(void (^)(NSError * _Nullable))handler {
    if (data.length == 0) {
        NSError *error = [NSError errorWithDomain:@"TCPSocket sendData is nil" code:-1 userInfo:nil];
        if (handler) {
            handler(error);
        }
        return;
    }
    self.sendDataCompletion = handler;
    [self writeDataToServer:data];
}

- (void)writeDataToServer:(NSData *)data{
    NSInteger tag = (NSInteger)data.length;
    [self.clientSocket writeData:data withTimeout:ATWriteTimeout tag:tag];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(writeDataToServerFail) withObject:nil afterDelay:ATWriteTimeout];
}

- (void)writeDataToServerFail {
    if (self.sendDataCompletion) {
        NSError *error = [NSError errorWithDomain:@"TCPSocket send data writing timeouts" code:-1 userInfo:nil];
        self.sendDataCompletion(error);
        [self removeSendDataCompletion];
    }
}

#pragma mark -GCDAsyncSocketDelegate
//connect success
- (void)socket:(ATGCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [ATLogger logMessage:[NSString stringWithFormat:@"TCPSocket Connect success::socket::didConnectToHost:%@ port:%hu",host,port] type:ATLogTypeInternal];
    if (self.connectCompletion) {
        self.connectCompletion(nil);
        self.connectCompletion = nil;
    }
}

//disconnect
- (void)socketDidDisconnect:(ATGCDAsyncSocket *)sock withError:(nullable NSError *)err{
    [ATLogger logMessage:[NSString stringWithFormat:@"TCPSocket socketDidDisconnect::error：%@",err] type:ATLogTypeInternal];
    if (self.connectCompletion) {
        self.connectCompletion(err);
        self.connectCompletion = nil;
    }
}

- (void)socket:(ATGCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [ATLogger logMessage:@"TCPSocket socket::didWriteDataWithTag" type:ATLogTypeInternal];
    [self.clientSocket readDataWithTimeout:ATWriteTimeout tag:1];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
**/
- (void)socket:(ATGCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [ATLogger logMessage:@"TCPSocket socket::didReadData:" type:ATLogTypeInternal];
    // cancel
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSUInteger len = [data length];
   if (len < 1) {
       [ATLogger logMessage:@"TCPSocket socket::didReadData length too short" type:ATLogTypeInternal];
       [sock readDataWithTimeout:ATWriteTimeout tag:0];
       return;
   }
    Byte *byteVaule = (Byte*)malloc(len);
    memcpy(byteVaule, [data bytes], len);
    if (byteVaule[0] == 0x01) {
        if (self.sendDataCompletion) {
            self.sendDataCompletion(nil);
        }
    }else {
        if (self.sendDataCompletion) {
            NSError *error = [NSError errorWithDomain:@"TCPSocket write Data To Server Fail" code:-1 userInfo:nil];
            self.sendDataCompletion(error);
        }
    }
    free(byteVaule);
}


@end
