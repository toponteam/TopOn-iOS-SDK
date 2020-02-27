//
//  ATFlurryRewardedVideoAdapter.h
//  AnyThinkFlurryRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRewardedVideoAdapter.h"
#import <UIKit/UIKit.h>
extern NSString *const kFlurryRVAssetsCustomEventKey;
typedef enum {
    ATFlurryLogLevelNone = 0,         //No output
    ATFlurryLogLevelCriticalOnly,     //Default, outputs only critical log events
    ATFlurryLogLevelDebug,            //Debug level, outputs critical and main log events
    ATFlurryLogLevelAll               //Highest level, outputs all log events
} ATFlurryLogLevel;

typedef enum
{
    AT_FLURRY_AD_ERROR_DID_FAIL_TO_RENDER   = 0,
    AT_FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD = 1,
    AT_FLURRY_AD_ERROR_CLICK_ACTION_FAILED  = 2,
}ATFlurryAdError;
@interface ATFlurryRewardedVideoAdapter : NSObject<ATRewardedVideoAdapter>

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

@protocol ATFlurryAdInterstitialDelegate;
@protocol ATFlurryAdInterstitial<NSObject>
- (id) initWithSpace:(NSString *)space;
- (void) fetchAd;
- (void) presentWithViewController: (UIViewController *) presentingViewController;
@property (nonatomic, readonly) BOOL ready;
@property (nonatomic, weak) id<ATFlurryAdInterstitialDelegate> adDelegate;
@end

@protocol ATFlurryAdInterstitialDelegate <NSObject>
@optional
- (void) adInterstitialDidFetchAd:(id<ATFlurryAdInterstitial>)interstitialAd;
- (void) adInterstitialDidRender:(id<ATFlurryAdInterstitial>)interstitialAd;
- (void) adInterstitialWillPresent:(id<ATFlurryAdInterstitial>)interstitialAd;
- (void) adInterstitialWillLeaveApplication:(id<ATFlurryAdInterstitial>)interstitialAd;
- (void) adInterstitialWillDismiss:(id<ATFlurryAdInterstitial>)interstitialAd;
- (void) adInterstitialDidDismiss:(id<ATFlurryAdInterstitial>)interstitialAd;
- (void) adInterstitialDidReceiveClick:(id<ATFlurryAdInterstitial>)interstitialAd;
- (void) adInterstitialVideoDidFinish:(id<ATFlurryAdInterstitial>)interstitialAd;
- (void) adInterstitial:(id<ATFlurryAdInterstitial>) interstitialAd adError:(ATFlurryAdError) adError errorDescription:(NSError*) errorDescription;
@end
