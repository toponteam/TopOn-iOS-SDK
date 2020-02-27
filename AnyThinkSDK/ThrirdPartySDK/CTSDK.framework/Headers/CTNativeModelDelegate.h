//
//  CTNativeModelDelegate.h
//  CTSDK
//

#import <Foundation/Foundation.h>

@protocol CTNativeModelDelegate <NSObject>

@optional
/**
 * Advertisement landing page will show.
 */
-(void)CTNativeAdDidIntoLandingPage:(NSObject *)nativeModel;
/**
 * Leave App
 */
-(void)CTNativeAdWillLeaveApplication:(NSObject *)nativeModel;
/**
 * Jump failure
 */
-(void)CTNativeAdJumpfail:(NSObject *)nativeModel;

@end
