//
//  ATYeahmobiBannerAdapter.h
//  AnyThinkYeahmobiBannerAdapter
//
//  Created by Martin Lau on 2018/10/16.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATYeahmobiBannerAdapter : NSObject
@end

@protocol ATCTService<NSObject>
#pragma mark - CTService config Method
+ (instancetype)shareManager;
- (void)loadRequestGetCTSDKConfigBySlot_id:(NSString *)slot_id;
- (void)uploadConsentValue:(NSString *)consentValue consentType:(NSString *)consentType complete:(void(^)(BOOL state))complete;
- (void)getMRAIDBannerAdWithSlot:(NSString*)slotid delegate:(id)delegate adSize:(NSInteger)size isTest:(BOOL)isTest;
- (NSString*)getSDKVersion;
@end

@protocol CTAdViewDelegate;
@protocol ATCTADMRAIDView<NSObject>
@property(nonatomic) CGRect frame;
@property (nonatomic, weak) id<CTAdViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger placementType;
@property (nonatomic, readonly) UIView* expandView;
@property (nonatomic, assign) BOOL modalDismissAfterPresent;
@property (nonatomic, assign) BOOL useInternalBrowser;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, readonly) NSString* slot;
- (void)unregisterProtocolClass;
@end


@protocol CTAdViewDelegate <NSObject>
@optional
- (void)CTAdViewDidRecieveBannerAd:(id<ATCTADMRAIDView>)adView;
- (void)CTAdView:(id<ATCTADMRAIDView>)adView didFailToReceiveAdWithError:(NSError*)error;
- (BOOL)CTAdView:(id<ATCTADMRAIDView>)adView shouldOpenURL:(NSURL*)url;
- (void)CTAdViewCloseButtonPressed:(id<ATCTADMRAIDView>)adView;
- (void)CTAdViewWillExpand:(id<ATCTADMRAIDView>)adView;
- (void)CTAdViewDidExpand:(id<ATCTADMRAIDView>)adView;
- (void)CTAdView:(id<ATCTADMRAIDView>)adView willResizeToFrame:(CGRect)frame;
- (void)CTAdView:(id<ATCTADMRAIDView>)adView didResizeToFrame:(CGRect)frame;
- (void)CTAdViewWillCollapse:(id<ATCTADMRAIDView>)adView;
- (void)CTAdViewDidCollapse:(id<ATCTADMRAIDView>)adView;
- (void)CTAdViewWillLeaveApplication:(id<ATCTADMRAIDView>)adView;
- (BOOL)CTAdView:(id<ATCTADMRAIDView>)adView shouldLogEvent:(NSString*)event ofType:(NSInteger)type;
- (BOOL)CTAdViewSupportsSMS:(id<ATCTADMRAIDView>)adView;
- (BOOL)CTAdViewSupportsPhone:(id<ATCTADMRAIDView>)adView;
- (BOOL)CTAdView:(id<ATCTADMRAIDView>)adView shouldPlayVideo:(NSString*)videoURL;
- (UIViewController*)CTAdViewPresentationController:(id<ATCTADMRAIDView>)adView;
- (UIView*)CTAdViewResizeSuperview:(id<ATCTADMRAIDView>)adView;
@end
NS_ASSUME_NONNULL_END
