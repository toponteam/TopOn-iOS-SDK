//
//  ATNendRewardedVideoAdapter.h
//  AnyThinkNendRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/4/19.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATNendRewardedVideoAdapter : NSObject
@end

@protocol ATNADVideo<NSObject>
@property (nonatomic, copy, nullable) NSString *mediationName;
@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic) id userFeature;
@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic) BOOL isLocationEnabled;
@property (nonatomic) BOOL isOutputLog __deprecated_msg("This method is deprecated. Use setLogLevel: method of NADLogger instead.");
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;
- (void)loadAd;
- (void)showAdFromViewController:(UIViewController *)viewController;
- (void)releaseVideoAd;
@end

@protocol NADRewardedVideoDelegate;
@protocol ATNADRewardedVideo<ATNADVideo>
@property (nonatomic, weak, readwrite) id<NADRewardedVideoDelegate> delegate;
@end

@protocol ATNADReward<NSObject>
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) NSInteger amount;
@end

@protocol NADRewardedVideoDelegate <NSObject>
@required
- (void)nadRewardVideoAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd didReward:(id<ATNADReward>)reward;
@optional
- (void)nadRewardVideoAdDidReceiveAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd;
- (void)nadRewardVideoAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd didFailToLoadWithError:(NSError *)error;
- (void)nadRewardVideoAdDidFailedToPlay:(id<ATNADRewardedVideo>)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidOpen:(id<ATNADRewardedVideo>)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidClose:(id<ATNADRewardedVideo>)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidStartPlaying:(id<ATNADRewardedVideo>)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidStopPlaying:(id<ATNADRewardedVideo>)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidCompletePlaying:(id<ATNADRewardedVideo>)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidClickAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidClickInformation:(id<ATNADRewardedVideo>)nadRewardedVideoAd;
@end
