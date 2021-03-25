//
//  ATAdmobBaseManager.h
//  AnyThinkAdmobAdapter
//
//  Created by Topon on 11/13/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATAdmobBaseManager : ATNetworkBaseManager
+ (void)initGoogleAdManagerWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo;
@end

typedef NS_ENUM(NSInteger, ATPACConsentStatus) {
    ATPACConsentStatusUnknown = 0,          ///< Unknown consent status.
    ATPACConsentStatusNonPersonalized = 1,  ///< User consented to non-personalized ads.
    ATPACConsentStatusPersonalized = 2,     ///< User consented to personalized ads.
};

@protocol ATPACConsentInformation<NSObject>
+ (instancetype)sharedInstance;
@property(nonatomic) ATPACConsentStatus consentStatus;
@property(nonatomic, getter=isTaggedForUnderAgeOfConsent) BOOL tagForUnderAgeOfConsent;
@end

@protocol ATGADRequestConfiguration <NSObject>

- (void)tagForChildDirectedTreatment:(BOOL)childDirectedTreatment;
- (void)tagForUnderAgeOfConsent:(BOOL)underAgeOfConsent;

@end
@protocol ATGADMobileAds<NSObject>
+ (id<ATGADMobileAds>)sharedInstance;
@property(nonatomic, nonnull, readonly) NSString *sdkVersion;
@property(nonatomic, readonly, strong, nonnull) id<ATGADRequestConfiguration> requestConfiguration;
@end

NS_ASSUME_NONNULL_END
