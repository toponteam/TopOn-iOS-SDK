//
//  ATTCPLogManager.h
//  AnyThinkSDK
//
//  Created by Topon on 7/7/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, ATTCPSocketOpenApiType) {
    ATTCPSocketOpenApiTracking = 1,
    ATTCPSocketOpenApiData = 2
};

@interface ATTCPLogManager : NSObject
+(instancetype)sharedManager;

- (void)sendTCPToOpenApi:(ATTCPSocketOpenApiType)type paramters:(id)parameters completion:(void(^)(NSData *data, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
