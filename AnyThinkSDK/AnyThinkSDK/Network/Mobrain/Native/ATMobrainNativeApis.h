//
//  ATMobrainNativeApis.h
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/2/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ATMobrainBaseManager.h"

#ifndef ATMobrainNativeApis_h
#define ATMobrainNativeApis_h

typedef NS_ENUM (NSInteger, ATABUPlayerPlayState) {
    ABUPlayerStateFailed    = 0,
    ABUPlayerStateBuffering = 1,
    ABUPlayerStatePlaying   = 2,
    ABUPlayerStateStopped   = 3,
    ABUPlayerStatePause     = 4,
    ABUPlayerStateDefalt    = 5
};

typedef NS_ENUM (NSInteger, ATABUAdSlotAdType) {
    ABUAdSlotAdTypeUnknown         = 0,
    ABUAdSlotAdTypeBanner          = 1,     // banner ads
    ABUAdSlotAdTypeInterstitial    = 2,     // interstitial ads
    ABUAdSlotAdTypeSplash          = 3,     // splash ads
    ABUAdSlotAdTypeSplash_Cache    = 4,     // cache splash ads
    ABUAdSlotAdTypeFeed            = 5,     // feed ads
    ABUAdSlotAdTypePaster          = 6,     // paster ads
    ABUAdSlotAdTypeRewardVideo     = 7,     // rewarded video ads
    ABUAdSlotAdTypeFullscreenVideo = 8,     // full-screen video ads
    ABUAdSlotAdTypeDrawVideo       = 9,     // vertical (immersive) video ads
};

// 代码位类型，值与服务端下发对应
typedef NS_ENUM(NSInteger, ATABUAdPriceType) {
    ABUAdPriceTypeUnknown = -1,     // 未知类型
    ABUAdPriceTypeNormal = 0,       // 普通类型
    ABUAdPriceTypeClientBid = 1,    // 客户端竞价
    ABUAdPriceTypeServerBid = 2,    // 服务端竞价
    ABUAdPriceTypePriority = 100,   // 手动优先层
};

typedef NS_ENUM(NSInteger, ATABUAdSlotPosition) {
    ABUAdSlotPositionTop = 1,
    ABUAdSlotPositionBottom = 2,
    ABUAdSlotPositionFeed = 3,
    ABUAdSlotPositionMiddle = 4, // for interstitial ad only
    ABUAdSlotPositionFullscreen = 5,
};

@protocol ATABUAdUnit <NSObject>

/// required. The unique identifier of a native ad.
@property (nonatomic, copy) NSString *ID;


/// Get a express Ad if SDK can.Default is NO.Only for native Ad
@property (nonatomic, assign, readwrite) BOOL getExpressAdIfCan;

/// required. Ad type.
@property (nonatomic, assign) ATABUAdSlotAdType AdType;

/// required. Ad display location.
@property (nonatomic, assign) ATABUAdSlotPosition position;

/// required. Image size ratio
@property (nonatomic, strong) id<ATABUSize> imgSize;

/// Image size ratio
@property (nonatomic, strong) id<ATABUSize> iconSize;

/// Maximum length of the title.Supported for pangle only.
@property (nonatomic, assign) NSInteger titleLengthLimit;

/// Maximum length of description.Supported for pangle only.
@property (nonatomic, assign) NSInteger descLengthLimit;

/// Whether to support deeplink.Supported for pangle only.
@property (nonatomic, assign) BOOL isSupportDeepLink;

/**
required.
size expected ad view size，when size.height is zero, acture height will match size.width
 rsetep when getExpressAdIfCan is YES.But if getExpressAdIfCan is NO,height should not to be zero.
*/
@property (nonatomic, assign) CGSize adSize;

@end

@protocol ABUNativeAdsManagerDelegate;
///ABUNativeAdsManager
@protocol ATABUNativeAdsManager <NSObject>

/// The delegate for receiving state change messages such as requests succeeding/failing.  The delegate can be set to any object which conforming to <BUNativeAdsManagerDelegate>.
@property (nonatomic, weak, nullable) id<ABUNativeAdsManagerDelegate> delegate;

/// Need to load ads
@property (nonatomic, assign, readonly) NSInteger loadCount;

/**
 该字段用于标示配置是否请求成功，具体使用参考demo
 */
@property (nonatomic, assign, readonly) BOOL hasAdConfig;

/**
 required.
 Root view controller for handling ad actions.
 Action method includes 'pushViewController' and 'presentViewController'.
 */
@property (nonatomic, weak, readwrite) UIViewController *_Nullable rootViewController;

/// Indicates whether videos should start muted. By default this property value is YES. Some ads take priority from server configuration。
@property (nonatomic, assign) BOOL startMutedIfCan;

/// size expected ad view size，when size.height is zero, acture height will match size.width rsetep when getExpressAdIfCan is YES
@property (nonatomic, assign, readwrite) CGSize adSize;

/// Initialization method
/// @param adSlot Data for loading ads
- (instancetype _Nonnull)initWithSlot:(id<ATABUAdUnit> _Nullable)adSlot;

/// Load ads
/// @param count Number of ads loaded
- (void)loadAdDataWithCount:(NSInteger)count;

/**
 在hasAdConfig为NO的情况下需要传入该callback，并在callback中loadAdData，具体使用参考demo
 */
- (void)setConfigSuccessCallback:(void (^_Nullable)(void))callback;

//required.
//清除广告资源，在广告使用完毕（当前页面销毁）手动调用
- (void)destroyAd;

@end


@protocol ATABUImage <NSObject>

// image address URL
@property (nonatomic, copy) NSURL *imageURL;

// image width
@property (nonatomic, assign) float width;

// image height
@property (nonatomic, assign) float height;

// image scale
@property (nonatomic, assign) float scale;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSDictionary *)dictionaryValue;

@end


typedef NS_ENUM (NSInteger, ATABUInteractionType) {
    ABUInteractionTypeCustorm        = 0,
    ABUInteractionTypeNO_INTERACTION = 1,  // pure ad display
    ABUInteractionTypeURL            = 2,  // open the webpage using a browser
    ABUInteractionTypePage           = 3,  // open the webpage within the app
    ABUInteractionTypeDownload       = 4,  // download the app
    ABUInteractionTypePhone          = 5,  // make a call
    ABUInteractionTypeMessage        = 6,  // send messages
    ABUInteractionTypeEmail          = 7,  // send email
    ABUInteractionTypeVideoAdDetail  = 8,   // video ad details page
    ABUInteractionTypeOthers         = 100 //其他广告sdk返回的类型
};

typedef NS_ENUM (NSInteger, ATABUFeedADMode) {
    ABUFeedADModeSmallImage    = 2,
    ABUFeedADModeLargeImage    = 3,
    ABUFeedADModeGroupImage    = 4,
    ABUFeedVideoAdModeImage    = 5, // video ad || rewarded video ad horizontal screen
    ABUFeedVideoAdModePortrait = 15, // rewarded video ad vertical screen
    ABUFeedADModeImagePortrait = 16
};

@protocol ATABUMaterialMeta <NSObject>

/// interaction types supported by ads.
@property (nonatomic, assign) ATABUInteractionType interactionType;

/// material pictures.
@property (nonatomic, strong) NSArray<id<ATABUImage> > *imageAry;

/// ad logo icon.
@property (nonatomic, strong) id<ATABUImage> icon;

/// ad headline.
@property (nonatomic, copy) NSString *AdTitle;

/// ad description.
@property (nonatomic, copy) NSString *AdDescription;

/// ad source.
@property (nonatomic, copy) NSString *source;

/// text displayed on the creative button.
@property (nonatomic, copy) NSString *buttonText;

/// display format of the in-feed ad, other ads ignores it.
@property (nonatomic, assign) ATABUFeedADMode imageMode;

/// Star rating, range from 1 to 5.
@property (nonatomic, assign) NSInteger score;

/// Number of comments.
@property (nonatomic, assign) NSInteger commentNum;

/// ad installation package size, unit byte.
@property (nonatomic, assign) NSInteger appSize;

/// video duration
@property (nonatomic, assign) NSInteger videoDuration;

/// media configuration parameters.
@property (nonatomic, copy) NSDictionary *mediaExt;

/// String representation of the app's price
@property (nonatomic, strong) NSString *appPrice;

/// Identifies the advertiser. For example, the advertiser’s name or visible URL.
@property (nonatomic, copy) NSString *advertiser;

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)error;

@end

@protocol ABUNativeAdViewDelegate;
@protocol ABUNativeAdVideoDelegate;
@protocol ATABUNativeAdView <NSObject>

@property (nonatomic, weak) id<ATABUNativeAdsManager> _Nullable adManager;     // 隶属的广告管理类
@property (nonatomic, strong) id<ATABUAdUnit> _Nullable originSlot;     //父级广告位

/**
 The delegate for receiving state change messages.
 The delegate is not limited to viewcontroller.
 The delegate can be set to any object which conforming to <BUNativeAdDelegate>.
 */
@property (nonatomic, weak, readwrite, nullable) id<ABUNativeAdViewDelegate> delegate;

/**
 The delegate is for native video Ads.
 The delegate can be set to video Ads  object which conforming to <ABUNativeAdViewDelegate>.
 */
@property (nonatomic, weak, readwrite, nullable) id<ABUNativeAdVideoDelegate> videoDelegate;

/**
 Indicates whether video should start play auto. By default this property value is NO. It is only valid when the third adn is supported and current ad type is native video(data.imageMode == ABUFeedVideoAdModeImage).
 信息流视频是否自动播放,默认为NO。仅在第三方Adn支持时可生效(若设置未生效说明三方不支持并不是聚合问题).同时，使用时要判断当前广告类型data.imageMode == ABUFeedVideoAdModeImage
 */
@property (nonatomic, assign, readonly) BOOL autoPlayIfcan;

/**
 control the video playbackcontrol the video playback.
 是否可以控制视频播放
 Generally if it is NO, it will be YES when third Adn is supported.
 当三方Adn支持时，开发者可手动控制视频播放.
 The valid premise of the value is when data.imageMode == ABUFeedVideoAdModeImage.
 有效前提是data.imageMode == ABUFeedVideoAdModeImage.
 */
@property (nonatomic, assign, readonly) BOOL canConfigVideoPlay;

/**
 The following four functions about video are only valid when the property "canConfigVideoPlay" is YES.If you want to use those functions, you should make sure that autoPlayIfcan is NO.
 以下四项有关视频的方法只有在canConfigVideoPlay=YES时，有效。使用时，需将autoPlayIfcan设置为NO.
 */
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)stop;

/**
 required.
 Root view controller for handling ad actions.
 Action method includes 'pushViewController' and 'presentViewController'.
 */
@property (nonatomic, weak, readwrite) UIViewController *_Nullable rootViewController;
/**
 Initializes native ad with ad slot.
 @param adUnit : ad unit description.
               including slotID,adType,adPosition,etc.
 @return ABUNativeAd
 */
- (instancetype _Nonnull)initWithUnit:(id<ATABUAdUnit> _Nonnull)adUnit;

/*************************************************自渲染接口 Start********************************************************************/

/**
 Ad slot material.It use to render ads by developer themselves when isExpressAd is NO.
 广告物料，当isExpressAd=NO时用于开发者自行渲染广告
 */
@property (nonatomic, strong, readonly, nullable) id<ATABUMaterialMeta> data;

/**
 Use for Ad which is not expressed(isExpressAd=NO).
 Register clickable views in native ads view.
 Interaction types can be configured on TikTok Audience Network.
 Interaction types include view video ad details page, make a call, send email, download the app, open the webpage using a browser,open the webpage within the app, etc.
 @param clickableViews : optional.
                        Array of views that are clickable.
 */
- (void)registerClickableViews:(NSArray<__kindof UIView *> *_Nullable)clickableViews;

// 若返回为自渲染广告，开发者需自己渲染布局返回的View，需自渲染以下内容

/*************************************************自渲染接口 End********************************************************************/

/*************************************************自渲染视图 Start********************************************************************/

/// hasSupportActionBtn. Whether to support adding button:callToActionBtn.If hasSupportActionBtn is YES, you can setuo frame of callToActionBtn
@property (nonatomic, assign) BOOL hasSupportActionBtn;

/// Ad Title. Need to be assigned from a data(ABUMaterialMeta).
@property (nonatomic, strong) UILabel *_Nullable titleLabel;

/// Ad Desc. Need to be assigned from a data(ABUMaterialMeta).
@property (nonatomic, strong) UILabel *_Nullable descLabel;

/// Ad Icon.Need to judge whether the value is empty.If If customized, it needs to be added to self(ABUNativeAdView)
@property (nonatomic, strong) UIImageView *_Nullable iconImageView;

/// Ad image. Need to be assigned from a data(ABUMaterialMeta), and need to be add to self(ABUNativeAdView).
@property (nonatomic, strong) UIImageView *_Nullable imageView;

/// Ad CTA button. Need to be assigned from a data(ABUMaterialMeta), and need to be add to self(ABUNativeAdView).
@property (nonatomic, strong) UIButton *_Nullable callToActionBtn;

/// Ad logo. Need to judge whether the value is empty.If If customized, it needs to be added to self(ABUNativeAdView).
@property (nonatomic, strong, nullable) UIView *adLogoView;

/// dislikeBtn.Need to judge whether the value is empty.If If customized, it needs to be added to self(ABUNativeAdView)
@property (nonatomic, strong, nullable) UIView *advertiserView;

/// dislikeBtn.Need to judge whether the value is empty.If customized, it needs to be added to self(ABUNativeAdView)
@property (nonatomic, strong, nullable) UIButton *dislikeBtn;

/**
 Video ad view. Need to be assigned from a data(ABUMaterialMeta).
 */
@property (nonatomic, strong, nullable) UIView *mediaView;

/*************************************************自渲染视图 End********************************************************************/

/*************************************************模板接口 Start********************************************************************/

// 若返回为模板广告，返回View可直接使用
/**
 Is a express Ad
 是否为模板广告，isExpressAd=YES时可调用render渲染广告;w在外部设置getExpressAdIfCanw=YES时如果第三方支持会返回模板广告
 */
@property (nonatomic, assign, readonly) BOOL hasExpressAdGot;

/**
 required if isExpressAd=YES
 */
- (void)render;

/**
required if frame of mediaView is resetup.
*/
- (void)reSizeMediaView;
/*************************************************模板接口 End********************************************************************/

/// 返回显示广告对应的Adn，当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3
- (ATABUAdnType)getAdNetworkPlaformId;
/// 返回显示广告对应的rit，当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3
- (NSString *_Nullable)getAdNetworkRitId;
/// 返回显示广告对应的ecpm，当未在平台配置ecpm会返回-1，当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3 单位：分
- (NSString *_Nullable)getPreEcpm;

@end

@protocol ATABUDislikeWords <NSObject>
@property (nonatomic, copy) NSString *dislikeID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSArray<id<ATABUDislikeWords>> *options;

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError **)error;
@end

@protocol ABUNativeAdsManagerDelegate <NSObject>
@optional

/// Native ad load success
/// @param adsManager adsManager
/// @param nativeAdViewArray Load successfully returned material
- (void)nativeAdsManagerSuccessToLoad:(id<ATABUNativeAdsManager> _Nonnull)adsManager nativeAds:(NSArray<id<ATABUNativeAdView>> *_Nullable)nativeAdViewArray;

/// Native ad load failed
/// @param adsManager adsManager
/// @param error  error description
- (void)nativeAdsManager:(id<ATABUNativeAdsManager> _Nonnull)adsManager didFailWithError:(NSError *_Nullable)error;

@end

# pragma mark - callback for native video
@protocol ABUNativeAdViewDelegate <NSObject>
@optional

/**
 * This method is called when rendering a nativeExpressAdView successed, and nativeExpressAdView.size.height has been updated.
 * Only called when hasExpressAdGot = YES.
 */
- (void)nativeAdExpressViewRenderSuccess:(id<ATABUNativeAdView> _Nonnull)nativeExpressAdView;

/**
 * This method is called when a nativeExpressAdView failed to render
 * Only called when hasExpressAdGot = YES.
 */
- (void)nativeAdExpressViewRenderFail:(id<ATABUNativeAdView> _Nonnull)nativeExpressAdView error:(NSError *_Nullable)error;

/**
 This method is called when native ad slot has been shown.
 */
- (void)nativeAdDidBecomeVisible:(id<ATABUNativeAdView> _Nonnull)nativeAdView;

/**
Sent when a playerw playback status changed.
@param playerState : player state after changed
 Only called when hasExpressAdGot = YES.
*/
- (void)nativeAdExpressView:(id<ATABUNativeAdView> _Nonnull)nativeAdView stateDidChanged:(ATABUPlayerPlayState)playerState;

/**
 This method is called when native ad is clicked.
 */
- (void)nativeAdDidClick:(id<ATABUNativeAdView> _Nonnull)nativeAdView withView:(UIView *_Nullable)view;

/**
 * Sent after an ad view is clicked, a ad landscape view will present modal content.Include appstore jump.
 */
- (void)nativeAdViewWillPresentFullScreenModal:(id<ATABUNativeAdView> _Nonnull)nativeAdView;

/**
 This method is called when the user clicked dislike reasons.
 Only called when nativeAdView.hasExpressAdGot = YES.
 */
- (void)nativeAdExpressViewDidClosed:(id<ATABUNativeAdView> _Nullable)nativeAdView closeReason:(NSArray<id<ATABUDislikeWords>> *_Nullable)filterWords;

@end

# pragma mark - callback for native video Ads
@protocol ABUNativeAdVideoDelegate <NSObject>
@optional

/**
 This method is called when videoadview playback status changed.
 @param playerState : player state after changed
 */
- (void)nativeAdVideo:(id<ATABUNativeAdView> _Nullable)nativeAdView stateDidChanged:(ATABUPlayerPlayState)playerState;

/**
 This method is called when videoadview's finish view is clicked.
 */
- (void)nativeAdVideoDidClick:(id<ATABUNativeAdView> _Nullable)nativeAdView;

/**
 This method is called when videoadview end of play.
 */
- (void)nativeAdVideoDidPlayFinish:(id<ATABUNativeAdView> _Nullable)nativeAdView;

@end

#endif /* ATMobrainNativeApis_h */
