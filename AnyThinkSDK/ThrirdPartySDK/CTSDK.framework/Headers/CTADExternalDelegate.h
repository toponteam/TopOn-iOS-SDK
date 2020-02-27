//
//  CTSDK
//

#import <UIKit/UIKit.h>

@class CTNativeAd;

#pragma mark ElementAd Delegate

@protocol CTNativeAdDelegate <NSObject>

@optional
/**
 * User click the advertisement.
 */
-(void)CTNativeAdDidClick:(UIView *)nativeAd;
/**
 * Advertisement landing page will show.
 */
-(void)CTNativeAdDidIntoLandingPage:(UIView *)nativeAd;
/**
 * User left the advertisement landing page.
 */
-(void)CTNativeAdDidLeaveLandingPage:(UIView *)nativeAd;
/**
 * Leave App
 */
-(void)CTNativeAdWillLeaveApplication:(UIView *)nativeAd;
/**
 * Jump failure
 */
-(void)CTNativeAdJumpfail:(UIView*)nativeAd;
@end


#pragma mark CTAppWall Delegate

@protocol CTAppWallDelegate <NSObject>

@optional
/**
 * User click the advertisement.
 */
-(void)CTAppWallDidClick:(CTNativeAd *)nativeAd;
/**
 * Advertisement landing page will show.
 */
-(void)CTAppWallDidIntoLandingPage:(CTNativeAd *)nativeAd;
/**
 * User left the advertisement landing page.
 */
-(void)CTAppWallDidLeaveLandingPage:(CTNativeAd *)nativeAd;
/**
 * Leave App
 */
-(void)CTAppWallWillLeaveApplication:(CTNativeAd *)nativeAd;
/**
 * User close the advertisement.
 */
-(void)CTAppWallClosed;
/**
 * Jump failure
 */
-(void)CTAppWallJumpfail:(CTNativeAd*)nativeAd;
@end
