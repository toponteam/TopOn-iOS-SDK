//
//  ATSigmobBaseManager.h
//  AnyThinkSigmobAdapter
//
//  Created by Topon on 11/15/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATSigmobBaseManager : ATNetworkBaseManager

@end

@protocol ATWindAdOptions<NSObject>
@property (readonly, nonatomic) NSString* appId;
@property (readonly, nonatomic) NSString* apiKey;
+ (instancetype)options;
- (instancetype)initWithAppId:(NSString *)appId appKey:(NSString *)appKey usedMediation:(BOOL)usedMediation;

@end

@protocol ATWindAds<NSObject>
+ (void) startWithOptions:(nullable id<ATWindAdOptions>)options;
+ (NSString * _Nonnull)sdkVersion;
@end

NS_ASSUME_NONNULL_END
