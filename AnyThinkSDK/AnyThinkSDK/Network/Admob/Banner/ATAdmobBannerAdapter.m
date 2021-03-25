//
//  ATAdmobBannerAdapter.m
//  AnyThinkAdmobBannerAdapter
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobBannerAdapter.h"
#import "ATAdmobBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATBannerManager.h"
#import "ATAdManager+Banner.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATAdmobBaseManager.h"

@interface ATAdmobBannerAdapter()
@property(nonatomic, readonly) ATAdmobBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADBannerView> bannerView;
@end
@implementation ATAdmobBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAdmobBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GADBannerView") != nil && NSClassFromString(@"GADRequest") != nil) {
        _customEvent = [[ATAdmobBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        CGSize unitGroupSize = ((ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey]).adSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (localInfo[kATAdLoadingExtraAdmobBannerSizeKey] != nil && localInfo[kATAdLoadingExtraAdmobAdSizeFlagsKey] != nil) {
                CGSize size = [localInfo[kATAdLoadingExtraAdmobBannerSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [localInfo[kATAdLoadingExtraAdmobBannerSizeKey] CGSizeValue] : CGSizeMake(unitGroupSize.width, unitGroupSize.height);
                NSInteger flags = [localInfo[kATAdLoadingExtraAdmobAdSizeFlagsKey] integerValue];

                self->_customEvent.admobAdSizeValue = localInfo[kATAdLoadingExtraAdmobBannerSizeKey];
                self->_customEvent.admobAdSizeFlags = [localInfo[kATAdLoadingExtraAdmobAdSizeFlagsKey] integerValue];
                self->_bannerView = [[NSClassFromString(@"GADBannerView") alloc] init];
                self->_bannerView.adSize = (GADAdSize){size, flags};
            }else {
                self->_bannerView = [[NSClassFromString(@"GADBannerView") alloc] initWithAdSize:(GADAdSize){CGSizeMake(unitGroupSize.width, unitGroupSize.height), 0}];
            }
            
            self->_bannerView.adUnitID = serverInfo[@"unit_id"];
            self->_bannerView.delegate = self->_customEvent;
            self->_bannerView.adSizeDelegate = self->_customEvent;
            self->_bannerView.rootViewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]];
            [self->_bannerView loadRequest:[NSClassFromString(@"GADRequest") request]];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}
@end
