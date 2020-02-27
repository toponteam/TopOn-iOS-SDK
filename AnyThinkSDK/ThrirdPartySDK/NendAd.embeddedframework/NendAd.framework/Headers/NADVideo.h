//
//  NADVideo.h
//  NendAd
//

#import <UIKit/UIKit.h>

#import "NADUserFeature.h"

NS_ASSUME_NONNULL_BEGIN
@interface NADVideo : NSObject

@property (nonatomic, copy, nullable) NSString *mediationName;
@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic) NADUserFeature *userFeature;

@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic) BOOL isLocationEnabled;
@property (nonatomic) BOOL isOutputLog __deprecated_msg("This method is deprecated. Use setLogLevel: method of NADLogger instead.");

- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey NS_DESIGNATED_INITIALIZER;
- (void)loadAd;
- (void)showAdFromViewController:(UIViewController *)viewController;
- (void)releaseVideoAd;

@end
NS_ASSUME_NONNULL_END
