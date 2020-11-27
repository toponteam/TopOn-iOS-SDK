//
//  ATTCPSocketManager.h
//  AnyThinkSDK
//
//  Created by Topon on 7/3/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATTCPSocketManager : NSObject
+(instancetype)sharedManager;

-(void)sendData:(NSData *_Nonnull)data completionHandler:(nullable void (^)(NSError * __nullable error))handler;

@end

@interface ATTCPClientSocket : NSObject
- (instancetype _Nonnull )initWithHost:(NSString *)host onPort:(uint16_t)port;
- (void)sendData:(NSData *_Nonnull)data completionHandler:(nullable void (^)(NSError * __nullable error))handler;
- (void)connectCompletion:(nullable void (^)(NSError * __nullable error))completion;
- (BOOL)isConnected;
- (void)disconnect;
- (void)removeSendDataCompletion;
@end

NS_ASSUME_NONNULL_END
