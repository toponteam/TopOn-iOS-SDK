//
//  ATFlurryBannerAdapter.h
//  AnyThinkFlurryBannerAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ATFlurryLogLevelNone = 0,         //No output
    ATFlurryLogLevelCriticalOnly,     //Default, outputs only critical log events
    ATFlurryLogLevelDebug,            //Debug level, outputs critical and main log events
    ATFlurryLogLevelAll               //Highest level, outputs all log events
} ATFlurryLogLevel;

@interface ATFlurryBannerAdapter : NSObject

@end

@protocol ATFlurryConsent<NSObject>
- (instancetype) initWithGDPRScope:(BOOL)isGDPRScope andConsentStrings:(NSDictionary*)consentStrings;
+ (BOOL) updateConsentInformation:(id<ATFlurryConsent>)consent;
@end

@protocol ATFlurrySessionBuilder<NSObject>
- (instancetype) withCrashReporting:(BOOL)value;
- (instancetype) withLogLevel:(NSInteger) value;
@end

@protocol ATFlurry<NSObject>
+ (void)setUserID:(nullable NSString *)userID;
+ (NSString *)getFlurryAgentVersion;
+ (void) startSession:(NSString *)apiKey withSessionBuilder:(id<ATFlurrySessionBuilder>)sessionBuilder;
@end

@protocol FlurryAdBannerDelegate;
@protocol ATFlurryAdBanner<NSObject>
@property (nonatomic, copy) NSString* space;
//@property (nonatomic, strong) FlurryAdTargeting* targeting;
@property (nonatomic, weak) id<FlurryAdBannerDelegate> adDelegate;
@property (nonatomic, readonly) BOOL ready;
- (id) initWithSpace:(NSString *)space;
- (void) fetchAdForFrame:(CGRect)frame;
- (void) displayAdInView:(UIView *)view viewControllerForPresentation:(UIViewController *)viewController;
- (void) fetchAndDisplayAdInView:(UIView *)view viewControllerForPresentation:(UIViewController *)viewController;
@end

@protocol FlurryAdBannerDelegate <NSObject>
@optional
- (void) adBannerDidFetchAd:(id<ATFlurryAdBanner>)bannerAd;
- (void) adBannerDidRender:(id<ATFlurryAdBanner>)bannerAd;
- (void) adBannerWillPresentFullscreen:(id<ATFlurryAdBanner>)bannerAd;
- (void) adBannerWillLeaveApplication:(id<ATFlurryAdBanner>)bannerAd;
- (void) adBannerWillDismissFullscreen:(id<ATFlurryAdBanner>)bannerAd;
- (void) adBannerDidDismissFullscreen:(id<ATFlurryAdBanner>)bannerAd;
- (void) adBannerDidReceiveClick:(id<ATFlurryAdBanner>)bannerAd;
- (void) adBannerVideoDidFinish:(id<ATFlurryAdBanner>)bannerAd;
- (void) adBanner:(id<ATFlurryAdBanner>) bannerAd adError:(NSInteger) adError errorDescription:(NSError*) errorDescription;
@end
NS_ASSUME_NONNULL_END
