//
//  ATFlurryNativeAdapter.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
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

@interface ATFlurryNativeAdapter : NSObject
@end

@protocol ATFlurryConsent<NSObject>
- (instancetype) initWithGDPRScope:(BOOL)isGDPRScope andConsentStrings:(NSDictionary*)consentStrings;
+ (BOOL) updateConsentInformation:(id<ATFlurryConsent>)consent;
@end

@protocol ATFlurrySessionBuilder<NSObject>
- (instancetype) withCrashReporting:(BOOL)value;
- (instancetype) withLogLevel:(ATFlurryLogLevel) value;
@end

@protocol ATFlurry<NSObject>
+ (NSString *)getFlurryAgentVersion;
+ (void) startSession:(NSString *)apiKey withSessionBuilder:(id<ATFlurrySessionBuilder>)sessionBuilder;
@end

@protocol ATFlurryAdNativeAsset<NSObject>
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *value;
@end

@protocol ATFlurryAdNativeDelegate;
@protocol ATFlurryAdNative<NSObject>
- (id) initWithSpace:(NSString *)space;
- (void) fetchAd;
- (BOOL)isVideoAd;
@property (nonatomic, weak) id<ATFlurryAdNativeDelegate> adDelegate;
@property (nonatomic, strong, readonly) NSArray *assetList;
@property (nonatomic, weak) UIViewController* viewControllerForPresentation;
@property (nonatomic, strong) UIView *trackingView;
@property (nonatomic, strong) UIView* videoViewContainer;
@end

@protocol ATFlurryAdNativeDelegate<NSObject>
- (void) adNativeDidFetchAd:(id<ATFlurryAdNative>)nativeAd;
- (void) adNative:(id<ATFlurryAdNative>)nativeAd adError:(ATFlurryAdError)adError errorDescription:(NSError*) errorDescription;
- (void) adNativeDidLogImpression:(id<ATFlurryAdNative>) nativeAd;
- (void) adNativeDidReceiveClick:(id<ATFlurryAdNative>) nativeAd;
@end
