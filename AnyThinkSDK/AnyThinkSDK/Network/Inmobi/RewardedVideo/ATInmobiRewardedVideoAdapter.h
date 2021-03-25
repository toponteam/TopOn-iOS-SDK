//
//  ATInmobiRewardedVideoAdapter.h
//  AnyThinkInmobiRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRewardedVideoAdapter.h"
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ATIMInterstitialAnimationType) {
    kATIMInterstitialAnimationTypeCoverVertical,
    kATIMInterstitialAnimationTypeFlipHorizontal,
    kATIMInterstitialAnimationTypeNone
};
extern NSString *const kInmobiRVAssetsCustomEventKey;
@interface ATInmobiRewardedVideoAdapter : NSObject<ATRewardedVideoAdapter>
@end

@protocol ATIMRewardedVideoPreloadManager <NSObject>
- (void)preload;
- (void)load;
@end

@protocol ATIMInterstitialDelegate, ATIMInterstitialPreloadManager;
@protocol ATIMInterstitial<NSObject>
@property (nonatomic, weak) id<ATIMInterstitialDelegate> delegate;
@property (nonatomic, strong) NSString* keywords;
@property (nonatomic, copy) NSString *unitID;
@property (nonatomic, strong) NSDictionary* extras;
@property (nonatomic, strong, readonly) NSString* creativeId;
@property (nonatomic, strong, readonly) id<ATIMRewardedVideoPreloadManager> preloadManager;

-(instancetype)initWithPlacementId:(long long)placementId;
-(instancetype)initWithPlacementId:(long long)placementId delegate:(id<ATIMInterstitialDelegate>)delegate;
-(void)load;
-(BOOL)isReady;
-(void)showFromViewController:(UIViewController *)viewController;
-(void)showFromViewController:(UIViewController *)viewController withAnimation:(ATIMInterstitialAnimationType)type;
- (NSDictionary *)getAdMetaInfo;
@end

@protocol ATIMInterstitialDelegate<NSObject>
@optional
-(void)interstitialDidReceiveAd:(id<ATIMInterstitial>)interstitial;
-(void)interstitialDidFinishLoading:(id<ATIMInterstitial>)interstitial;
-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToLoadWithError:(NSError*)error;
-(void)interstitialWillPresent:(id<ATIMInterstitial>)interstitial;
-(void)interstitialDidPresent:(id<ATIMInterstitial>)interstitial;
-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToPresentWithError:(NSError*)error;
-(void)interstitialWillDismiss:(id<ATIMInterstitial>)interstitial;
-(void)interstitialDidDismiss:(id<ATIMInterstitial>)interstitial;
-(void)interstitial:(id<ATIMInterstitial>)interstitial didInteractWithParams:(NSDictionary*)params;
-(void)interstitial:(id<ATIMInterstitial>)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards;
-(void)userWillLeaveApplicationFromInterstitial:(id<ATIMInterstitial>)interstitial;
@end
