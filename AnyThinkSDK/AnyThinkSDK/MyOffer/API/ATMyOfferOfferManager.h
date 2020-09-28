//
//  ATMyOfferOfferManager.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferModel.h"
#import "ATMyOfferInterstitialDelegate.h"
#import "ATMyOfferRewardedVideoDelegate.h"
#import "ATMyOfferSplashDelegate.h"
#import "ATMyOfferNativeDelegate.h"

typedef NS_ENUM(NSInteger, ATMyOfferFormat) {
    ATMyOfferFormatNative = 0,
    ATMyOfferFormatRewardedVideo = 1,
    ATMyOfferFormatBanner = 2,
    ATMyOfferFormatInterstitial = 3,
    ATMyOfferFormatSplash = 4
};

extern NSString *const kATMyOfferBannerSize320_50;
extern NSString *const kATMyOfferBannerSize320_90;
extern NSString *const kATMyOfferBannerSize300_250;
extern NSString *const kATMyOfferBannerSize728_90;



@interface ATMyOfferOfferManager : NSObject
+(instancetype) sharedManager;
-(BOOL) resourceReadyForOfferModel:(ATMyOfferOfferModel*)offerModel;
-(BOOL) offerReadyForOfferModel:(ATMyOfferOfferModel*)offerModel;
-(BOOL) offerReadyForInterstitialOfferModel:(ATMyOfferOfferModel*)offerModel;
-(ATMyOfferOfferModel*) defaultOfferInOfferModels:(NSArray<ATMyOfferOfferModel*>*)offerModels;
-(void) loadOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion;
-(void) showInterstitialWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferInterstitialDelegate>)delegate;
-(void) showRewardedVideoWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferRewardedVideoDelegate>)delegate;
- (void)showSplashInKeyWindow:(UIWindow *)window containerView:(UIView *)containerView offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting  delegate:(id<ATMyOfferSplashDelegate>)delegate;
- (void)registerViewForInteraction:(UIViewController *)viewController clickableViews:(NSArray<UIView *> *)clickableViews offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting *)setting delegate:(id<ATMyOfferNativeDelegate>)delegate;
@end
