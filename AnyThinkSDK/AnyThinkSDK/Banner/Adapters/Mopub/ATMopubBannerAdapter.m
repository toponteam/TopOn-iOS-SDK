//
//  ATMopubBannerAdapter.m
//  AnyThinkMopubBannerAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubBannerAdapter.h"
#import "ATMopubBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
@interface ATMopubBannerAdapter()
@property(nonatomic) id<ATMPAdView> adView;
@property(nonatomic, readonly) ATMopubBannerCustomEvent *customEvent;
@end
@implementation ATMopubBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];
            [[ATAPI sharedInstance] setVersion:[mopub version] forNetwork:kNetworkNameMopub];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMopub]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMopub];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMopub]) {
                    if ([[ATAPI sharedInstance].networkConsentInfo[kNetworkNameMopub] boolValue]) {
                        [mopub grantConsent];
                    } else {
                        [mopub revokeConsent];
                    }
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) {
                        if (limit) {
                            [mopub revokeConsent];
                        } else {
                            [mopub grantConsent];
                        }
                    }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MPAdView") != nil) {
        _customEvent = [[ATMopubBannerCustomEvent alloc] initWithUnitID:info[@"unitid"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.rootViewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]];
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];
        __weak typeof(self) weakSelf = self;
        void(^Load)(void) = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.adView = [[NSClassFromString(@"MPAdView") alloc] initWithAdUnitId:info[@"unitid"] size:CGSizeMake(unitGroupModel.adSize.width, unitGroupModel.adSize.height)];
                weakSelf.adView.delegate = self->_customEvent;
                weakSelf.adView.frame = CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height);
                [weakSelf.adView loadAd];
            });
        };
        if(![ATAPI getMPisInit]){
            [ATAPI setMPisInit:YES];
            [mopub initializeSdkWithConfiguration:[[NSClassFromString(@"MPMoPubConfiguration") alloc] initWithAdUnitIdForAppInitialization:info[@"unitid"]] completion:^{
                Load();
            }];
        }else{
             Load();
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mopub"]}]);
    }
}
@end
