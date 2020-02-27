//
//  AppnextAd+DelegateCallbacks.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 17/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAd.h>
#import <AppnextSDKCore/AppnextAdsContainerDelegate.h>

@interface AppnextAd(DelegateCallbacks)

- (void) performAdLoaded:(id<AppnextAdsContainerProtocol>)container;
- (void) performAdOpened;
- (void) performAdClosed;
- (void) performAdClicked;
- (void) performAdUserWillLeaveApplication;
- (void) performAdError:(NSString *)error;
- (void) performStoreOpenedForAdData:(AppnextAdData *)adData;
- (void) performInstallErrorForAdData:(AppnextAdData *)adData withError:(NSString *)error;

@end
