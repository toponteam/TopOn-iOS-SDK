//
//  HBAdBidError.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/10.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const HBAdBidErrorDomain;

typedef enum {
    GDBidErrorUnknown = -1,
    GDBidErrorInputParamersInvalid = 10000,
    GDBidErrorNoValidResponse = 10001,
    GDBidErrorNetworkNotSupportCurrentAdFormat = 10002,
    GDBidErrorNetworkBidFailed = 10003,
    GDBidErrorNetworkBidTimeout = 10004,
    GDBidErrorNetworkPriceInvalid = 10005

} GDBidErrorCode;

@interface HBAdBidError : NSObject

+ (NSError *)errorWithCode:(GDBidErrorCode)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;
+ (NSError *)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

@end

NS_ASSUME_NONNULL_END
