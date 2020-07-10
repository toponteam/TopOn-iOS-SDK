//
//  ATBannerViewController.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 19/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerViewController.h"
@import AnyThinkSDK;
@import AnyThinkBanner;

static NSString *const kGDTPlacementID = @"b5bacad0803fd1";
static NSString *const kTTPlacementID = @"b5bacacfc470c9";
static NSString *const kAdmobPlacementID = @"b5bacacef17717";
static NSString *const kApplovinPlacementID = @"b5bacace1549da";
static NSString *const kFacebookPlacementID = @"b5baf502bb23e3";
static NSString *const kMopubPlacementID = @"b5baf57068e0b6";
static NSString *const kFlurryPlacementID = @"b5baf52fe4e57b";
static NSString *const kInmobiPlacementID = @"b5baf522891992";
static NSString *const kAllPlacementID = @"b5bacaccb61c29";
static NSString *const kYeahmobiPlacementID = @"b5bc7fb61b3213";
static NSString *const kAppnextPlacementID = @"b5bc7fb78288e9";
static NSString *const kBaiduPlacementID = @"b5c04dda229f7e";
static NSString *const kUnityAdsPlacementID = @"b5c21a04406722";
static NSString *const kNendPlacementID = @"b5cb96d97400b3";
static NSString *const kMintegralPlacementID = @"b5dd363166a5ea";
static NSString *const kBannerHeaderBiddingPlacementID = @"b5d146f9483215";
static NSString *const kFyberPlacementID = @"b5e96db4cb0682";
static NSString *const kStartAppPlacementID = @"b5ed47a285a23a";
static NSString *const kChartboostPlacementID = @"b5ee89f1a7eaf2";
static NSString *const kVunglePlacementID = @"b5ee89f3e63d80";
static NSString *const kAdColonyPlacementID = @"b5ee89f4d1791e";

NSString *const kBannerShownNotification = @"banner_shown";
NSString *const kBannerLoadingFailedNotification = @"banner_failed_to_load";
@interface ATBannerViewController ()<ATBannerDelegate>
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*>* placementIDs;
@property(nonatomic, readonly) UIActivityIndicatorView *loadingView;
@property(nonatomic, readonly) UIButton *reloadADButton;
@property(nonatomic, readonly) UIButton *clearAdButton;
@property(nonatomic, readonly) UIButton *showAdButton;
@property(nonatomic, readonly) UILabel *failureTipsLabel;
@property(nonatomic, readonly) UIButton *removeAdButton;
@property(nonatomic, weak) UIView *bannerView;
@property(nonatomic, weak) UIView *embededView;
@property(nonatomic, readonly) UIButton *readyButton;
@property(nonatomic, readonly) CGSize adSize;
@end

@implementation ATBannerViewController
-(instancetype) initWithPlacementName:(NSString*)name {
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil) {
        _name = name;
        _placementIDs = @{
                          kGDTPlacement:kGDTPlacementID,
                          kTTPlacementName:kTTPlacementID,
                          kAdMobPlacement:kAdmobPlacementID,
                          kApplovinPlacement:kApplovinPlacementID,
                          kFacebookPlacement:kFacebookPlacementID,
                          kMopubPlacementName:kMopubPlacementID,
                          kFlurryPlacement:kFlurryPlacementID,
                          kInmobiPlacement:kInmobiPlacementID,
                          kAllPlacementName:kAllPlacementID,
                          kYeahmobiPlacement:kYeahmobiPlacementID,
                          kAppnextPlacement:kAppnextPlacementID,
                          kBaiduPlacement:kBaiduPlacementID,
                          kUnityAdsPlacementName:kUnityAdsPlacementID,
                          kNendPlacement:kNendPlacementID,
                          kMintegralPlacement:kMintegralPlacementID,
                          kHeaderBiddingPlacement:kBannerHeaderBiddingPlacementID,
                          kFyberPlacement:kFyberPlacementID,
                          kStartAppPlacement:kStartAppPlacementID,
                          kVunglePlacementName:kVunglePlacementID,
                          kChartboostPlacementName:kChartboostPlacementID,
                          kAdcolonyPlacementName:kAdColonyPlacementID
                          };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = _name;
    _reloadADButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reloadADButton addTarget:self action:@selector(reloadADButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_reloadADButton setTitleColor:_reloadADButton.tintColor forState:UIControlStateNormal];
    [_reloadADButton setTitle:@"Reload AD" forState:UIControlStateNormal];
    _reloadADButton.frame = CGRectMake(.0f, CGRectGetMaxY(self.view.bounds) - 100.0f, (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_reloadADButton];
    
    _showAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_showAdButton addTarget:self action:@selector(showBanner) forControlEvents:UIControlEventTouchUpInside];
    [_showAdButton setTitleColor:_showAdButton.tintColor forState:UIControlStateNormal];
    [_showAdButton setTitle:@"Show AD" forState:UIControlStateNormal];
    _showAdButton.frame = CGRectMake(CGRectGetMaxX(_reloadADButton.frame) + 40.0f, CGRectGetMinY(_reloadADButton.frame), (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_showAdButton];
    
    _clearAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_clearAdButton addTarget:self action:@selector(clearAdButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_clearAdButton setTitleColor:_clearAdButton.tintColor forState:UIControlStateNormal];
    [_clearAdButton setTitle:@"clear cache" forState:UIControlStateNormal];
    _clearAdButton.frame = CGRectMake(.0f, CGRectGetMinY(_reloadADButton.frame) - 20.0f - 60.0f, (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_clearAdButton];
    
    _removeAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_removeAdButton addTarget:self action:@selector(removeAdButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_removeAdButton setTitleColor:_removeAdButton.tintColor forState:UIControlStateNormal];
    [_removeAdButton setTitle:@"Remove Ad" forState:UIControlStateNormal];
    _removeAdButton.frame = CGRectMake(CGRectGetMaxX(_clearAdButton.frame) + 40.0f, CGRectGetMinY(_clearAdButton.frame), (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_removeAdButton];
    
    _readyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_readyButton addTarget:self action:@selector(readyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_readyButton setTitleColor:_readyButton.tintColor forState:UIControlStateNormal];
    [_readyButton setTitle:@"Ad Ready?" forState:UIControlStateNormal];
    _readyButton.frame = CGRectMake(CGRectGetMinX(_clearAdButton.frame), CGRectGetMinY(_clearAdButton.frame) - 65.0f, (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_readyButton];
    
    _failureTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(.0f, 64.0f, CGRectGetWidth(self.view.bounds), 400.0f)];
    _failureTipsLabel.text = @"Failed to load ad";
    _failureTipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_failureTipsLabel];
    _failureTipsLabel.hidden = YES;
    
    _adSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 250.0f);
    if ([[ATAdManager sharedManager] bannerAdReadyForPlacementID:_placementIDs[_name]]) {
        NSLog(@"ATBannerViewController::banner ad ready, will show");
        [self showBanner];
    } else {
        NSLog(@"ATBannerViewController::banner ad not ready, will load");
        [self reloadADButtonTapped];
    }
}

-(void) readyButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[ATAdManager sharedManager] bannerAdReadyForPlacementID:_placementIDs[_name]] ? @"Ready!" : @"Not Yet!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) reloadADButtonTapped {
    _failureTipsLabel.hidden = YES;
    [self.view addSubview:_loadingView];
    [[ATAdManager sharedManager] loadADWithPlacementID:_placementIDs[_name] extra:@{kATAdLoadingExtraBannerAdSizeKey:[NSValue valueWithCGSize:_adSize], kATAdLoadingExtraBannerSizeAdjustKey:@NO} delegate:self];
}

-(void) removeAdButtonTapped {
    [[self.view viewWithTag:3333] removeFromSuperview];
    NSLog(@"banner removed");
}

-(void) clearAdButtonTapped {
    [[ATAdManager sharedManager] clearCache];
}

-(void) dealloc {
    NSLog(@"ATBannerViewController::dealloc");
}

-(void) showBanner {
    if ([[ATAdManager sharedManager] bannerAdReadyForPlacementID:_placementIDs[_name]]) {
        NSInteger tag = 3333;
        [[self.view viewWithTag:tag] removeFromSuperview];
        ATBannerView *bannerView = [[ATAdManager sharedManager] retrieveBannerViewForPlacementID:_placementIDs[_name]];
        bannerView.delegate = self;
        bannerView.presentingViewController = self;
        bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        bannerView.tag = tag;
        bannerView.layer.borderColor = [UIColor redColor].CGColor;
        bannerView.layer.borderWidth = .5f;
        bannerView.backgroundColor = [UIColor colorWithRed:.0f green:.0f blue:1.0f alpha:.4f];
        [self.view addSubview:bannerView];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bannerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + CGRectGetHeight(self.navigationController.navigationBar.frame)]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:_adSize.width]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:_adSize.height]];
        
//        UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth(self.view.bounds), 50.0f + 64.0f)];
//        mask.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:.4f];
//        [self.view addSubview:mask];
    } else {
        NSLog(@"Banner ad's not ready for placementID:%@", _placementIDs[_name]);
    }
}

#pragma mark - delegate method(s)
-(void) didFinishLoadingADWithPlacementID:(NSString *)placementID {
    NSLog(@"ATBannerViewController::didFinishLoadingADWithPlacementID:%@", placementID);
    [_loadingView removeFromSuperview];
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID error:(NSError*)error {
    NSLog(@"ATBannerViewController::didFailToLoadADWithPlacementID:%@ error:%@", placementID, error);
    _failureTipsLabel.hidden = NO;
#ifdef BANNER_AUTO_TEST
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerLoadingFailedNotification object:nil];
    [self.navigationController popViewControllerAnimated:NO];
#endif
}


-(void) bannerView:(ATBannerView *)bannerView failedToAutoRefreshWithPlacementID:(NSString *)placementID error:(NSError *)error {
    NSLog(@"ATBannerViewController::bannerView:failedToAutoRefreshWithPlacementID:%@ error:%@", placementID, error);
}

#pragma mark - add networkID and adsourceID delegate

-(void) bannerView:(ATBannerView*)bannerView didShowAdWithPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATBannerViewController::bannerView:didShowAdWithPlacementID:%@ with extra: %@", placementID,extra);
#ifdef BANNER_AUTO_TEST
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerShownNotification object:nil];
    [self.navigationController popViewControllerAnimated:NO];
#endif
}
-(void) bannerView:(ATBannerView*)bannerView didClickWithPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATBannerViewController::bannerView:didClickWithPlacementID:%@ with extra: %@", placementID,extra);
}
-(void) bannerView:(ATBannerView*)bannerView didCloseWithPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATBannerViewController::bannerView:didCloseWithPlacementID:%@ with extra: %@", placementID,extra);
}
-(void) bannerView:(ATBannerView*)bannerView didAutoRefreshWithPlacement:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATBannerViewController::bannerView:didAutoRefreshWithPlacement:%@ with extra: %@", placementID,extra);
}

-(void) bannerView:(ATBannerView*)bannerView didTapCloseButtonWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra {
    NSLog(@"ATBannerViewController::bannerView:didTapCloseButtonWithPlacementID:%@ extra: %@", placementID,extra);
}
@end
