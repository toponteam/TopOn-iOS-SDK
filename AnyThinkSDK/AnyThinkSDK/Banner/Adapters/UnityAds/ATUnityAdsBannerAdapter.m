//
//  ATUnityAdsBannerAdapter.m
//  AnyThinkUnityAdsBannerAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsBannerAdapter.h"
#import "ATUnityAdsBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAppSettingManager.h"
#import "ATAdManager+Banner.h"

@interface ATUnityAdsBannerAdapter()
@property(nonatomic, readonly) ATUnityAdsBannerCustomEvent *customEvent;
@property (strong, nonatomic) id<UADSBannerView> bannerView;
@end
@implementation ATUnityAdsBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameUnityAds]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameUnityAds];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"UnityAds") getVersion] forNetwork:kNetworkNameUnityAds];
            id playerMetaData = [[NSClassFromString(@"UADSMetaData") alloc] init];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameUnityAds]) {
                [playerMetaData set:@"gdpr.consent" value:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameUnityAds]];
            } else {
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [playerMetaData set:@"gdpr.consent" value:@(!limit)]; }
                
            }
            [playerMetaData commit];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"UADSBannerView") != nil && NSClassFromString(@"UnityAds") != nil) {
        _customEvent = [[ATUnityAdsBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        
        if (![NSClassFromString(@"UnityAds") isInitialized]) {
            [NSClassFromString(@"UnityAds") initialize:serverInfo[@"game_id"]];
        }
        self.bannerView = [[NSClassFromString(@"UADSBannerView") alloc] initWithPlacementId:serverInfo[@"placement_id"] size:[self sizeToSizeType:serverInfo[@"size"]]];
        self.bannerView.delegate = _customEvent;
        [self.bannerView load];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"UnityAds"]}]);
    }
}

- (CGSize) sizeToSizeType:(NSString *)sizeStr {
    if ([sizeStr isEqualToString:@"728x90"]) {
        return CGSizeMake(728.0f, 90.0f);
    } else if ([sizeStr isEqualToString:@"468x60"]) {
        return CGSizeMake(468.0f, 60.0f);
    } else {
        return CGSizeMake(320.0f, 50.0f);
    }
}

@end
