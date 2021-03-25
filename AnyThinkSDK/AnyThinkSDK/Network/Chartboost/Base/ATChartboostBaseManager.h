//
//  ATChartboostBaseManager.h
//  AnyThinkChartboostAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATChartboostBaseManager : ATNetworkBaseManager

@end

@protocol ATCHBDataUseConsent <NSObject>

@property (nonatomic, readonly) NSString *privacyStandard;

@end
@protocol ATChartboost<NSObject>
+ (void)startWithAppId:(NSString*)appId appSignature:(NSString*)appSignature completion:(void (^)(BOOL))completion;
+ (NSString*)getSDKVersion;
+ (void)addDataUseConsent:(id<ATCHBDataUseConsent>)consent;

@end

NS_ASSUME_NONNULL_END
