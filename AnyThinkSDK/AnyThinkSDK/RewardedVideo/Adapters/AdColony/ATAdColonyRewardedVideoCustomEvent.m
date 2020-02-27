//
//  ATAdColonyRewardedVideoCustomEvent.m
//  AnyThinkAdColonyRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdColonyRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import <objc/runtime.h>
#import "ATAdColonyRewardedVideoAdapter.h"
#import "Utilities.h"
@implementation ATAdColonyRewardedVideoCustomEvent
static NSString *const kAdColonyRewardedSuccess = @"com.topon.adColony_rewarded_success";

#pragma mark -new delegate
-(instancetype)initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo{
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handelRewardedSuccessNotification:) name:kAdColonyRewardedSuccess object:nil];

    }
    return self;
}

- (void)adColonyInterstitialDidLoad:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidLoad:" type:ATLogTypeInternal];
    objc_setAssociatedObject(interstitial, (__bridge_retained void*)kAdColonyRVCustomEventKey, self, OBJC_ASSOCIATION_RETAIN);
    [self handleAssets:@{kAdAssetsCustomObjectKey:interstitial, kRewardedVideoAssetsUnitIDKey:self.unitID}];
    
}

- (void)adColonyInterstitialDidFailToLoad:(id<AdColonyAdRequestError>)error {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidFailToLoad" type:ATLogTypeInternal];
    [self handleLoadingFailure:(NSError*)error];
}

- (void)adColonyInterstitialWillOpen:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialWillOpen" type:ATLogTypeInternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)adColonyInterstitialDidClose:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidClose" type:ATLogTypeInternal];
    [self handleClose];
    [self trackVideoEnd];
    [self saveVideoCloseEventRewarded:self.rewardGranted];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }

    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)adColonyInterstitialExpired:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    
}

- (void)adColonyInterstitialWillLeaveApplication:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    
}

- (void)adColonyInterstitialDidReceiveClick:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidReceiveClick" type:ATLogTypeInternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)adColonyInterstitial:(id<ATAdColonyInterstitial> _Nonnull)interstitial iapOpportunityWithProductId:(NSString * _Nonnull)iapProductID andEngagement:(ATAdColonyIAPEngagement)engagement {
    
}

-(void) handelRewardedSuccessNotification:(NSNotification*)notify {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidRewardedSuccess" type:ATLogTypeInternal];
    self.rewardGranted = YES;

    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
