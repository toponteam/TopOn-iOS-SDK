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
-(instancetype)initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo{
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handelRewardedSuccessNotification:) name:kAdColonyRewardedSuccess object:nil];
    }
    return self;
}

- (void)adColonyInterstitialDidLoad:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidLoad:" type:ATLogTypeInternal];
    objc_setAssociatedObject(interstitial, (__bridge_retained void*)kAdColonyRVCustomEventKey, self, OBJC_ASSOCIATION_RETAIN);
    [self trackRewardedVideoAdLoaded:interstitial adExtra:nil];
    
}

- (void)adColonyInterstitialDidFailToLoad:(id<AdColonyAdRequestError>)error {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidFailToLoad" type:ATLogTypeInternal];
    [self trackRewardedVideoAdLoadFailed:(NSError*)error];
}

- (void)adColonyInterstitialWillOpen:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialWillOpen" type:ATLogTypeInternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)adColonyInterstitialDidClose:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidClose" type:ATLogTypeInternal];
    [self trackRewardedVideoAdVideoEnd];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

- (void)adColonyInterstitialExpired:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    
}

- (void)adColonyInterstitialWillLeaveApplication:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    
}

- (void)adColonyInterstitialDidReceiveClick:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidReceiveClick" type:ATLogTypeInternal];
    [self trackRewardedVideoAdClick];
}

- (void)adColonyInterstitial:(id<ATAdColonyInterstitial> _Nonnull)interstitial iapOpportunityWithProductId:(NSString * _Nonnull)iapProductID andEngagement:(ATAdColonyIAPEngagement)engagement {
    
}

-(void) handelRewardedSuccessNotification:(NSNotification*)notify {
    [ATLogger logMessage:@"ATAdColonyRewardedVideoCustomEvent::adColonyInterstitialDidRewardedSuccess" type:ATLogTypeInternal];
    self.rewardGranted = YES;
    [self trackRewardedVideoAdRewarded];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAdColonyRewardedSuccess object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"zone_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"zone_id"];
//    return extra;
//}

@end
