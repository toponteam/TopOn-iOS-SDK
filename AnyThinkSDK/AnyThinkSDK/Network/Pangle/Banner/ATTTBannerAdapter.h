//
//  ATTTBannerAdapter.h
//  AnyThinkTTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATTTBannerAdapter : NSObject

@end
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, ATWMProposalSize) {
    ATWMProposalSize_Banner600_90,
    ATWMProposalSize_Banner600_100,
    ATWMProposalSize_Banner600_150,
    ATWMProposalSize_Banner600_260,
    ATWMProposalSize_Banner600_286,
    ATWMProposalSize_Banner600_300,
    ATWMProposalSize_Banner600_388,
    ATWMProposalSize_Banner600_400,
    ATWMProposalSize_Banner600_500,
    ATWMProposalSize_Feed228_150,
    ATWMProposalSize_Feed690_388,
    ATWMProposalSize_Interstitial600_400,
    ATWMProposalSize_Interstitial600_600,
    ATWMProposalSize_Interstitial600_900,
};

typedef NS_ENUM(NSInteger, ATWMAdSlotPosition) {
    ATWMAdSlotPositionTop = 1, // 顶部
    ATWMAdSlotPositionBottom = 2, // 底部
    ATWMAdSlotPositionFeed = 3, // 信息流内
    ATWMAdSlotPositionMiddle = 4, // 中部(插屏广告专用)
    ATWMAdSlotPositionFullscreen = 5, // 全屏
};

@protocol ATBUSize<NSObject>
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
- (NSDictionary *)dictionaryValue;
+ (instancetype)sizeBy:(ATWMProposalSize)proposalSize;
@end

@protocol BUNativeExpressBannerViewDelegate;
@protocol ATBUNativeExpressBannerView<NSObject>
@property(nonatomic) CGRect frame;
@property (nonatomic, assign, readonly) NSInteger interval;
@property (nonatomic, weak, nullable) id<BUNativeExpressBannerViewDelegate> delegate;
- (instancetype)initWithSlotID:(NSString *)slotID rootViewController:(UIViewController *)rootViewController imgSize:(id<ATBUSize>)expectSize adSize:(CGSize)adsize IsSupportDeepLink:(BOOL)isSupportDeepLink;
- (instancetype)initWithSlotID:(NSString *)slotID
rootViewController:(UIViewController *)rootViewController
            adSize:(CGSize)adsize
 IsSupportDeepLink:(BOOL)isSupportDeepLink;

- (void)loadAdData;
@end

@protocol BUNativeExpressBannerViewDelegate <NSObject>
@optional
- (void)nativeExpressBannerAdViewDidLoad:(id<ATBUNativeExpressBannerView>)bannerAdView;
- (void)nativeExpressBannerAdView:(id<ATBUNativeExpressBannerView>)bannerAdView didLoadFailWithError:(NSError *_Nullable)error;
- (void)nativeExpressBannerAdViewRenderSuccess:(id<ATBUNativeExpressBannerView>)bannerAdView;
- (void)nativeExpressBannerAdViewRenderFail:(id<ATBUNativeExpressBannerView>)bannerAdView error:(NSError * __nullable)error;
- (void)nativeExpressBannerAdViewWillBecomVisible:(id<ATBUNativeExpressBannerView>)bannerAdView;
- (void)nativeExpressBannerAdViewDidClick:(id<ATBUNativeExpressBannerView>)bannerAdView;
- (void)nativeExpressBannerAdView:(id<ATBUNativeExpressBannerView>)bannerAdView dislikeWithReason:(NSArray *_Nullable)filterwords;

@end
NS_ASSUME_NONNULL_END
