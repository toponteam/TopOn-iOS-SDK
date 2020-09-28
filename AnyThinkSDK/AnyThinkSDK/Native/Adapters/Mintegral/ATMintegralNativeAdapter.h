//
//  ATMintegralNativeAdapter.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 18/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ATMTGUserPrivateType) {
    ATMTGUserPrivateType_ALL         = 0,
    ATMTGUserPrivateType_GeneralData = 1,
    ATMTGUserPrivateType_DeviceId    = 2,
    ATMTGUserPrivateType_Gps         = 3,
};

typedef NS_ENUM(NSInteger, ATMTGAdTemplateType) {
    AT_MTGAD_TEMPLATE_BIG_IMAGE  = 2,
    AT_MTGAD_TEMPLATE_ONLY_ICON  = 3,
};

typedef NS_ENUM(NSInteger, ATMTGAdSourceType) {
    AT_MTGAD_SOURCE_API_OFFER = 1,
    AT_MTGAD_SOURCE_MY_OFFER  = 2,
    AT_MTGAD_SOURCE_FACEBOOK  = 3,
    AT_MTGAD_SOURCE_MOBVISTA  = 4,
    AT_MTGAD_SOURCE_PUBNATIVE = 5,
    AT_MTGAD_SOURCE_ADMOB     = 6,
    AT_MTGAD_SOURCE_MYTARGET  = 7,
    AT_MTGAD_SOURCE_NATIVEX   = 8,
    AT_MTGAD_SOURCE_APPLOVIN  = 9,
};

typedef NS_ENUM(NSInteger, ATMTGAdCategory) {
    AT_MTGAD_CATEGORY_ALL  = 0,
    AT_MTGAD_CATEGORY_GAME = 1,
    AT_MTGAD_CATEGORY_APP  = 2,
};

extern NSString *const kATMintegralNativeAssetCustomEvent;
@interface ATMintegralNativeAdapter : NSObject

@end

@protocol ATMTGBiddingSDK<NSObject>
+ (NSString *)buyerUID;
@end

@protocol ATMTGSDK<NSObject>
+(instancetype) sharedInstance;
+(NSString *)sdkVersion;
- (void)setUserPrivateInfoType:(ATMTGUserPrivateType)type agree:(BOOL)agree;
- (void)setAppID:(NSString *)appID ApiKey:(NSString *)apiKey;
@property (nonatomic, assign) BOOL consentStatus;
@end

@protocol ATMTGTemplate<NSObject>
+ (instancetype )templateWithType:(ATMTGAdTemplateType)templateType adsNum:(NSUInteger)adsNum;
@end

@protocol ATMTGNativeAdManagerDelegate;
@protocol ATMTGCampaign;
@protocol ATMTGNativeAdManager<NSObject>
- (instancetype)initWithPlacementId:(NSString *)placementId
            unitID:(NSString *)unitId
     fbPlacementId:(NSString *)fbPlacementId
supportedTemplates:(NSArray *)templates
    autoCacheImage:(BOOL)autoCacheImage
        adCategory:(NSInteger)adCategory
             presentingViewController:(UIViewController *)viewController;
- (void)registerViewForInteraction:(UIView *)view
                withClickableViews:(NSArray *)clickableViews
                      withCampaign:(id<ATMTGCampaign>)campaign;
- (void)loadAds;
@property (nonatomic, weak) id <ATMTGNativeAdManagerDelegate> delegate;
@end

@protocol ATMTGNativeAdManagerDelegate <NSObject>
- (void)nativeAdsLoaded:(NSArray *)nativeAds;
- (void)nativeAdsFailedToLoadWithError:(NSError *)error;
@end

@protocol ATMTGMediaViewDelegate;
@protocol ATMTGCampaign;
@protocol ATMTGMediaView<NSObject>
- (void)setMediaSourceWithCampaign:(id<ATMTGCampaign>)campaign unitId:(NSString*)unitId;
@property (nonatomic, weak) id<ATMTGMediaViewDelegate> delegate;
@property (nonatomic,readonly,getter = isVideoContent) BOOL videoContent;
@end

@protocol ATMTGCampaign<NSObject>
- (void)loadIconUrlAsyncWithBlock:(void (^)(UIImage *image))block;
- (void)loadImageUrlAsyncWithBlock:(void (^)(UIImage *image))block;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appDesc;
@property (nonatomic, copy) NSString *adCall;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *imageUrl;
@end

@protocol ATMTGMediaViewDelegate <NSObject>
- (void)nativeAdImpressionWithType:(ATMTGAdSourceType)type mediaView:(id<ATMTGMediaView>)mediaView;
- (void)nativeAdDidClick:(id<ATMTGCampaign>)nativeAd;
@end

@protocol MTGBidNativeAdManagerDelegate;
@protocol ATMTGBidNativeAdManager<NSObject>
@property (nonatomic, weak) id <MTGBidNativeAdManagerDelegate> delegate;
@property (nonatomic, assign) BOOL showLoadingView;
@property (nonatomic, readonly) NSString *currentUnitId;
@property (nonatomic, weak) UIViewController *viewController;
- (instancetype)initWithPlacementId:(NSString *)placementId
                       unitID:(NSString *)unitId
presentingViewController:(UIViewController *)viewController;
- (instancetype)initWithUnitID:(NSString *)unitId autoCacheImage:(BOOL)autoCacheImage presentingViewController:(UIViewController *)viewController;
- (void)loadWithBidToken:(NSString *)bidToken;
- (void)registerViewForInteraction:(UIView *)view withCampaign:(id<ATMTGCampaign>)campaign;
- (void)unregisterView:(UIView *)view;
- (void)registerViewForInteraction:(UIView *)view withClickableViews:(NSArray *)clickableViews withCampaign:(id<ATMTGCampaign>)campaign;
- (void)unregisterView:(UIView *)view clickableViews:(NSArray *)clickableViews;
- (void)cleanAdsCache;
-(void)setVideoViewSize:(CGSize)size;
-(void)setVideoViewSizeWithWidth:(CGFloat)width height:(CGFloat)height;
@end

@protocol MTGBidNativeAdManagerDelegate<NSObject>
@end

@protocol ATNativeMTGAdCustomConfig<NSObject>
+(instancetype)sharedInstance;
-(void)setCustomInfo:(NSString*)customInfo type:(NSInteger)type unitId:(NSString*)unitID;
@end

@protocol ATMTGBiddingResponse<NSObject>
@property (nonatomic,strong,readonly) NSError *error;
@property (nonatomic,assign,readonly) BOOL success;
@property (nonatomic,assign,readonly) double price;
@property (nonatomic,copy,readonly) NSString *currency;
@property (nonatomic,copy,readonly) NSString *bidToken;
-(void)notifyWin;
-(void)notifyLoss:(NSInteger)reasonCode;
@end

@protocol ATMTGBiddingRequestParameter <NSObject>
@property(nonatomic,copy,readonly)NSString *unitId;
@property(nonatomic,readonly)NSNumber *basePrice;
- (instancetype)initWithPlacementId:(NSString *)placementId
   unitId:(NSString *) unitId
basePrice:(NSNumber *)basePrice;
@end
@protocol ATMTGBiddingRequest<NSObject>
+(void)getBidWithRequestParameter:(__kindof id<ATMTGBiddingRequestParameter>)requestParameter completionHandler:(void(^)(id<ATMTGBiddingResponse> bidResponse))completionHandler;
@end

@protocol MTGNativeAdvancedAdDelegate <NSObject>
@end

@protocol ATMTGNativeAdvancedAd<NSObject>
@property(nonatomic,weak) id <MTGNativeAdvancedAdDelegate> delegate;
/**
 MTGVideoPlayTypeOnlyWiFi = 1,// the video will play only if the network is WiFi
 MTGVideoPlayTypeJustTapped = 2,// the video will play when user tap the adView
 MTGVideoPlayTypeAuto = 3
 */
@property(nonatomic,assign) NSInteger autoPlay;
@property(nonatomic,assign) BOOL mute;
@property(nonatomic,assign) BOOL showCloseButton;
- (void)setAdElementsStyle:(NSDictionary *)style;
- (void)loadAd;
- (void)loadAdWithBidToken:(NSString *)bidToken;
- (UIView *)fetchAdView;
- (void)destroyNativeAd;
- (instancetype)initWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID adSize:(CGSize)adSize rootViewController:(UIViewController *)rootViewControlle;
@end
