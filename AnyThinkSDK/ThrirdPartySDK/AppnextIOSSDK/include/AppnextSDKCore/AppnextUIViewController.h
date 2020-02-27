//
//  AppnextUIViewController.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 30/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdsContainerDelegate.h>
#import <AppnextSDKCore/AppnextUIWebViewHandler.h>
#import <AppnextSDKCore/AppnextAd.h>

@protocol AppnextUIViewControllerDelegate <UIWebViewDelegate>

- (void) viewShown:(AppnextAdData *)impressionUrl;
- (void) viewClosed;

- (void) onAppnextWebViewOpenWithClickedBanner:(AppnextAdData *)banner;
- (void) onAppnextWebViewDestroy:(NSString *)param;
- (void) onAppnextWebViewImpression:(NSString *)param;
- (void) onAppnextWebViewOpenLink:(NSString *)param;

@end

@interface AppnextUIViewController : UIViewController <AppnextUIWebViewHandlerDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) AppnextAd *owningAd;
@property (nonatomic, strong, readonly) UIWebView *adWebView;
@property (nonatomic, strong, readonly) NSString *currentBannerJSONString;
@property (nonatomic, strong) AppnextAdData *currentAdData;

- (void) prepareAndLoadResourcesAndViewsForAd:(AppnextAd *)ad
                                withContainer:(id<AppnextAdsContainerProtocol>)container
                          withViewsReadyBlock:(appnext_prepare_load_block_t)viewsReadyBlock
                               withCompletion:(appnext_prepare_load_block_t)completionBlock;
- (void) prepareViewsToShow:(AppnextAd *)ad;
- (void) showAppnextAdView:(AppnextAd *)ad;
- (void) hideAppnextAdView;
- (void) showWaitScreen;
- (void) hideWaitScreen;
- (void) resumeAd:(AppnextAd *)ad;
- (void) goToTheEnd;

- (void) adjustViewToOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void) completeAdjustViewToOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
