//
//  ATIronsourceBaseManager.h
//  AnyThinkIronSourceAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kIronSourceClassName;
@interface ATIronsourceBaseManager : ATNetworkBaseManager

@end

@protocol ATBaseIronSource<NSObject>
+ (void)setConsent:(BOOL)consent;
+ (NSString *)sdkVersion;
+ (BOOL)setDynamicUserId:(NSString *)dynamicUserId;
+ (void)initISDemandOnly:(NSString *)appKey adUnits:(NSArray<NSString *> *)adUnits;

+ (void)setMetaDataWithKey:(NSString *)key value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
