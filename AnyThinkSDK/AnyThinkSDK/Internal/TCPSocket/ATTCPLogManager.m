//
//  ATTCPLogManager.m
//  AnyThinkSDK
//
//  Created by Topon on 7/7/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATTCPLogManager.h"
#import "ATTCPSocketManager.h"
#import "ATNetworkingManager.h"
#import "ATAppSettingManager.h"
#import "Utilities.h"

const Byte ATTCP_VERSION = 0;
const Byte ATHeartBeat = 1;
const Byte ATData = 2;
const Byte ATGzipData = 3;
//const Byte ATZipData = 4;

const Byte ATOpenApiTracking = 1;
const Byte ATOpenApiData = 2;

@implementation ATTCPLogManager

#pragma mark - init
+(instancetype)sharedManager {
    static ATTCPLogManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATTCPLogManager alloc] init];
    });
    return sharedManager;
}

- (void)sendTCPToOpenApi:(ATTCPSocketOpenApiType)type paramters:(id)parameters completion:(nonnull void (^)(NSData * _Nonnull, NSError * _Nullable))completion {
    NSData *data = [[[parameters jsonString_anythink] dataUsingEncoding:NSUTF8StringEncoding] gzippedData_ATKit];
    if (data.length == 0) {
        completion(parameters,nil);
        return;
    }
    
    int dataLength = (int)data.length;
    
    Byte header[7] = {};
    header[0] = ATTCP_VERSION;
    header[1] = ATGzipData;
    header[2] = (type == ATTCPSocketOpenApiTracking ? ATOpenApiTracking : ATOpenApiData);
    header[3] =(Byte)((dataLength & 0xFF000000)>>24);
    header[4] =(Byte)((dataLength & 0x00FF0000)>>16);
    header[5] =(Byte)((dataLength & 0x0000FF00)>>8);
    header[6] =(Byte)((dataLength & 0x000000FF));
    
    NSData *headerData = [NSData dataWithBytes:header length:7];
    
    NSMutableData *totalData = [NSMutableData new];
    [totalData appendData:headerData];
    [totalData appendData:data];

    [[ATTCPSocketManager sharedManager] sendData:totalData completionHandler:^(NSError * _Nullable error) {
        if (error) {
            completion(parameters,error);
        }else {
            completion(parameters,nil);
        }
    }];
}


@end
