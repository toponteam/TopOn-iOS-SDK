//
//  ATMyTargetAdViewApis.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef ATMyTargetAdViewApis_h
#define ATMyTargetAdViewApis_h

typedef enum : NSUInteger
{
    ATMTRGAdSizeType320x50,
    ATMTRGAdSizeType300x250,
    ATMTRGAdSizeType728x90,
    ATMTRGAdSizeTypeAdaptive
} ATMTRGAdSizeType;

@protocol MTRGAdViewDelegate;

@protocol ATMTRGAdSize <NSObject>

@property(nonatomic, readonly) CGSize size;
@property(nonatomic, readonly) ATMTRGAdSizeType type;

+ (instancetype)adSize320x50;
+ (instancetype)adSize300x250;
+ (instancetype)adSize728x90;
+ (instancetype)adSizeForCurrentOrientation;
+ (instancetype)adSizeForCurrentOrientationForWidth:(CGFloat)width;

@end

@protocol ATMTRGAdView <NSObject>

@property(nonatomic, weak, nullable) id <MTRGAdViewDelegate> delegate;
@property(nonatomic, weak, nullable) UIViewController *viewController;
//@property(nonatomic, readonly) MTRGCustomParams *customParams;
@property(nonatomic) BOOL trackLocationEnabled;
@property(nonatomic) BOOL mediationEnabled;
@property(nonatomic) id<ATMTRGAdSize> adSize;
@property(nonatomic, readonly) NSUInteger slotId;
@property(nonatomic, readonly) BOOL shouldRefreshAd;
@property(nonatomic, readonly, nullable) NSString *adSource;
@property(nonatomic, readonly) float adSourcePriority;

+ (void)setDebugMode:(BOOL)enabled;

+ (BOOL)isDebugMode;

+ (instancetype)adViewWithSlotId:(NSUInteger)slotId;

+ (instancetype)adViewWithSlotId:(NSUInteger)slotId shouldRefreshAd:(BOOL)shouldRefreshAd;

//- (instancetype)withTestDevices:(nullable NSArray<NSString *> *)testDevices NS_SWIFT_NAME(withTestDevices(_:));

- (void)load;

- (void)loadFromBid:(NSString *)bidId;

@end

@protocol MTRGAdViewDelegate <NSObject>

- (void)onLoadWithAdView:(id<ATMTRGAdView>)adView;

- (void)onNoAdWithReason:(NSString *)reason adView:(id<ATMTRGAdView>)adView;

@optional

- (void)onAdClickWithAdView:(id<ATMTRGAdView>)adView;

- (void)onAdShowWithAdView:(id<ATMTRGAdView>)adView;

- (void)onShowModalWithAdView:(id<ATMTRGAdView>)adView;

- (void)onDismissModalWithAdView:(id<ATMTRGAdView>)adView;

- (void)onLeaveApplicationWithAdView:(id<ATMTRGAdView>)adView;

@end

#endif /* ATMyTargetAdViewApis_h */

NS_ASSUME_NONNULL_END
