//
//  ATYeahmobiInterstitialAdapter.h
//  AnyThinkYeahmobiInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/16.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATYeahmobiInterstitialAdapter : NSObject
@end

@protocol ATCTService<NSObject>
#pragma mark - CTService config Method
+ (instancetype)shareManager;
- (void)loadRequestGetCTSDKConfigBySlot_id:(NSString *)slot_id;
- (void)uploadConsentValue:(NSString *)consentValue consentType:(NSString *)consentType complete:(void(^)(BOOL state))complete;
- (NSString*)getSDKVersion;
- (void)preloadMRAIDInterstitialAdWithSlotId:(NSString *)slotid delegate:(id)delegate isTest:(BOOL)isTest;
- (void)mraidInterstitialShow;
- (BOOL)mraidInterstitialIsReady;
@end

@protocol ATCTADMRAIDView<NSObject>
@end
@protocol CTAdViewDelegate <NSObject>
@optional
- (BOOL)CTAdView:(id<ATCTADMRAIDView>)adView shouldOpenURL:(NSURL*)url;
- (void)CTAdViewDidRecieveInterstitialAd;
- (void)CTAdViewDidRecieveInterstitialAdForSlot:(NSString *)slot;
- (void)CTAdView:(id<ATCTADMRAIDView>)adView didFailToReceiveAdWithError:(NSError*)error;
- (void)CTAdViewCloseButtonPressed:(id<ATCTADMRAIDView>)adView;
- (void)CTAdViewInternalBrowserWillOpen:(id<ATCTADMRAIDView>)adView;
- (void)CTAdViewInternalBrowserDidOpen:(id<ATCTADMRAIDView>)adView;
- (void)CTAdViewInternalBrowserWillClose:(id<ATCTADMRAIDView>)adView;
- (void)CTAdViewInternalBrowserDidClose:(id<ATCTADMRAIDView>)adView;
- (void)CTAdViewWillLeaveApplication:(id<ATCTADMRAIDView>)adView;
- (BOOL)CTAdView:(id<ATCTADMRAIDView>)adView shouldLogEvent:(NSString*)event ofType:(NSInteger)type;
- (UIViewController*)CTAdViewPresentationController:(id<ATCTADMRAIDView>)adView;

@end
NS_ASSUME_NONNULL_END
