//
//  ATTTNativeAdapter.h
//  AnyThinkTTNativeAdapter
//
//  Created by Martin Lau on 2018/12/29.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *const kTTNativeExpressDrawAdViewKey;
@interface ATTTNativeAdapter : NSObject

@end
typedef NS_ENUM(NSInteger, ATBUProposalSize) {
    BUProposalSize_Banner600_90,
    BUProposalSize_Banner600_100,
    BUProposalSize_Banner600_150,
    BUProposalSize_Banner600_260,
    BUProposalSize_Banner600_286,
    BUProposalSize_Banner600_300,
    BUProposalSize_Banner600_388,
    BUProposalSize_Banner600_400,
    BUProposalSize_Banner600_500,
    BUProposalSize_Feed228_150,
    BUProposalSize_Feed690_388,
    BUProposalSize_Interstitial600_400,
    BUProposalSize_Interstitial600_600,
    BUProposalSize_Interstitial600_900,
    BUProposalSize_DrawFullScreen
};

typedef NS_ENUM(NSInteger, ATTTNativeAdType) {
    ATTTNativeAdTypeBanner = 1,
    ATTTNativeAdTypeInterstitial = 2,
    ATTTNativeAdTypeFeed = 5,
    ATTTNativeAdTypeDraw = 9
};

@protocol ATBUAdSlot, ATBUNativeAd, BUNativeAdsManagerDelegate, ATBUMaterialMeta, BUNativeAdDelegate;
@protocol ATBUNativeAdsManager<NSObject>
@property (nonatomic, strong, nullable) id<ATBUAdSlot> adslot;
@property (nonatomic, strong, nullable) NSArray<id<ATBUNativeAd>> *data;
@property (nonatomic, weak, nullable) id<BUNativeAdsManagerDelegate> delegate;
- (instancetype)initWithSlot:(id<ATBUAdSlot> _Nullable) slot;
- (void)loadAdDataWithCount:(NSInteger)count;
@end

@protocol BUNativeAdsManagerDelegate <NSObject>
@optional
- (void)nativeAdsManagerSuccessToLoad:(id<ATBUNativeAdsManager>)adsManager nativeAds:(NSArray<id<ATBUNativeAd>> *_Nullable)nativeAdDataArray;
- (void)nativeAdsManager:(id<ATBUNativeAdsManager>)adsManager didFailWithError:(NSError *_Nullable)error;
@end

@protocol ATBUNativeAd<NSObject>
@property (nonatomic, strong, readwrite, nullable) id<ATBUAdSlot> adslot;
@property (nonatomic, strong, readonly, nullable) id<ATBUMaterialMeta> data;
@property (nonatomic, weak, readwrite, nullable) id<BUNativeAdDelegate> delegate;
@property (nonatomic, weak, readwrite) UIViewController *rootViewController;
- (instancetype)initWithSlot:(id<ATBUAdSlot>)slot;
- (void)registerContainer:(__kindof UIView *)containerView withClickableViews:(NSArray<__kindof UIView *> *_Nullable)clickableViews;
- (void)unregisterView;
- (void)loadAdData;

@end


@protocol BUNativeAdDelegate <NSObject>
@optional
- (void)nativeAdDidLoad:(id<ATBUNativeAd>)nativeAd;
- (void)nativeAd:(id<ATBUNativeAd>)nativeAd didFailWithError:(NSError *_Nullable)error;
- (void)nativeAdDidBecomeVisible:(id<ATBUNativeAd>)nativeAd;
- (void)nativeAdDidClick:(id<ATBUNativeAd>)nativeAd withView:(UIView *_Nullable)view;
- (void)nativeAd:(id<ATBUNativeAd>)nativeAd dislikeWithReason:(NSArray*)filterWords;
@end

@protocol ATBUImage<NSObject>
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end

@protocol ATBUMaterialMeta<NSObject>
@property (nonatomic, assign) NSInteger interactionType;
@property (nonatomic, strong) NSArray<id<ATBUImage>> *imageAry;
@property (nonatomic, strong) id<ATBUImage> icon;
@property (nonatomic, copy) NSString *AdTitle;
@property (nonatomic, copy) NSString *AdDescription;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *buttonText;
@property (nonatomic, copy) NSArray *filterWords;
@property (nonatomic, assign) NSInteger imageMode;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger commentNum;
@property (nonatomic, assign) NSInteger appSize;
- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError * __autoreleasing *)error;
@end

@protocol ATBUSize<NSObject>
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
+ (instancetype)sizeBy:(NSInteger)proposalSize;
- (NSDictionary *)dictionaryValue;
@end

@protocol ATBUAdSlot<NSObject>
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) NSInteger AdType;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, strong) NSMutableArray<id<ATBUSize>> *imgSizeArray;
@property (nonatomic, strong) id<ATBUSize> imgSize;
@property (nonatomic, strong) id<ATBUSize> iconSize;
@property (nonatomic, assign) NSInteger titleLengthLimit;
@property (nonatomic, assign) NSInteger descLengthLimit;
@property (nonatomic, assign) BOOL isSupportDeepLink;
@property (nonatomic, assign) BOOL isOriginAd;
- (NSDictionary *)dictionaryValue;
@end

@protocol BUVideoAdViewDelegate;
@protocol ATBUVideoAdView<NSObject>
@property (nonatomic, weak, nullable) id<BUVideoAdViewDelegate> delegate;
@property (nonatomic, weak, readwrite) UIViewController *rootViewController;
@property (nonatomic, assign) BOOL drawVideoClickEnable;
@property(nonatomic) CGRect  bounds;
@property(nonatomic) CGRect  frame;
@end

@protocol BUVideoAdViewDelegate <NSObject>
@optional
- (void)videoAdView:(id<ATBUVideoAdView>)videoAdView didLoadFailWithError:(NSError *_Nullable)error;
- (void)videoAdView:(id<ATBUVideoAdView>)videoAdView stateDidChanged:(NSInteger)playerState;
- (void)playerDidPlayFinish:(id<ATBUVideoAdView>)videoAdView;
- (void)videoAdViewDidClick:(id<ATBUVideoAdView>)videoAdView;
- (void)videoAdViewFinishViewDidClick:(id<ATBUVideoAdView>)videoAdView;
- (void)videoAdViewDidCloseOtherController:(id<ATBUVideoAdView>)videoAdView interactionType:(NSInteger)interactionType;
@end

@protocol ATBUNativeAdRelatedView<NSObject>
@property(nonatomic) BOOL hidden;
@property (nonatomic, strong, readonly, nullable) UIButton *dislikeButton;
@property (nonatomic, strong, readonly, nullable) UILabel *adLabel;
@property (nonatomic, strong, readonly, nullable) UIImageView *logoImageView;
@property (nonatomic, strong, readonly, nullable) UIImageView *logoADImageView;
@property (nonatomic, strong, readonly, nullable) id<ATBUVideoAdView> videoAdView;
- (void)refreshData:(id<ATBUNativeAd>)nativeAd;
@end

// 5.2.0 add TT 2.5.1.5 NativeExpress  Feed & Draw
@protocol ATBUDislikeWords <NSObject>
@property (nonatomic, copy, readonly) NSString *dislikeID;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL isSelected;
@property (nonatomic, copy,readonly) NSArray<id<ATBUDislikeWords>> *options;
- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError **)error;
@end

@protocol ATBUDislike <NSObject>

/**
 The array of BUDislikeWords which have reasons for dislike.
 The application can show the secondary page for dislike if '[filterWords.options count] > 0'.
 */
@property (nonatomic, copy, readonly) NSArray<id<ATBUDislikeWords>> *filterWords;

/**
 Initialize with nativeAd to get filterWords.
 return BUDislike
 */
- (instancetype)initWithNativeAd:(id<ATBUNativeAd>)nativeAd;

/**
 Call this method after the user chose dislike reasons.
 (Only for object which uses 'BUDislike.filterWords')
 @param filterWord : reasons for dislike
 @note : don't need to call this method if '[filterWords.options count] > 0'.
 @note :please dont't change 'BUDislike.filterWords'.
        'filterWord' must be one of 'BUDislike.filterWords', otherwise it will be filtered.
 */
- (void)didSelectedFilterWordWithReason:(id<ATBUDislikeWords>)filterWord;

@end

@protocol ATBUNativeExpressAdView <NSObject>
@property(nonatomic) CGPoint center;
@property(nonatomic) CGRect  frame;
@property(nonatomic) CGRect  bounds;
@property(nonatomic) UIViewAutoresizing autoresizingMask;
@property(nonatomic) BOOL  autoresizesSubviews;
@property (nonatomic, assign, readonly) BOOL isReady;
@property (nonatomic, weak) UIViewController *rootViewController;
- (void)render;
@end

@protocol ATBUNativeExpressAdViewDelegate;
@protocol ATBUNativeExpressAdManager <NSObject>
@property (nonatomic, strong, nullable) id<ATBUAdSlot> adslot;
@property (nonatomic, assign, readwrite) CGSize adSize;
@property (nonatomic, weak, nullable) id<ATBUNativeExpressAdViewDelegate> delegate;
- (instancetype)initWithSlot:(id<ATBUAdSlot> _Nullable)slot adSize:(CGSize)size;
- (void)loadAd:(NSInteger)count;
@end

@protocol ATBUNativeExpressAdViewDelegate <NSObject>
@optional
- (void)nativeExpressAdSuccessToLoad:(id<ATBUNativeExpressAdManager>)nativeExpressAd views:(NSArray<__kindof id<ATBUNativeExpressAdView>> *)views;
- (void)nativeExpressAdFailToLoad:(id<ATBUNativeExpressAdManager>)nativeExpressAd error:(NSError *_Nullable)error;
- (void)nativeExpressAdViewRenderSuccess:(id<ATBUNativeExpressAdView>)nativeExpressAdView;
- (void)nativeExpressAdViewRenderFail:(id<ATBUNativeExpressAdView>)nativeExpressAdView error:(NSError *_Nullable)error;
- (void)nativeExpressAdViewWillShow:(id<ATBUNativeExpressAdView>)nativeExpressAdView;
- (void)nativeExpressAdViewDidClick:(id<ATBUNativeExpressAdView>)nativeExpressAdView;
- (void)nativeExpressAdViewPlayerDidPlayFinish:(id<ATBUNativeExpressAdView>)nativeExpressAdView error:(NSError *)error;
- (void)nativeExpressAdView:(id<ATBUNativeExpressAdView>)nativeExpressAdView dislikeWithReason:(NSArray<id<ATBUDislikeWords>> *)filterWords;
- (void)nativeExpressAdViewWillPresentScreen:(id<ATBUNativeExpressAdView>)nativeExpressAdView;
@end


