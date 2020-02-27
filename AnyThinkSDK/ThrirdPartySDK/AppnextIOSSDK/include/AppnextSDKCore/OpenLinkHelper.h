//
//  OpenLinkHelper.h
//  AppnextLib
//
//  Created by shalom.b on 1/31/18.
//  Copyright © 2018 Appnext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppnextSettingsManager.h"
#import "AppnextRedirectResolveManagerDelegate.h"

@protocol OpenLinkHelperDelegate <NSObject>
@optional
- (void) storeOpened:(AppnextAdData *)adData;
- (void) onLeaveStore;
- (void) installFailed:(AppnextAdData *)adData withError:(NSString *)error;
@end

@interface OpenLinkHelper : NSObject <AppnextRedirectResolveManagerDelegate>

- (instancetype) initWithPlacementID:(NSString *) placmentID  withTID:(NSString *) TID withAUID:(NSString *) AUID withClickInAppUserChoose:(NSNumber *) clickInAppUserChoose withSettingManager:(AppnextSettingsManager *) settingsManager withDelegate:(id<OpenLinkHelperDelegate>) delegate;
- (void) onInstallClickedWithClickedBanner:(AppnextAdData *)banner withViewcontroller:(UIViewController *) viewController;
- (void) onOpenUrlFromAd:(NSString *)url;
@end
