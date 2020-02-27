//
//  ATInmobiInterstitialAdapter.h
//  AnyThinkInmobiInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, ATIMInterstitialAnimationType) {
    kATIMInterstitialAnimationTypeCoverVertical,
    kATIMInterstitialAnimationTypeFlipHorizontal,
    kATIMInterstitialAnimationTypeNone
};
@interface ATInmobiInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATIMSdk<NSObject>
+(NSString *)getVersion;
+(void)initWithAccountID:(NSString *)accountID;
+(void) updateGDPRConsent:(NSDictionary *)consentDictionary;
@end

@protocol ATIMInterstitialDelegate;
@protocol ATIMInterstitial<NSObject>
@property (nonatomic, weak) id<ATIMInterstitialDelegate> delegate;
@property (nonatomic, strong) NSString* keywords;
@property (nonatomic, strong) NSDictionary* extras;
@property (nonatomic, strong, readonly) NSString* creativeId;
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

NS_ASSUME_NONNULL_END
