//
//  ATAdManager+Splash.h
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
extern NSString *const kATSplashExtraCountdownKey;
extern NSString *const kATSplashExtraTolerateTimeoutKey;
extern NSString *const kATSplashExtraHideSkipButtonFlagKey;
extern NSString *const kATSplashExtraBackgroundImageKey;
extern NSString *const kATSplashExtraBackgroundColorKey;
extern NSString *const kATSplashExtraSkipButtonCenterKey;
extern NSString *const kATSplashExtraCustomSkipButtonKey;
extern NSString *const kATSplashExtraCanClickFlagKey;
@protocol ATSplashDelegate;
@interface ATAdManager (Splash)
-(void) loadADWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATSplashDelegate>)delegate window:(UIWindow*)window containerView:(UIView*)containerView;
-(void) loadADWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATSplashDelegate>)delegate window:(UIWindow*)window windowScene:(UIWindowScene *)windowScene containerView:(UIView*)containerView API_AVAILABLE(ios(13.0));
@end
