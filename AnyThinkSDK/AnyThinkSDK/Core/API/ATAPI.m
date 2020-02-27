//
//  ATAPI.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 09/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAPI.h"
#import "ATAdManager.h"
#import "ATAppSettingManager.h"
#import "ATAdManager+Internal.h"
#import "ATThreadSafeAccessor.h"
#import "Utilities.h"
#import "ATPolicyViewController.h"
#import "ATAgentEvent.h"
#import <WebKit/WebKit.h>

NSString *const kNativeADAssetsAdvertiserKey = @"advertiser";
NSString *const kNativeADAssetsMainTextKey = @"main_text";
NSString *const kNativeADAssetsMainTitleKey = @"main_title";
NSString *const kNativeADAssetsMainImageKey = @"main_image";
NSString *const kNativeADAssetsIconImageKey = @"icon_iamge";
NSString *const kNativeADAssetsCTATextKey = @"call_to_action";
NSString *const kNativeADAssetsRatingKey = @"rating";
NSString *const kNativeADAssetsContainsVideoFlag = @"native_ad_contains_video";
NSString *const kNativeADAssetsUnitIDKey = @"unit_id";
NSString *const kNativeADAssetsIconURLKey = @"icon_url";
NSString *const kNativeADAssetsImageURLKey = @"image_url";
NSString *const kNativeADAssetsSponsoredImageKey = @"sponsor_image";

NSString *const ATADShowingErrorDomain = @"com.anythink.ATAdShowingErrorDomain";

NSString *const ATADLoadingErrorDomain = @"com.anythink.ATADLoadingErrorDomain";
NSInteger const ATADLoadingErrorCodePlacementStrategyInvalidResponse = 1001;
NSInteger const ATADLoadingErrorCdoePlacementStragetyNetworkError = 1002;
NSInteger const ATADLoadingErrorCodeADOfferLoadingFailed = 1003;
NSInteger const ATADLoadingErrorCodePlacementStrategyNotFound = 1004;
NSInteger const ATADLoadingErrorCodeADOfferNotFound = 1005;
NSInteger const ATADLoadingErrorCodeShowIntervalWithinPlacementPacing = 1006;
NSInteger const ATADLoadingErrorCodeShowTimesExceedsHourCap = 1007;
NSInteger const ATADLoadingErrorCodeShowTimesExceedsDayCap = 1008;
NSInteger const ATADLoadingErrorCodeAdapterClassNotFound = 1009;
NSInteger const ATADLoadingErrorCodeADOfferLoadingTimeout = 10010;
NSInteger const ATADLoadingErrorCodeSDKNotInitalizedProperly = 1011;
NSInteger const ATADLoadingErrorCodeDataConsentForbidden = 1012;
NSInteger const ATADLoadingErrorCodeThirdPartySDKNotImportedProperly = 1013;
NSInteger const ATADLoadingErrorCodeInvalidInputEncountered = 1014;
NSInteger const ATADLoadingErrorCodePlacementAdDeliverySwitchOff = 1015;

NSString *const ATSDKInitErrorDomain = @"com.anythink.AnyThinkSDKInitErrorDomain";
NSInteger const ATSDKInitErrorCodeDataConsentNotSet = 2001;
NSInteger const ATSDKInitErrorCodeDataConsentForbidden = 2002;
static NSString *const kInitErrorDescriptionDataConsentNotSet = @"SDK initialization failed.";
static NSString *const kInitErrorReasonDataConsentNotSet = @"The user's now within data protected area and the data consent has not been set. Please set data consent before you init the SDK.";
static NSString *const kInitErrorDescriptionDataConsentForbidden = @"SDK initialization failed.";
static NSString *const kInitErrorReasonDataConsentForbidden = @"The user's denied personal data access. Please inform he/she to reset the data consent and allow personal data access.";

NSString *const kATADLoadingStartLoadNotification = @"ATADLoadingStartLoadNotification";
NSString *const kATADLoadingOfferSuccessfullyLoadedNotification = @"ADLoadingOfferSuccessfullyLoadedNotification";
NSString *const kATADLoadingFailedToLoadNotification = @"ATADLoadingFailedToLoadNotification";
NSString *const kATADLoadingNotificationUserInfoRequestIDKey = @"request_id";
NSString *const kATADLoadingNotificationUserInfoPlacementKey = @"placement_model";
NSString *const kATADLoadingNotificationUserInfoUnitGroupKey = @"unit_group_model";
NSString *const kATADLoadingNotificationUserInfoErrorKey = @"error";
NSString *const kATADLoadingNotificationUserInfoExtraKey = @"extra";

NSString *const kNetworkNameFacebook = @"facebook";
NSString *const kNetworkNameInmobi = @"inmobi";
NSString *const kNetworkNameAdmob = @"admob";
NSString *const kNetworkNameFlurry = @"flurry";
NSString *const kNetworkNameMintegral = @"mintegral";
NSString *const kNetworkNameApplovin = @"applovin";
NSString *const kNetworkNameGDT = @"gdt";
NSString *const kNetworkNameMopub = @"mopub";
NSString *const kNetworkNameTapjoy = @"tapjoy";
NSString *const kNetworkNameChartboost = @"chartboost";
NSString *const kNetworkNameIronSource = @"ironsource";
NSString *const kNetworkNameVungle = @"vungle";
NSString *const kNetworkNameAdColony = @"adcolony";
NSString *const kNetworkNameUnityAds = @"unityads";
NSString *const kNetworkNameTT = @"tt";
NSString *const kNetworkNameOneway = @"oneway";
NSString *const kNetworkNameAppnext = @"appnext";
NSString *const kNetworkNameYeahmobi = @"yeahmobi";
NSString *const kNetworkNameBaidu = @"baidu";
NSString *const kNetworkNameMobPower = @"mobpower";
NSString *const kNetworkNameNend = @"nend";
NSString *const kNetworkNameMaio = @"maio";
NSString *const kNetworkNameSigmob = @"sigmob";
NSString *const kNetworkNameMyOffer = @"myoffer";
NSString *const kNetworkNameKS = @"KS";
NSString *const kNetworkNameOgury = @"Ogury";

NSString *const kInmobiGDPRStringKey = @"gdpr";
NSString *const kInmobiConsentStringKey = @"consent_string";

NSString *const kAdmobConsentStatusKey = @"consent_status";
NSString *const kAdmobUnderAgeKey = @"under_age";

NSString *const kApplovinConscentStatusKey = @"consent_status";
NSString *const kApplovinUnderAgeKey = @"under_age";

NSString *const kTapjoyConsentValueKey = @"consent_value";
NSString *const kTapjoyGDPRSubjectionKey = @"gdpr_subjection";

NSString *const kFlurryConsentGDPRScopeFlagKey = @"scope_flag";
NSString *const kFlurryConsentConsentStringKey = @"consent_string";

NSString *const kAdColonyGDPRConsiderationFlagKey = @"gdpr_consideration_flag";
NSString *const kAdColonyGDPRConsentStringKey = @"consent_string";

NSString *const kYeahmobiGDPRConsentValueKey = @"consent_value";
NSString *const kYeahmobiGDPRConsentTypeKey = @"consent_type";

static NSString *kUserDefaultConsentInfoKey = @"com.anythink.dataConsentInfo";
static NSString *kUserDefaultConsentInfoConsentKey = @"consent";

@interface ATAPI()
@property(atomic) BOOL logEnabled_impl;
@property(atomic) BOOL MPisInit;

@property(nonatomic, readonly) ATThreadSafeAccessor *networkVersionsAccessor;
@property(nonatomic, readonly) NSMutableDictionary *networkVersionsInfo;

@property(nonatomic, readonly) ATThreadSafeAccessor *dataConsentSettingAccessor;
@property(nonatomic, readwrite) ATDataConsentSet dataConsentSet;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*> *consentStrings_impl;

@property(nonatomic, readonly) ATThreadSafeAccessor *networkInitFlagsAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSNumber*> *networkInitFlags;

@property(nonatomic, readonly) NSString *psID_impl;
@property(nonatomic, readonly) ATSerialThreadSafeAccessor *userAgentAccessor;
@property(nonatomic) NSString *userAgent_impl;
@property(nonatomic) WKWebView *webView;
@end

@implementation ATAPI
#pragma mark - init
+(instancetype)sharedInstance {
    static ATAPI *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ATAPI alloc] init];
    });
    return sharedInstance;
}

+(NSDictionary<NSNumber*, NSString*>*)networkNameMap {
    return @{@1:kNetworkNameFacebook, @2:kNetworkNameAdmob, @3:kNetworkNameInmobi, @4:kNetworkNameFlurry, @5:kNetworkNameApplovin, @6:kNetworkNameMintegral, @7:kNetworkNameMopub, @8:kNetworkNameGDT, @9:kNetworkNameChartboost, @10:kNetworkNameTapjoy, @11:kNetworkNameIronSource, @12:kNetworkNameUnityAds, @13:kNetworkNameVungle, @14:kNetworkNameAdColony, @15:kNetworkNameTT, @17:kNetworkNameOneway, @18:kNetworkNameMobPower, @20:kNetworkNameYeahmobi, @21:kNetworkNameAppnext, @22:kNetworkNameBaidu, @23:kNetworkNameNend, @24:kNetworkNameMaio,@28:kNetworkNameKS, @29:kNetworkNameSigmob,@35:kNetworkNameMyOffer, @36:kNetworkNameOgury};
}

+(void) integrationChecking {
    NSString *dependenciesKey = @"dependencies";
    NSString *frameworksKey = @"third_party_sdk_packages";
    NSString *resourceBundleKey = @"bundle";
    NSDictionary<NSString*, NSDictionary*> *integrityDict = @{@"Facebook":@{dependenciesKey:@{@"AnyThinkFacebookNativeAdapter":@[@"FBNativeAd", @"FBAdBidRequest", @"FBAdBidResponse"],
                                                           @"AnyThinkFacebookRewardedVideoAdapter":@[@"FBRewardedVideoAd", @"FBAdBidRequest", @"FBAdBidResponse"],
                                                           @"AnyThinkFacebookBannerAdapter":@[@"FBAdView", @"FBAdBidRequest", @"FBAdBidResponse"],
                                                           @"AnyThinkFacebookInterstitialAdapter":@[@"FBInterstitialAd", @"FBAdBidRequest", @"FBAdBidResponse"]
    },
                                         frameworksKey:@[@"FBAudienceNetwork.framework", @"FBAudienceNetworkBiddingKit.framework", @"FBSDKCoreKit.framework"]
                                         
    },
                                                              @"Admob":@{dependenciesKey:@{@"AnyThinkAdmobNativeAdapter":@[@"PACConsentInformation", @"GADAdLoader"],
                                                                                                                     @"AnyThinkAdmobRewardedVideoAdapter":@[@"PACConsentInformation", @"GADRequest", @"GADRewardedAd"],
                                                                                                                     @"AnyThinkAdmobBannerAdapter":@[@"PACConsentInformation", @"GADRequest", @"GADBannerView"],
                                                                                                                     @"AnyThinkAdmobInterstitialAdapter":@[@"PACConsentInformation", @"GADInterstitial", @"GADRequest"]
                                                              },
                                                                                                   frameworksKey:@[@"PersonalizedAdConsent.framework", @"GoogleMobileAds.framework"]
                                                                                                   
                                                              },
                                                              @"Inmobi":@{dependenciesKey:@{@"AnyThinkInmobiNativeAdapter":@[@"IMNative"],
                                                                                                                     @"AnyThinkInmobiRewardedVideoAdapter":@[@"IMNative"],
                                                                                                                     @"AnyThinkInmobiBannerAdapter":@[@"IMBanner"],
                                                                                                                     @"AnyThinkInmobiInterstitialAdapter":@[@"IMInterstitial"]
                                                              },
                                                                                                   frameworksKey:@[@"InMobiSDK.framework"]
                                                                                                   
                                                              },
                                                              @"Flurry":@{dependenciesKey:@{@"AnyThinkFlurryNativeAdapter":@[@"FlurryAdNative"],
                                                                                                                     @"AnyThinkFlurryRewardedVideoAdapter":@[@"FlurryAdInterstitial"],
                                                                                                                     @"AnyThinkFlurryBannerAdapter":@[@"FlurryAdBanner"],
                                                                                                                     @"AnyThinkFlurryInterstitialAdapter":@[@"FlurryAdInterstitial"]
                                                              },
                                                                                                   frameworksKey:@[@"libFlurry_9.0.0.a"]
                                                                                                   
                                                              },
                                                              @"Applovin":@{dependenciesKey:@{@"AnyThinkApplovinNativeAdapter":@[@"ALSdk"],
                                                                                                                     @"AnyThinkApplovinRewardedVideoAdapter":@[@"ALIncentivizedInterstitialAd"],
                                                                                                                     @"AnyThinkApplovinBannerAdapter":@[@"ALAdView", @"ALSdk", @"ALAdSize"],
                                                                                                                     @"AnyThinkApplovinInterstitialAdapter":@[@"ALSdk", @"ALAdService", @"ALInterstitialAd"]
                                                              },
                                                                                                   frameworksKey:@[@"AppLovinSDK.framework"],
                                                                            resourceBundleKey:@"AppLovinSDKResources"
                                                                                                   
                                                              },
                                                              @"Mopub":@{dependenciesKey:@{@"AnyThinkMopubNativeAdapter":@[@"MPNativeAdRequest", @"ATMopubRenderer", @"MPMoPubConfiguration"],
                                                                                                                     @"AnyThinkMopubRewardedVideoAdapter":@[@"MPRewardedVideo"],
                                                                                                                     @"AnyThinkMopubBannerAdapter":@[@"MPAdView"],
                                                                                                                     @"AnyThinkMopubInterstitialAdapter":@[@"MPInterstitialAdController"]
                                                              },
                                                                                                   frameworksKey:@[@"MoPubSDKFramework.framework"]},
                                                              @"GDT":@{dependenciesKey:@{@"AnyThinkGDTNativeAdapter":@[@"GDTNativeExpressAd", @"GDTNativeAd", @"GDTUnifiedNativeAd"],
                                                                                                                     @"AnyThinkGDTRewardedVideoAdapter":@[@"GDTRewardVideoAd"],
                                                                                                                     @"AnyThinkGDTBannerAdapter":@[@"GDTMobBannerView", @"GDTUnifiedBannerView"],
                                                                                                                     @"AnyThinkGDTInterstitialAdapter":@[@"GDTMobInterstitial", @"GDTUnifiedInterstitialAd"],
                                                                                         @"AnyThinkGDTSplashAdapter":@[@"GDTSplashAd"]
                                                              },
                                                                                                   frameworksKey:@[@"libGDTMobSDK.a"]},
                                                              @"Tapjoy":@{dependenciesKey:@{@"AnyThinkTapjoyRewardedVideoAdapter":@[@"Tapjoy"],
                                                                                                                     @"AnyThinkTapjoyInterstitialAdapter":@[@"Tapjoy"]
                                                              },
                                                                                                   frameworksKey:@[@"Tapjoy.embededframework"]
                                                              },
                                                              @"IronSource":@{dependenciesKey:@{@"AnyThinkIronSourceRewardedVideoAdapter":@[@"IronSource"],
                                                                                                                     @"AnyThinkIronSourceInterstitialAdapter":@[@"IronSource"]
                                                              },
                                                                                                   frameworksKey:@[@"IronSource.framework"]
                                                              },
                                                              @"UnityAds":@{dependenciesKey:@{@"AnyThinkUnityAdsRewardedVideoAdapter":@[@"UnityMonetization"],
                                                                                                                     @"AnyThinkUnityAdsInterstitialAdapter":@[@"UnityMonetization"]
                                                              },
                                                                                                   frameworksKey:@[@"UnityAds.framework"]
                                                              },
                                                              @"Vungle":@{dependenciesKey:@{@"AnyThinkVungleRewardedVideoAdapter":@[@"VungleSDK"],
                                                                                                                     @"AnyThinkVungleInterstitialAdapter":@[@"VungleSDK"]
                                                              },
                                                                                                   frameworksKey:@[@"VungleSDK.framework"]
                                                              },
                                                              @"AdColony":@{dependenciesKey:@{@"AnyThinkAdColonyRewardedVideoAdapter":@[@"AdColony"],
                                                                                                                     @"AnyThinkAdColonyInterstitialAdapter":@[@"AdColony"]
                                                              },
                                                                                                   frameworksKey:@[@"AdColony.framework"]
                                                              },
                                                              @"TikTok":@{dependenciesKey:@{@"AnyThinkTTNativeAdapter":@[@"BUNativeAdsManager", @"BUAdSlot", @"BUNativeAd"],
                                                                                                                     @"AnyThinkTTRewardedVideoAdapter":@[@"BURewardedVideoModel", @"BURewardedVideoAd"],
                                                                                                                     @"AnyThinkTTBannerAdapter":@[@"BUBannerAdView", @"BUSize", @"BUNativeExpressBannerView"],
                                                                                                                     @"AnyThinkTTInterstitialAdapter":@[@"BUFullscreenVideoAd", @"BUInterstitialAd", @"BUNativeExpressInterstitialAd"],
                                                                                                                     @"AnyThinkTTSplashAdapter":@[@"BUSplashAdView"]
                                                              },
                                                                                                   frameworksKey:@[@"BUAdSDK.framework"],
                                                                          resourceBundleKey:@"BUAdSDK"
                                                              },
                                                              @"Oneway":@{dependenciesKey:@{@"AnyThinkOnewayRewardedVideoAdapter":@[@"OWRewardedAd"],
                                                                                                                     @"AnyThinkOnewayInterstitialAdapter":@[@"OWInterstitialAd"]
                                                              },
                                                                                                   frameworksKey:@[@"OnewaySDK.a"]
                                                              },
                                                              @"Yeahmobi":@{dependenciesKey:@{@"AnyThinkYeahmobiNativeAdapter":@[@"CTService"],
                                                                                                                     @"AnyThinkYeahmobiRewardedVideoAdapter":@[@"CTService"],
                                                                                                                     @"AnyThinkYeahmobiBannerAdapter":@[@"CTService"],
                                                                                                                     @"AnyThinkYeahmobiInterstitialAdapter":@[@"CTService"]
                                                              },
                                                                                                   frameworksKey:@[@"CTSDK.framework"]
                                                              },
                                                              @"Appnext":@{dependenciesKey:@{@"AnyThinkAppnextNativeAdapter":@[@"AppnextNativeAdsRequest", @"AppnextNativeAdsSDKApi"],
                                                                                                                     @"AnyThinkAppnextRewardedVideoAdapter":@[@"AppnextRewardedVideoAd"],
                                                                                                                     @"AnyThinkAppnextBannerAdapter":@[@"BannerRequest", @"AppnextBannerView"],
                                                                                                                     @"AnyThinkAppnextInterstitialAdapter":@[@"AppnextInterstitialAd"]
                                                              },
                                                                                                   frameworksKey:@[@"libAppnextNativeAdsSDK.a", @"libAppnextSDKCore.a", @"libAppnextLib.a"]
                                                              },
                                                              @"Baidu":@{dependenciesKey:@{@"AnyThinkBaiduNativeAdapter":@[@"BaiduMobAdNativeAdView", @"BaiduMobAdNative"],
                                                                                                                     @"AnyThinkBaiduRewardedVideoAdapter":@[@"BaiduMobAdRewardVideo"],
                                                                                                                     @"AnyThinkBaiduBannerAdapter":@[@"BaiduMobAdView"],
                                                                                                                     @"AnyThinkBaiduInterstitialAdapter":@[@"BaiduMobAdInterstitial"],
                                                                                           @"AnyThinkBaiduSplashAdapter":@[@"BaiduMobAdSplash"]
                                                              },
                                                                                                   frameworksKey:@[@"BaiduMobAdSDK.framework"],
                                                                         resourceBundleKey:@"baidumobadsdk"
                                                              },
                                                              @"Nend":@{dependenciesKey:@{@"AnyThinkNendNativeAdapter":@[@"NADNative", @"NADNativeClient", @"NADNativeVideoLoader", @"NADNativeVideo"],
                                                                                                                     @"AnyThinkNendRewardedVideoAdapter":@[@"NADRewardedVideo"],
                                                                                                                     @"AnyThinkNendBannerAdapter":@[@"NADView"],
                                                                                                                     @"AnyThinkNendInterstitialAdapter":@[@"NADInterstitial", @"NADInterstitialVideo", @"NADFullBoard", @"NADFullBoardLoader"]
                                                              },
                                                                                                   frameworksKey:@[@"Nend.embededframework"]
                                                              },
                                                              @"Maio":@{dependenciesKey:@{@"AnyThinkMaioRewardedVideoAdapter":@[@"Maio"],
                                                                                                                     @"AnyThinkMaioInterstitialAdapter":@[@"Maio"]
                                                              },
                                                                                                   frameworksKey:@[@"Maio.framework"]
                                                              },
                                                              @"KS":@{dependenciesKey:@{@"AnyThinkKSNativeAdapter":@[@"KSNativeAd", @"KSFeedAd"],
                                                                                        @"AnyThinkKSRewardedVideoAdapter":@[@"KSRewardedVideoAd"],
                                                                                                                     @"AnyThinkKSInterstitialAdapter":@[@"KSFullscreenVideoAd"]
                                                              },
                                                                                                   frameworksKey:@[@"KSAdSDK.framework"],
                                                                      resourceBundleKey:@"KSAdSDK"
                                                              },
                                                              @"Sigmob":@{dependenciesKey:@{@"AnyThinkSigmobRewardedVideoAdapter":@[@"WindAdRequest", @"WindRewardedVideoAd"],
                                                                                                                     @"AnyThinkSigmobInterstitialAdapter":@[@"WindFullscreenVideoAd", @"WindAdRequest"],
                                                                                                                     @"AnyThinkSigmobSplashAdapter":@[@"WindSplashAd"]
                                                              },
                                                                                                   frameworksKey:@[@"WindSDK.framework"],
                                                                          resourceBundleKey:@"Sigmob"
                                                              },
                                                              @"Ogury":@{dependenciesKey:@{@"AnyThinkOguryRewardedVideoAdapter":@[@"OguryAdsOptinVideo"],
                                                                                                                     @"AnyThinkOguryInterstitialAdapter":@[@"OguryAdsInterstitial"]
                                                              },
                                                                                                   frameworksKey:@[@"OMSDK_Oguryco.framework", @"OguryAds.framework", @"OguryConsentManager.framework"]
                                                              },
                                                              @"MyOffer":@{dependenciesKey:@{@"AnyThinkMyOfferRewardedVideoAdapter":@[@"ATMyOfferOfferManager"],
                                                                                                                     @"AnyThinkMyOfferInterstitialAdapter":@[@"ATMyOfferOfferManager"]
                                                              },
                                                                                                   frameworksKey:@[@"AnyThinkMyOffer.framework"]
                                                              }
    };
    
    NSMutableArray<NSDictionary*>* results = [NSMutableArray<NSDictionary*> array];
    [integrityDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableDictionary * result = [NSMutableDictionary dictionaryWithObject:key forKey:@"NetworkName"];
        NSDictionary *dependencies = obj[dependenciesKey];
        NSArray<NSString*>* frameworks = obj[frameworksKey];
        NSMutableArray<NSDictionary*>* adapterResults = [NSMutableArray<NSDictionary*> array];
        __block BOOL networkStatus = YES;
        [dependencies enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull adapter, NSArray<NSString*>*  _Nonnull classes, BOOL * _Nonnull stop) {
            NSString *adapterClassName = [adapter stringByReplacingOccurrencesOfString:@"AnyThink" withString:@"AT"];
            if (NSClassFromString(adapterClassName) != nil) {
                NSMutableArray<NSString*>* missingClasses = [NSMutableArray<NSString*> array];
                [classes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { if (NSClassFromString(obj) == nil) { [missingClasses addObject:obj]; } }];
                
                NSMutableDictionary *adapterResult = [NSMutableDictionary dictionaryWithObject:[adapter stringByAppendingString:@".framework"] forKey:@"Adapter"];
                if ([missingClasses count] > 0) {
                    adapterResult[@"Status"] = @"Fail";
                    adapterResult[@"Reason"] = [NSString stringWithFormat:@"One or more classes missing: %@", [missingClasses componentsJoinedByString:@" "]];
                    adapterResult[@"Suggestion"] = [NSString stringWithFormat:@"Please import frameworks: %@", [frameworks componentsJoinedByString:@" "]];
                    if (networkStatus) { networkStatus = NO; }
                } else {
                    adapterResult[@"Status"] = @"Success";
                }
                
                [adapterResults addObject:adapterResult];
            }
        }];
        
        if ([adapterResults count] > 0) {
            result[@"Adapters"] = adapterResults;
            
            if (networkStatus) {
                NSString *bundle = obj[resourceBundleKey];
                if (bundle != nil) {
                    if ([[NSBundle mainBundle] pathForResource:bundle ofType:@"bundle"] != nil) {
                        networkStatus = YES;
                    } else {
                        networkStatus = NO;
                        result[@"Reason"] = [NSString stringWithFormat:@"%@.bundle not being properly imported", bundle];
                        result[@"Suggestion"] = [NSString stringWithFormat:@"Please import %@.bundle", bundle];
                    }
                }
            }
            
            result[@"Status"] = networkStatus ? @"Success" : @"Fail";
            [results addObject:result];
        }
    }];
    
    NSString *classesKey = @"classes";
    NSDictionary<NSString*, NSDictionary<NSString*, NSArray<NSString*>*>*> *dependencies = @{@"AnyThinkMintegralNativeAdapter":@{classesKey:@[@"MTGNativeAdManager", @"MTGBidNativeAdManager", @"MTGBiddingRequest", @"MTGBiddingResponse", @"MTGBiddingBannerRequestParameter"], frameworksKey:@[@"MTGSDK.framework", @"MTGSDKBidding.framework"]},
                                                           @"AnyThinkMintegralRewardedVideoAdapter":@{classesKey:@[@"MTGBidRewardAdManager", @"MTGRewardAdManager", @"MTGBiddingRequest", @"MTGBiddingResponse", @"MTGBiddingBannerRequestParameter"], frameworksKey:@[@"MTGSDK.framework", @"MTGSDKReward.framework", @"MTGSDKBidding.framework"]},
                                                           @"AnyThinkMintegralBannerAdapter":@{classesKey:@[@"MTGSDK", @"MTGBannerAdView", @"MTGBiddingRequest", @"MTGBiddingResponse", @"MTGBiddingBannerRequestParameter"], frameworksKey:@[@"MTGSDK.framework", @"MTGSDKBanner.framework", @"MTGSDKBidding.framework"]},
                                                           @"AnyThinkMintegralInterstitialAdapter":@{classesKey:@[@"MTGInterstitialVideoAdManager", @"MTGInterstitialAdManager", @"MTGBiddingRequest", @"MTGBiddingResponse", @"MTGBiddingBannerRequestParameter"], frameworksKey:@[@"MTGSDK.framework", @"MTGSDKInterstitialVideo.framework", @"MTGSDKInterstitial.framework", @"MTGSDKBidding.framework"]}
    };
    
    __block BOOL networkStatus = YES;
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObject:@"Mintegral" forKey:@"NetworkName"];
    NSMutableArray<NSDictionary*>* adapterResults = [NSMutableArray<NSDictionary*> array];
    [dependencies enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull adapter, NSDictionary<NSString *,NSArray<NSString *> *> * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *adapterClassName = [adapter stringByReplacingOccurrencesOfString:@"AnyThink" withString:@"AT"];
        if (NSClassFromString(adapterClassName) != nil) {
            NSMutableDictionary *adapterResult = [NSMutableDictionary dictionaryWithObject:[adapter stringByAppendingString:@".framework"] forKey:@"Adapter"];
            NSArray<NSString*>* classes = obj[classesKey];
            NSArray<NSString*>* frameworks = obj[frameworksKey];
            __block BOOL adapterStatus = YES;
            NSMutableArray<NSString*>* missingClasses = [NSMutableArray<NSString*> array];
            [classes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (NSClassFromString(obj) == nil) {
                    if (adapterStatus) { adapterStatus = NO; }
                    [missingClasses addObject:obj];
                }
            }];
            if (adapterStatus) {
                adapterResult[@"Status"] = @"Success";
            } else {
                if (networkStatus) { networkStatus = NO; }
                adapterResult[@"Status"] = @"Fail";
                adapterResult[@"Reason"] = [NSString stringWithFormat:@"One or more classes missing: %@", [missingClasses componentsJoinedByString:@" "]];
                adapterResult[@"Suggestion"] = [NSString stringWithFormat:@"Please import frameworks: %@", [frameworks componentsJoinedByString:@" "]];
            }
            [adapterResults addObject:adapterResult];
        }
    }];
    if ([adapterResults count]) {
        result[@"Status"] = networkStatus ? @"Success" : @"Fail";
        result[@"Adapters"] = adapterResults;
        [results addObject:result];
    }
    [ATLogger logMessage:[NSString stringWithFormat:@"\n**************************** Checking Result ****************************\n%@\n**************************** Checking Result ****************************\n", results] type:ATLogTypeExternal];
}

static NSString *const UAInfoKey = @"user_agent_info_key";
static NSString *const UAInfoSystemVersionKey = @"sys_ver";
static NSString *const UAInfoUAKey = @"ua";
-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _networkVersionsAccessor = [ATThreadSafeAccessor new];
        _networkVersionsInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", kNetworkNameFacebook, @"", kNetworkNameInmobi, @"", kNetworkNameAdmob, @"", kNetworkNameFlurry, @"", kNetworkNameMintegral, @"", kNetworkNameApplovin, @"", kNetworkNameMopub, @"", kNetworkNameGDT, @"", kNetworkNameTapjoy, @"", kNetworkNameChartboost, @"", kNetworkNameIronSource, @"", kNetworkNameVungle, @"", kNetworkNameAdColony, @"", kNetworkNameUnityAds, @"", kNetworkNameTT, @"", kNetworkNameOneway, @"", kNetworkNameMobPower, @"", kNetworkNameAppnext, @"", kNetworkNameYeahmobi, @"", kNetworkNameBaidu, @"", kNetworkNameNend, @"", kNetworkNameMaio, @"", kNetworkNameKS,@"", kNetworkNameSigmob, @"",kNetworkNameOgury, @"",kNetworkNameMyOffer, nil];
        _dataConsentSet = [self retrieveDataConsentSet];
        _dataConsentSettingAccessor = [ATThreadSafeAccessor new];
        _networkInitFlags = [NSMutableDictionary<NSString*, NSNumber*> dictionary];
        _networkInitFlagsAccessor = [ATThreadSafeAccessor new];
        
        _userAgentAccessor = [ATSerialThreadSafeAccessor new];
        _userAgent_impl = [[NSUserDefaults standardUserDefaults] objectForKey:UAInfoKey][UAInfoUAKey];
        _userAgent_impl = _userAgent_impl != nil ? _userAgent_impl : @"";
    }
    return self;
}

-(NSString*) userAgent {
    return [_userAgentAccessor readWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *system = [UIDevice currentDevice].systemVersion;
            NSDictionary *uaInfo = [[NSUserDefaults standardUserDefaults] objectForKey:UAInfoKey];
            if (![system isEqualToString:uaInfo[UAInfoSystemVersionKey]]) {
                WKWebView *webView = [[WKWebView alloc] initWithFrame:UIScreen.mainScreen.bounds];
                [webView loadHTMLString:@"<html></html>" baseURL:nil];
                
                [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
                    if ([userAgent isKindOfClass:[NSString class]]) {
                        [_userAgentAccessor writeWithBlock:^{
                            _userAgent_impl = userAgent;
                            [[NSUserDefaults standardUserDefaults] setObject:@{UAInfoSystemVersionKey:system, UAInfoUAKey:userAgent} forKey:UAInfoKey];
                        }];
                    }
                }];
                _webView = webView;
            }
        });
        return _userAgent_impl;
    }];
}

static NSString *const psIDInfoDateKey = @"date";
static NSString *const psIDInfoIDKey = @"id";
-(void) loadPSID {
    void(^GenPSID)(NSDate *date) = ^void(NSDate *date){
        uint32_t random = 0;
        NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000.0f;
        BOOL randomIncluded = NO;
        if ([ATAppSettingManager sharedManager].ATID != nil) {
            _psID_impl = [NSString stringWithFormat:@"%@%@%@", [ATAppSettingManager sharedManager].ATID, _appID, @(timestamp)].md5;
        } else {
            randomIncluded = YES;
            random = arc4random_uniform(10000000);
            _psID_impl = [NSString stringWithFormat:@"%@%@%@%@%@", [Utilities advertisingIdentifier], [Utilities idfv], _appID, @(random), @(timestamp)].md5;
        }
        
        NSDictionary *psIDInfo = @{psIDInfoDateKey:date, psIDInfoIDKey:_psID_impl};
        [psIDInfo writeToFile:[ATAPI psIDStoragePath] atomically:YES];
        NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@1, kAgentEventExtraInfoGeneratedIDTypeKey, @((NSInteger)timestamp), kAgentEventExtraInfoIDGenerationTimestampKey, _psID_impl, kAgentEventExtraInfoPSIDKey, nil];
        if (randomIncluded) { extraInfo[kAgentEventExtraInfoIDGenerationRandomNumberKey] = @(random); }
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyPSIDSessionIDGeneration placementID:nil unitGroupModel:nil extraInfo:extraInfo];
    };
    
    NSDictionary *psIDInfo = nil;
    if ([NSDictionary respondsToSelector:@selector(dictionaryWithContentsOfURL:error:)]) {
        psIDInfo = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:[ATAPI psIDStoragePath]] error:nil];
    } else {
        psIDInfo = [NSDictionary dictionaryWithContentsOfFile:[ATAPI psIDStoragePath]];
    }
    
    NSDate *date = [NSDate date];
    if ([psIDInfo count] == 0) {
        GenPSID(date);
    } else {
        NSDate *lastDate = psIDInfo[psIDInfoDateKey];
        _psID_impl = psIDInfo[psIDInfoIDKey];
        if ([date timeIntervalSinceDate:lastDate] >= [[ATAppSettingManager sharedManager] psIDInterval]) {
            GenPSID(date);
        }
    }
}

-(NSString*)psID {
    return _psID_impl;
}

+(NSString*)psIDStoragePath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.psInfo"];
}

+(void) setLogEnabled:(BOOL)logEnabled {
    [ATAPI sharedInstance].logEnabled_impl = logEnabled;
}

+(BOOL)logEnabled {
    return [ATAPI sharedInstance].logEnabled_impl;
}

+(BOOL) getMPisInit {
    return [ATAPI sharedInstance].MPisInit;
}

+(void) setMPisInit:(BOOL)MPisInit{
    [ATAPI sharedInstance].MPisInit = MPisInit;
}

-(ATDataConsentSet) retrieveDataConsentSet {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultConsentInfoKey][kUserDefaultConsentInfoConsentKey] integerValue];
}

-(void) saveDataConsentSet:(ATDataConsentSet)consentSet {
    [[NSUserDefaults standardUserDefaults] setObject:@{kUserDefaultConsentInfoConsentKey:@(consentSet)} forKey:kUserDefaultConsentInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 
-(BOOL) startWithAppID:(NSString*)appID appKey:(NSString*)appKey error:(NSError**)error {
    [ATLogger logMessage:@"startWithAppID" type:ATLogTypeInternal];
    _appID = appID;
    _appKey = appKey;
    void(^initSDK)(void) = ^{
        if (_psID_impl == nil) { [self loadPSID]; }
        [self applyAppSetting];
    };
    BOOL initSucceeded = YES;
    if (self.dataConsentSet == ATDataConsentSetUnknown) {
        if ([[ATAppSettingManager sharedManager] inDataProtectedArea]) {
            initSucceeded = NO;
            if (error != nil) {
                *error = [NSError errorWithDomain:ATSDKInitErrorDomain code:ATSDKInitErrorCodeDataConsentNotSet userInfo:@{NSLocalizedDescriptionKey:kInitErrorDescriptionDataConsentNotSet, NSLocalizedFailureReasonErrorKey:kInitErrorReasonDataConsentNotSet}];
            }
        } else {
            initSucceeded = YES;
            initSDK();
        }
    } else {
        initSucceeded = YES;
        initSDK();
    }
    
    return initSucceeded;
}

-(void) applyAppSetting {
    if ([[ATAppSettingManager sharedManager] currentSettingExpired]) {
        [[ATAppSettingManager sharedManager] requestAppSettingCompletion:^(NSDictionary *setting, NSError *error) {
            if (error == nil) {
                //Use the new setting
                [[ATAgentEvent sharedAgent] uploadIfNeed];
            } else {
                if ([[ATAppSettingManager sharedManager].currentSetting count] > 0) {
                    //Use the current setting
                    [[ATAgentEvent sharedAgent] uploadIfNeed];
                } else {
                    //User the default setting
                    [[ATAgentEvent sharedAgent] uploadIfNeed];
                }
            }
        }];
    } else {
        //Use the current setting
        [[ATAgentEvent sharedAgent] uploadIfNeed];
    }
}

-(void) setCustomData:(NSDictionary*)customData {
    if ([customData isKindOfClass:[NSDictionary class]]) { _customData = customData; }
}

+(NSCharacterSet*) channelCharacterSet {
    NSMutableCharacterSet *set = [NSMutableCharacterSet decimalDigitCharacterSet];
    [set formUnionWithCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    [set formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    [set addCharactersInString:@"_"];
    return set;
}

-(void) setChannel:(NSString*)channel {
    if ([channel isKindOfClass:[NSString class]] && [channel length] <= 32 && [channel length] > 0 && [channel rangeOfCharacterFromSet:[[ATAPI channelCharacterSet] invertedSet]].location == NSNotFound) {
        _channel = channel;
    } else {
        [ATLogger logError:[NSString stringWithFormat:@"The passed channel is not valid:%@; it should be of length between [1, 32], containing only '_', [0-9], [a-z], [A-Z]", channel] type:ATLogTypeExternal];
    }
}

-(void) setSubchannel:(NSString *)subchannel {
    if ([subchannel isKindOfClass:[NSString class]] && [subchannel length] <= 32 && [subchannel length] > 0 && [subchannel rangeOfCharacterFromSet:[[ATAPI channelCharacterSet] invertedSet]].location == NSNotFound) {
        _subchannel = subchannel;
    } else {
        [ATLogger logError:[NSString stringWithFormat:@"The passed channel is not valid:%@; it should be of length between [1, 32], containing only '_', [0-9], [a-z], [A-Z]", subchannel] type:ATLogTypeExternal];
    }
}

-(NSString*)version {
    return @"UA_5.5.0";
}

-(void) setDataConsentSet:(ATDataConsentSet)dataConsentSet consentString:(NSDictionary<NSString *,NSString *> *)consentString {
    if (dataConsentSet == ATDataConsentSetUnknown) {
        [ATLogger logError:@"You can't set ATDataConsentSetUnknown as a dataConsentSet, use ATDataConsentSetPersonalized or ATDataConsentSetNonpersonalized instead"  type:ATLogTypeExternal];
    } else {
        [_dataConsentSettingAccessor writeWithBlock:^{
            _dataConsentSet = dataConsentSet;
            _consentStrings_impl = consentString;
            [self saveDataConsentSet:_dataConsentSet];
        }];
    }
}

-(ATDataConsentSet) dataConsentSet {
    ATDataConsentSet consentSet = [[_dataConsentSettingAccessor readWithBlock:^id{
        return @(_dataConsentSet);
    }] integerValue];
    return consentSet;
}

-(NSDictionary<NSString*, NSString*>*)consentStrings {
    return [_dataConsentSettingAccessor readWithBlock:^id{ return _consentStrings_impl; }];
}

-(void) presentDataConsentDialogInViewController:(UIViewController*)viewController dismissalCallback:(void (^)(void))dismissCallback {
    ATPolicyViewController *tVC = [ATPolicyViewController new];
    NSString *URLStr = [[ATAppSettingManager sharedManager].currentSetting[kATAppSettingGDPRPolicyURLKey] length] > 0 ? [ATAppSettingManager sharedManager].currentSetting[kATAppSettingGDPRPolicyURLKey] : [ATAppSettingManager sharedManager].defaultSetting[kATAppSettingGDPRPolicyURLKey];
    tVC.policyPageURL = [NSURL URLWithString:URLStr];
    tVC.dismissalCallback = dismissCallback;
    if (viewController == nil) viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    tVC.modalPresentationStyle = 0;
    [viewController presentViewController:tVC animated:YES completion:nil];
}

-(BOOL)inDataProtectionArea {
    return [[ATAppSettingManager sharedManager] inDataProtectedArea];
}

#pragma mark - internal methods
-(void) setNetworkVersions:(NSDictionary<NSString *,NSString *> *)networkVersions {
    [networkVersions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([@[kNetworkNameAdmob, kNetworkNameFacebook, kNetworkNameApplovin, kNetworkNameFlurry, kNetworkNameInmobi, kNetworkNameMintegral, kNetworkNameMopub, kNetworkNameGDT, kNetworkNameTapjoy, kNetworkNameChartboost, kNetworkNameIronSource, kNetworkNameVungle, kNetworkNameAdColony, kNetworkNameUnityAds, kNetworkNameTT, kNetworkNameOneway, kNetworkNameMobPower, kNetworkNameAppnext, kNetworkNameYeahmobi, kNetworkNameBaidu, kNetworkNameNend, kNetworkNameMaio,kNetworkNameKS,kNetworkNameOgury, kNetworkNameSigmob, kNetworkNameMyOffer] containsObject:key] && [obj isKindOfClass:[NSString class]])
            [[ATAPI sharedInstance] setVersion:obj forNetwork:key];
    }];
}

-(void) setVersion:(NSString*)version forNetwork:(NSString*)network {
//    NSLog(@"Marvin -- nw_ver:%@",version);
    [_networkVersionsAccessor writeWithBlock:^{ if (version != nil && network != nil) _networkVersionsInfo[network] = version; }];
}

-(NSDictionary*)networkVersions {
    return [_networkVersionsAccessor readWithBlock:^id{ return [NSMutableDictionary dictionaryWithDictionary:_networkVersionsInfo]; }];
}

-(NSString*)versionForNetworkFirmID:(NSInteger)networkFirmID {
    return [_networkVersionsAccessor readWithBlock:^id{ return _networkVersionsInfo[[ATAPI networkNameMap][@(networkFirmID)]]; }];
}

-(BOOL) initFlagForNetwork:(NSString*)networkName {
    return [[_networkInitFlagsAccessor readWithBlock:^{ return _networkInitFlags[networkName]; }] boolValue];
}

-(void) setInitFlagForNetwork:(NSString*)networkName {
    [_networkInitFlagsAccessor writeWithBlock:^{ _networkInitFlags[networkName] = @(YES); }];
}

-(void) setInitFlag:(NSInteger)flag forNetwork:(NSString*)networkName {
    [_networkInitFlagsAccessor writeWithBlock:^{ _networkInitFlags[networkName] = @(flag); }];
}


-(void) inspectInitFlagForNetwork:(NSString*)networkName usingBlock:(NSInteger(^)(NSInteger currentValue))block {
    __weak typeof(self) weakSelf = self;
    [_networkInitFlagsAccessor writeWithBlock:^{
        NSInteger newValue = block([weakSelf.networkInitFlags[networkName] integerValue]);
        weakSelf.networkInitFlags[networkName] = @(newValue);
    }];
}
@end
