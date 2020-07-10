//
//  ATAdManager+Splash.m
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdManager+Splash.h"
#import "ATSplashManager.h"
NSString *const kATSplashDelegateExtraNetworkIDKey = @"network_firm_id";
NSString *const kATSplashDelegateExtraAdSourceIDKey = @"adsource_id";
NSString *const kATSplashDelegateExtraIsHeaderBidding = @"adsource_isHeaderBidding";
NSString *const kATSplashDelegateExtraPrice = @"adsource_price";
NSString *const kATSplashDelegateExtraPriority = @"adsource_index";

NSString *const kATSplashExtraCountdownKey = @"countdown";
NSString *const kATSplashExtraTolerateTimeoutKey = @"tolerate_timeout";
NSString *const kATSplashExtraHideSkipButtonFlagKey = @"hide_skip_button_flag";
NSString *const kATSplashExtraBackgroundImageKey = @"background_image";
NSString *const kATSplashExtraBackgroundColorKey = @"background_color";
NSString *const kATSplashExtraSkipButtonCenterKey = @"skip_button_center";
NSString *const kATSplashExtraCustomSkipButtonKey = @"custom_skip_button";
NSString *const kATSplashExtraCanClickFlagKey = @"can_click_flag";

NSString *const kATSplashExtraBackgroundImageViewKey = @"background_image_view";
@implementation ATAdManager (Splash)
-(void) loadADWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATAdLoadingDelegate>)delegate window:(UIWindow*)window containerView:(UIView*)containerView {
    [self loadADWithPlacementID:placementID extra:extra customData:customData delegate:delegate window:window windowScene:nil containerView:containerView];
}

- (void)loadADWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra customData:(NSDictionary *)customData delegate:(id<ATSplashDelegate>)delegate window:(UIWindow *)window windowScene:(UIWindowScene *)windowScene containerView:(UIView *)containerView {
    NSMutableDictionary *modifiedExtra = [NSMutableDictionary dictionaryWithDictionary:extra];
    modifiedExtra[kATSplashExtraLoadingStartDateKey] = [NSDate date];
    if ([window isKindOfClass:[UIWindow class]]) {
        modifiedExtra[kATSplashExtraWindowKey] = window;
        if ([modifiedExtra[kATSplashExtraBackgroundImageKey] isKindOfClass:[UIImage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:window.bounds];
                bgImageView.image = modifiedExtra[kATSplashExtraBackgroundImageKey];
                [window addSubview:bgImageView];
                modifiedExtra[kATSplashExtraBackgroundImageViewKey] = bgImageView;
            });
        }
    }
    if ([windowScene isKindOfClass:[UIWindowScene class]]) { modifiedExtra[kATSplashExtraWindowSceneKey] = windowScene;}
    if ([containerView isKindOfClass:[UIView class]]) { modifiedExtra[kATSplashExtraContainerViewKey] = containerView; }
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:modifiedExtra customData:customData delegate:delegate];
}
@end
