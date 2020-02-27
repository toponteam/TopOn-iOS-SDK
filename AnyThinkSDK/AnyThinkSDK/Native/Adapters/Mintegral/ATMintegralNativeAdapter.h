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

@protocol ATMTGSDK<NSObject>
+(instancetype) sharedInstance;
- (void)setUserPrivateInfoType:(ATMTGUserPrivateType)type agree:(BOOL)agree;
- (void)setAppID:(nonnull NSString *)appID ApiKey:(nonnull NSString *)apiKey;
@property (nonatomic, assign) BOOL consentStatus;
@end

@protocol ATMTGTemplate<NSObject>
+ (instancetype )templateWithType:(ATMTGAdTemplateType)templateType adsNum:(NSUInteger)adsNum;
@end

@protocol ATMTGNativeAdManagerDelegate;
@protocol ATMTGCampaign;
@protocol ATMTGNativeAdManager<NSObject>
- (nonnull instancetype)initWithUnitID:(nonnull NSString *)unitId
                         fbPlacementId:(nullable NSString *)fbPlacementId
                    supportedTemplates:(nullable NSArray *)templates
                        autoCacheImage:(BOOL)autoCacheImage
                            adCategory:(ATMTGAdCategory)adCategory
              presentingViewController:(nullable UIViewController *)viewController;
- (void)registerViewForInteraction:(nonnull UIView *)view
                withClickableViews:(nonnull NSArray *)clickableViews
                      withCampaign:(id<ATMTGCampaign>)campaign;
- (void)loadAds;
@property (nonatomic, weak, nullable) id <ATMTGNativeAdManagerDelegate> delegate;
@end

@protocol ATMTGNativeAdManagerDelegate <NSObject>
- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds;
- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error;
@end

@protocol ATMTGMediaViewDelegate;
@protocol ATMTGCampaign;
@protocol ATMTGMediaView<NSObject>
- (void)setMediaSourceWithCampaign:(id<ATMTGCampaign>)campaign unitId:(NSString*)unitId;
@property (nonatomic, weak, nullable) id<ATMTGMediaViewDelegate> delegate;
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
- (void)nativeAdDidClick:(nonnull id<ATMTGCampaign>)nativeAd;
@end

@protocol MTGBidNativeAdManagerDelegate;
@protocol ATMTGBidNativeAdManager<NSObject>
@property (nonatomic, weak, nullable) id <MTGBidNativeAdManagerDelegate> delegate;
@property (nonatomic, assign) BOOL showLoadingView;
@property (nonatomic, readonly) NSString * _Nonnull currentUnitId;
@property (nonatomic, weak) UIViewController * _Nullable  viewController;
- (nonnull instancetype)initWithUnitID:(nonnull NSString *)unitId presentingViewController:(nullable UIViewController *)viewController;
- (nonnull instancetype)initWithUnitID:(nonnull NSString *)unitId autoCacheImage:(BOOL)autoCacheImage presentingViewController:(nullable UIViewController *)viewController;
- (void)loadWithBidToken:(nonnull NSString *)bidToken;
- (void)registerViewForInteraction:(nonnull UIView *)view withCampaign:(nonnull id<ATMTGCampaign>)campaign;
- (void)unregisterView:(nonnull UIView *)view;
- (void)registerViewForInteraction:(nonnull UIView *)view withClickableViews:(nonnull NSArray *)clickableViews withCampaign:(nonnull id<ATMTGCampaign>)campaign;
- (void)unregisterView:(nonnull UIView *)view clickableViews:(nonnull NSArray *)clickableViews;
- (void)cleanAdsCache;
-(void)setVideoViewSize:(CGSize)size;
-(void)setVideoViewSizeWithWidth:(CGFloat)width height:(CGFloat)height;
@end

@protocol MTGBidNativeAdManagerDelegate<NSObject>
@end
