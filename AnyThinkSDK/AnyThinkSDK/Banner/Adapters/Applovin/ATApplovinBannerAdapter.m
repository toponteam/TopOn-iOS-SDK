//
//  ATApplovinBannerAdapter.m
//  AnyThinkApplovinBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinBannerAdapter.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATApplovinBannerCustomEvent.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
@interface ATApplovinBannerAdapter()
@property(nonatomic, readonly) id<ATALAdView> bannerView;
@property(nonatomic, readonly) ATApplovinBannerCustomEvent *customEvent;
@end
@implementation ATApplovinBannerAdapter
+(void) showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    id<ATALAdView> bannerView = banner.bannerView;
    [bannerView render:banner.customObject];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameApplovin]) {
            [[ATAPI sharedInstance] setVersion:@([NSClassFromString(@"ALSdk") versionCode]).stringValue forNetwork:kNetworkNameApplovin];
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameApplovin];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameApplovin]) {
                [NSClassFromString(@"ALPrivacySettings") setHasUserConsent:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameApplovin][kApplovinConscentStatusKey] boolValue]];
                [NSClassFromString(@"ALPrivacySettings") setIsAgeRestrictedUser:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameApplovin][kApplovinUnderAgeKey] boolValue]];
            } else {
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) { [NSClassFromString(@"ALPrivacySettings") setHasUserConsent:!limit]; }
                
            }
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"ALAdView") != nil && NSClassFromString(@"ALSdk") != nil && NSClassFromString(@"ALAdSize") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        _customEvent = [[ATApplovinBannerCustomEvent alloc] initWithUnitID:info[@"zone_id"] customInfo:info sdkKey:info[@"sdkkey"] alSize:unitGroupModel.adSize];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
//            self->_bannerView = [[NSClassFromString(@"ALAdView") alloc] initWithFrame:CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height) size:CGSizeEqualToSize(unitGroupModel.adSize, CGSizeMake(300.0f, 250.0f)) ? [NSClassFromString(@"ALAdSize") sizeMRec] : [NSClassFromString(@"ALAdSize") sizeBanner] sdk:[NSClassFromString(@"ALSdk") sharedWithKey:info[@"sdkkey"]]];
            self->_bannerView = [[NSClassFromString(@"ALAdView") alloc] initWithSdk:[NSClassFromString(@"ALSdk") sharedWithKey:info[@"sdkkey"]] size:CGSizeEqualToSize(unitGroupModel.adSize, CGSizeMake(300.0f, 250.0f)) ? [NSClassFromString(@"ALAdSize") sizeMRec] : [NSClassFromString(@"ALAdSize") sizeBanner] zoneIdentifier:info[@"zone_id"]];
            self->_bannerView.adLoadDelegate = self->_customEvent;
            self->_bannerView.adEventDelegate = self->_customEvent;
            self->_bannerView.adEventDelegate = self->_customEvent;
            self->_customEvent.alAdView = self->_bannerView;
            [self->_bannerView loadNextAd];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Applovin"]}]);
    }
}
@end
