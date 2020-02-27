//
//  NADRewardedVideo.h
//  NendAd
//

#import "NADReward.h"
#import "NADVideo.h"

@class NADRewardedVideo;

@protocol NADRewardedVideoDelegate <NSObject>

@required

- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didReward:(NADReward *)reward;

@optional

- (void)nadRewardVideoAdDidReceiveAd:(NADRewardedVideo *)nadRewardedVideoAd;
- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didFailToLoadWithError:(NSError *)error;
- (void)nadRewardVideoAdDidFailedToPlay:(NADRewardedVideo *)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidOpen:(NADRewardedVideo *)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidClose:(NADRewardedVideo *)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidStartPlaying:(NADRewardedVideo *)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidStopPlaying:(NADRewardedVideo *)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidCompletePlaying:(NADRewardedVideo *)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidClickAd:(NADRewardedVideo *)nadRewardedVideoAd;
- (void)nadRewardVideoAdDidClickInformation:(NADRewardedVideo *)nadRewardedVideoAd;

@end

@interface NADRewardedVideo : NADVideo

@property (nonatomic, weak, readwrite) id<NADRewardedVideoDelegate> delegate;

@end
