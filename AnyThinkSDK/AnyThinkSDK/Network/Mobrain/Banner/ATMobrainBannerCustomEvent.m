//
//  ATMobrainBannerCustomEvent.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainBannerCustomEvent.h"
#import "ATMobrainBannerApis.h"
#import "ATLogger.h"
#import "Utilities.h"

@interface ATMobrainBannerCustomEvent ()
//@property(nonatomic, copy) NSString *ecpm;
//@property(nonatomic, copy) NSString *ritID;
//@property(nonatomic) NSUInteger platformID;
@property(nonatomic, strong) id<ATABUBannerAd> bannerAd;

@end
@implementation ATMobrainBannerCustomEvent

// 回调事件
- (void)bannerAdDidLoad:(id<ATABUBannerAd> _Nonnull)bannerAd bannerView:(UIView *)bannerView{
    [ATLogger logMessage:@"ATMobrainBannerCustomEvent::bannerAdViewDidLoad" type:ATLogTypeExternal];
    [self trackBannerAdLoaded:bannerView adExtra:nil];
    self.bannerAd = bannerAd;
//    self.ecpm = [bannerAd getPreEcpm];
//    self.ritID = [bannerAd getAdNetworkRitId];
//    self.platformID = [bannerAd getAdNetworkPlaformId];
}
/**
 This method is called when bannerAdView ad slot failed to load.
 @param error : the reason of error
 */
- (void)bannerAd:(id<ATABUBannerAd> _Nonnull)bannerAd didLoadFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATMobrainBannerCustomEvent::bannerAdView:didLoadFailWithError,%@", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
}
/**
 This method is called when bannerAdView ad slot showed new ad.
 */
- (void)bannerAdDidBecomVisible:(id<ATABUBannerAd> _Nonnull)ABUBannerAd bannerView:(UIView *)bannerView {
    [ATLogger logMessage:@"ATMobrainBannerCustomEvent::bannerAdViewDidBecomVisible" type:ATLogTypeExternal];
    [self trackBannerAdImpression];
}

/**
 * This method is called when FullScreen modal has been presented.
 *  弹出详情广告页
 */
- (void)bannerAdWillPresentFullScreenModal:(id<ATABUBannerAd> _Nonnull)ABUBannerAd bannerView:(UIView *)bannerView {
    [ATLogger logMessage:@"ATMobrainBannerCustomEvent::bannerAdViewWillPresentFullScreenModal" type:ATLogTypeExternal];
}

- (void)bannerAdWillDismissFullScreenModal:(id<ATABUBannerAd> _Nonnull)ABUBannerAd bannerView:(UIView *)bannerView {
    [ATLogger logMessage:@"ATMobrainBannerCustomEvent::bannerAdWillDismissFullScreenModal" type:ATLogTypeExternal];
}
/**
 This method is called when bannerAdView is clicked.
 */
- (void)bannerAdDidClick:(id<ATABUBannerAd> _Nonnull)ABUBannerAd bannerView:(UIView *)bannerView {
    [ATLogger logMessage:@"ATMobrainBannerCustomEvent::bannerAdViewDidClick" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

/**
 This method is called when the user clicked dislike button and chose dislike reasons.
 @param filterwords : the array of reasons for dislike.
 */
- (void)bannerAdDidClosed:(id<ATABUBannerAd> _Nonnull)ABUBannerAd bannerView:(UIView *)bannerView dislikeWithReason:(NSArray<id> *_Nullable)filterwords {
    [ATLogger logMessage:@"ATMobrainBannerCustomEvent::bannerAdViewDidClosed" type:ATLogTypeExternal];
    [self trackBannerAdClosed];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {

    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra AT_setDictValue:@([self.bannerAd getAdNetworkPlaformId]) key:@"network_id"];
    [extra AT_setDictValue:[self.bannerAd getAdNetworkRitId] key:@"network_unit_id"];
    [extra AT_setDictValue:[self.bannerAd getPreEcpm] key:@"network_ecpm"];

    return extra;
}
@end
