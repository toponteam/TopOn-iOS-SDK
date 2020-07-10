//
//  NADInterstitialVideo.h
//  NendAd
//

#import "NADVideo.h"

@class NADInterstitialVideo;

@protocol NADInterstitialVideoDelegate <NSObject>

@optional

- (void)nadInterstitialVideoAdDidReceiveAd:(NADInterstitialVideo *)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAd:(NADInterstitialVideo *)nadInterstitialVideoAd didFailToLoadWithError:(NSError *)error;
- (void)nadInterstitialVideoAdDidFailedToPlay:(NADInterstitialVideo *)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidOpen:(NADInterstitialVideo *)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidClose:(NADInterstitialVideo *)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidStartPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidStopPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidCompletePlaying:(NADInterstitialVideo *)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidClickAd:(NADInterstitialVideo *)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidClickInformation:(NADInterstitialVideo *)nadInterstitialVideoAd;

@end

@interface NADInterstitialVideo : NADVideo

@property (nonatomic, weak, readwrite) id<NADInterstitialVideoDelegate> delegate;
@property (nonatomic, copy) UIColor *fallbackFullboardBackgroundColor;
@property (nonatomic) BOOL isMuteStartPlaying;

- (void)addFallbackFullboardWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;

@end
