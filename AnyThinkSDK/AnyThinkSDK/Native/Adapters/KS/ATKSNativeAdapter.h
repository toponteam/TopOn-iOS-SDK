//
//  ATKSNativeAdapter.h
//  AnyThinkKSNaitveAdapter
//
//  Created by Topon on 2020/2/5.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const kKSAdVideoSoundEnableFlag;
extern NSString *const kKSNativeAdIsVideoFlag;
typedef NS_ENUM(NSInteger, ATKSAdSDKLogLevel) {
    KSAdSDKLogLevelAll      =       0,
    KSAdSDKLogLevelVerbose,  // 此类别的日记不会记录到日志文件中
    KSAdSDKLogLevelDebug,
    KSAdSDKLogLevelVerify,
    KSAdSDKLogLevelInfo,
    KSAdSDKLogLevelWarn,
    KSAdSDKLogLevelError,
    KSAdSDKLogLevelOff,
};
typedef NS_ENUM(NSInteger, ATKSAdMaterialType) {
    KSAdMaterialTypeUnkown      =       0,      // 未知
    KSAdMaterialTypeVideo       =       1,      // 视频
    KSAdMaterialTypeSingle      =       2,      // 单图
    KSAdMaterialTypeAtlas       =       3,      // 多图
};
typedef NS_ENUM(NSInteger, ATKSAdInteractionType) {
    KSAdInteractionType_Unknown,
    KSAdInteractionType_App,
    KSAdInteractionType_Web,
    KSAdInteractionType_DeepLink,
};
@interface ATKSNativeAdapter : NSObject
@end

@protocol KSAd <NSObject>
@property (nonatomic, readonly) NSInteger ecpm;
@end

@protocol ATKSAdUserInfo <NSObject>
@property (nonatomic, assign) long userId;           // 用户id，目前是必填
@property (nonatomic, copy) NSString *gender;         // 用户性别，选填 F: 女性 M:男性
@property (nonatomic, copy) NSArray *interestArray;   // 用户兴趣，选填
@end

@protocol ATKSAdSDKManager <NSObject>
@property (nonatomic, readonly, class) NSString *SDKVersion;
+ (void)setAppId:(NSString *)appId;
+ (void)setAppName:(NSString *)appName;
+ (void)setUserInfoBlock:(void(^)(id<ATKSAdUserInfo>))userInfoBlock;
+ (void)setLoglevel:(ATKSAdSDKLogLevel)level;
+ (NSString *)appId;
@end

@protocol ATKSAdImage <NSObject>
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@end

@protocol ATKSMaterialMeta <NSObject>
@property (nonatomic, assign) ATKSAdInteractionType interactionType;
@property (nonatomic, strong) NSArray< id<ATKSAdImage>> *imageArray;
@property (nonatomic, strong, nullable) id<ATKSAdImage> sdkLogo;
@property (nonatomic, strong, nullable)  id<ATKSAdImage> appIconImage;
@property (nonatomic, assign) CGFloat appScore;
@property (nonatomic, copy) NSString *appDownloadCountDesc;
@property (nonatomic, copy) NSString *adDescription;//descrip
@property (nonatomic, copy) NSString *adSource;
@property (nonatomic, copy) NSString *actionDescription;//button title
@property (nonatomic, assign) ATKSAdMaterialType materialType;
@property (nonatomic, assign) NSInteger videoDuration;
- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError * __autoreleasing *)error;
@property (nonatomic, strong) id<ATKSAdImage> videoCoverImage;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *appName;
@end


@protocol ATKSNativeAdDelegate;
@protocol ATKSNativeAd <NSObject>
@property (nonatomic, strong, readonly, nullable) id<ATKSMaterialMeta> data;
@property (nonatomic, weak, readwrite, nullable) id<ATKSNativeAdDelegate> delegate;
@property (nonatomic, weak, readwrite) UIViewController *rootViewController;
- (void)registerContainer:(__kindof UIView *)containerView withClickableViews:(NSArray<__kindof UIView *> *_Nullable)clickableViews;
- (void)unregisterView;
- (id)initWithPosId:(NSString *)posId;
- (void)loadAdData;
- (void)loadAdDataWithDictionary:(NSDictionary *)dictionary;
- (void)reportVideoStartPlay;
- (void)reportVideoEndPlay;
@end

@protocol ATKSNativeAdDelegate <NSObject>
@optional
- (void)nativeAdDidLoad:(id<ATKSNativeAd>)nativeAd;
- (void)nativeAd:(id<ATKSNativeAd>)nativeAd didFailWithError:(NSError *_Nullable)error;
- (void)nativeAdDidBecomeVisible:(id<ATKSNativeAd>)nativeAd;
- (void)nativeAdDidClick:(id<ATKSNativeAd>)nativeAd withView:(UIView *_Nullable)view;
- (void)nativeAdDidShowOtherController:(id<ATKSNativeAd>)nativeAd interactionType:(ATKSAdInteractionType)interactionType;
- (void)nativeAdDidCloseOtherController:(id<ATKSNativeAd>)nativeAd interactionType:(ATKSAdInteractionType)interactionType;
@end

@protocol ATKSVideoAdView <NSObject>
@property(nonatomic) CGRect frame;
@property(nonatomic) CGRect bounds;
@property (nonatomic, assign, readwrite) BOOL videoSoundEnable;
@end

@protocol ATKSNativeAdRelatedView <NSObject>
@property (nonatomic, strong, readonly, nullable) UILabel *adLabel;
@property (nonatomic, strong, readonly, nullable) id<ATKSVideoAdView> videoAdView;
- (void)refreshData:(id<ATKSNativeAd> )nativeAd;
@end

@protocol ATKSNativeAdsManagerDelegate;
@protocol ATKSNativeAdsManager <NSObject>
@property (nonatomic, strong, nullable) NSArray<id<ATKSNativeAd> > *data;
@property (nonatomic, weak, nullable) id<ATKSNativeAdsManagerDelegate> delegate;
- (id)initWithPosId:(NSString *)posId;
- (void)loadAdDataWithCount:(NSInteger)count;
@end


@protocol ATKSNativeAdsManagerDelegate <NSObject>
@optional
- (void)nativeAdsManagerSuccessToLoad:(id<ATKSNativeAdsManager>)adsManager nativeAds:(NSArray<id<ATKSNativeAd>> *_Nullable) nativeAdDataArray;
- (void)nativeAdsManager:(id<ATKSNativeAdsManager>)adsManager didFailWithError:(NSError *_Nullable)error;
@end

//feed
@protocol ATKSFeedAdDelegate;
//@protocol KSFeedAd <KSAd>
@protocol ATKSFeedAd <NSObject>
@property (nonatomic, readonly) UIView *feedView;
@property (nonatomic, weak) id<ATKSFeedAdDelegate> delegate;
- (void)setVideoSoundEnable:(BOOL)enable;
@end

@protocol ATKSFeedAdDelegate <NSObject>
@optional
- (void)feedAdViewWillShow:(id<ATKSFeedAd>)feedAd;
- (void)feedAdDidClick:(id<ATKSFeedAd>)feedAd;
- (void)feedAdDislike:(id<ATKSFeedAd>)feedAd;
- (void)feedAdDidShowOtherController:(id<ATKSFeedAd>)nativeAd interactionType:(ATKSAdInteractionType)interactionType;
- (void)feedAdDidCloseOtherController:(id<ATKSFeedAd>)nativeAd interactionType:(ATKSAdInteractionType)interactionType;
@end

@protocol ATKSFeedAdsManagerDelegate;
@protocol ATKSFeedAdsManager <NSObject>
@property (nonatomic, strong, readonly) NSArray<id<ATKSFeedAd>> *data;
- (instancetype)initWithPosId:(NSString *)posId size:(CGSize)size;
@property (nonatomic, weak, nullable) id<ATKSFeedAdsManagerDelegate> delegate;
- (void)loadAdDataWithCount:(NSInteger)count;
@end


@protocol ATKSFeedAdsManagerDelegate <NSObject>
@optional
- (void)feedAdsManagerSuccessToLoad:(id<ATKSFeedAdsManager>)adsManager nativeAds:(NSArray<id<ATKSFeedAd>> *_Nullable)feedAdDataArray;
- (void)feedAdsManager:(id<ATKSFeedAdsManager>)adsManager didFailWithError:(NSError *_Nullable)error;
@end

@protocol ATKSDrawAdDelegate;
@protocol ATKSDrawAd <NSObject>
@property (nonatomic, weak) id<ATKSDrawAdDelegate> delegate;
- (void)registerContainer:(UIView *)containerView;
- (void)unregisterView;

@end

@protocol ATKSDrawAdDelegate <NSObject>
@optional
- (void)drawAdViewWillShow:(id<ATKSDrawAd>)drawAd;
- (void)drawAdDidClick:(id<ATKSDrawAd>)drawAd;
- (void)drawAdDidShowOtherController:(id<ATKSDrawAd>)drawAd interactionType:(ATKSAdInteractionType)interactionType;
- (void)drawAdDidCloseOtherController:(id<ATKSDrawAd>)drawAd interactionType:(ATKSAdInteractionType)interactionType;
@end

@protocol ATKSDrawAdsManagerDelegate;
@protocol ATKSDrawAdsManager <NSObject>
@property (nonatomic, strong, readonly) NSArray<id<ATKSDrawAd>> *data;
- (instancetype)initWithPosId:(NSString *)posId;
@property (nonatomic, weak, nullable) id<ATKSDrawAdsManagerDelegate> delegate;
- (void)loadAdDataWithCount:(NSInteger)count;
@end

@protocol ATKSDrawAdsManagerDelegate <NSObject>

@optional
- (void)drawAdsManagerSuccessToLoad:(id<ATKSDrawAdsManager>)adsManager drawAds:(NSArray<id<ATKSDrawAd>> *_Nullable)drawAdDataArray;
- (void)drawAdsManager:(id<ATKSDrawAdsManager>)adsManager didFailWithError:(NSError *_Nullable)error;

@end
