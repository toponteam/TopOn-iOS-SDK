//
//  ATNativeBannerViewController.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2019/4/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNativeBannerViewController.h"
#import "ViewController.h"
@import AnyThinkNative;

NSString *const kFacebookNativeBannerPlacement = @"Facebook(Native Banner)";

static NSString *const kMPPlacementID = @"b5c2084d12aca4";
static NSString *const kPlacement0ID = @"b5ad9ba61dcb39";
static NSString *const kInmobiPlacementID = @"b5b0f553483724";
static NSString *const kMintegralPlacementID = @"b5b0f555698607";
static NSString *const kFacebookPlacementID = @"b5b0f551340ea9";
static NSString *const kFacebookNativePlacementID = @"b5ee89fd60cddc";
static NSString *const kAdMobPlacementID = @"b5b0f55228375a";
static NSString *const kApplovinPlacementID = @"b5b0f554ec9c4e";
static NSString *const kFlurryPlacementID = @"b5b0f554166ad1";
static NSString *const kMopubPlacementID = @"b5b0f55624527a";
static NSString *const kGDTPlacementID = @"b5bacac5f73476";
static NSString *const kGDTTemplatePlacementID = @"b5bacac780e03b";
static NSString *const kMopubVideoPlacementID = @"b5afbe325b1303";
static NSString *const kYeahmobiPlacementID = @"b5bc7fb1d0b02f";
static NSString *const kAppnextPlacementID = @"b5bc7fb2787f1e";
static NSString *const kAllPlacementID = @"b5b0f5663c6e4a";
static NSString *const kTTFeedPlacementID = @"b5c2c6d50e7f44";
static NSString *const kTTDrawPlacementID = @"b5c2c6d62b9d65";
static NSString *const kNendPlacementID = @"b5cb96d44c0c5f";
static NSString *const kMaioPlacementID = @"b5cb96d44c0c5f";
static NSString *const kKSPlacementID = @"b5e4613e50cbf2";




@interface ATNativeBannerViewController ()<ATNativeBannerDelegate>
@property(nonatomic, readonly) NSDictionary *placementIDs;
@property(nonatomic, readonly) NSString *placementID;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) UIButton *reloadADButton;
@property(nonatomic, readonly) UIButton *clearAdButton;
@property(nonatomic, readonly) UIButton *showAdButton;
@property(nonatomic, readonly) UIButton *removeAdButton;
@property(nonatomic, readonly) UIButton *readyButton;
@end

@implementation ATNativeBannerViewController
-(instancetype) initWithPlacementName:(NSString*)name {
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil) {
        _name = name;
        _placementIDs = @{
                          kMPPlacement:kMPPlacementID,
                          kMintegralPlacement:kMintegralPlacementID,
                          kAllPlacementName:kAllPlacementID,
                          kInmobiPlacement:kInmobiPlacementID,
                          kFacebookNativeBannerPlacement:kFacebookNativePlacementID,
                          kFacebookPlacement:kFacebookPlacementID,
                          kAdMobPlacement:kAdMobPlacementID,
                          kMopubPlacementName:kMopubPlacementID,
                          kMopubVideoPlacementName:kMopubVideoPlacementID,
                          kApplovinPlacement:kApplovinPlacementID,
                          kFlurryPlacement:kFlurryPlacementID,
                          kGDTPlacement:kGDTPlacementID,
                          kGDTTemplatePlacement:kGDTTemplatePlacementID,
                          kYeahmobiPlacement:kYeahmobiPlacementID,
                          kAppnextPlacement:kAppnextPlacementID,
                          kTTFeedPlacementName:kTTFeedPlacementID,
                          kTTDrawPlacementName:kTTDrawPlacementID,
                          kNendPlacement:kNendPlacementID,
                          kKSPlacement:kKSPlacementID,
                          };
        _placementID = _placementIDs[_name];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _name;
    self.view.backgroundColor = [UIColor whiteColor];
    _reloadADButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reloadADButton addTarget:self action:@selector(reloadADButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_reloadADButton setTitleColor:_reloadADButton.tintColor forState:UIControlStateNormal];
    [_reloadADButton setTitle:@"Reload AD" forState:UIControlStateNormal];
    _reloadADButton.frame = CGRectMake(.0f, CGRectGetMaxY(self.view.bounds) - 100.0f, (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_reloadADButton];
    
    _showAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_showAdButton addTarget:self action:@selector(showAd) forControlEvents:UIControlEventTouchUpInside];
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
    
    if ([ATNativeBannerWrapper nativeBannerAdReadyForPlacementID:_placementID]) {
        [self showAd];
    } else {
        [ATNativeBannerWrapper loadNativeBannerAdWithPlacementID:_placementID extra:@{kExtraInfoNativeAdSizeKey:[NSValue valueWithCGSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 120.0f)]} customData:nil delegate:self];
    }
}

-(void) readyButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[ATNativeBannerWrapper nativeBannerAdReadyForPlacementID:_placementID] ? @"Ready!" : @"Not Yet!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) reloadADButtonTapped {
    [ATNativeBannerWrapper loadNativeBannerAdWithPlacementID:_placementID extra:@{kExtraInfoNativeAdSizeKey:[NSValue valueWithCGSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 120.0f)]} customData:nil delegate:self];
}

-(void) removeAdButtonTapped {
    [[self.view viewWithTag:3333] removeFromSuperview];
    NSLog(@"banner removed");
}

-(void) clearAdButtonTapped {
    [[ATAdManager sharedManager] clearCache];
}


-(void) showAd {
    ATNativeBannerView *bannerView = [ATNativeBannerWrapper retrieveNativeBannerAdViewWithPlacementID:_placementID extra:@{kATNativeBannerAdShowingExtraAdSizeKey:[NSValue valueWithCGSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 120.0f)], kATNativeBannerAdShowingExtraAutorefreshIntervalKey:@10.0f, kATNativeBannerAdShowingExtraHideCloseButtonFlagKey:@NO, kATNativeBannerAdShowingExtraCTAButtonBackgroundColorKey:[UIColor redColor], kATNativeBannerAdShowingExtraCTAButtonTitleColorKey:[UIColor whiteColor], kATNativeBannerAdShowingExtraCTAButtonTitleFontKey:[UIFont systemFontOfSize:12.0f], kATNativeBannerAdShowingExtraTitleColorKey:[UIColor grayColor], kATNativeBannerAdShowingExtraTitleFontKey:[UIFont systemFontOfSize:12.0f], kATNativeBannerAdShowingExtraTextColorKey:[UIColor lightGrayColor], kATNativeBannerAdShowingExtraTextFontKey:[UIFont systemFontOfSize:10.0f], kATNativeBannerAdShowingExtraBackgroundColorKey:[UIColor whiteColor], kATNativeBannerAdShowingExtraAdvertiserTextFontKey:[UIFont systemFontOfSize:12.0f], kATNativeBannerAdShowingExtraAdvertiserTextColorKey:[UIColor lightGrayColor]} delegate:self];
    bannerView.tag = 3333;
    bannerView.frame = CGRectMake(.0f, 100.0f, CGRectGetWidth(bannerView.bounds), CGRectGetHeight(bannerView.bounds));
    bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:bannerView];
}
#pragma mark - native banner delegate(s)
-(void) didFinishLoadingNativeBannerAdWithPlacementID:(NSString *)placementID {
    NSLog(@"ATNativeBannerViewController::didFinishLoadingNativeBannerAdWithPlacementID:%@", placementID);
    if ([self.view viewWithTag:3333] == nil) { [self showAd]; }
}

-(void) didFailToLoadNativeBannerAdWithPlacementID:(NSString*)placementID error:(NSError*)error {
    NSLog(@"ATNativeBannerViewController::didFailToLoadNativeBannerAdWithPlacementID:%@ error:%@", placementID, error);
}

-(void) didShowNativeBannerAdInView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATNativeBannerViewController::didShowNativeBannerAdInView:%@ placementID:%@ with extra: %@",bannerView, placementID,extra);
}

-(void) didClickNativeBannerAdInView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATNativeBannerViewController::didClickNativeBannerAdInView:%@ placementID:%@ with extra: %@",bannerView, placementID,extra);
}

-(void) didClickCloseButtonInNativeBannerAdView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATNativeBannerViewController::didClickCloseButtonInNativeBannerAdView:%@ placementID:%@ extra:%@", bannerView, placementID, extra);
}

-(void) didAutorefreshNativeBannerAdInView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATNativeBannerViewController::didAutorefreshNativeBannerAdInView:%@ placementID:%@ with extra: %@",bannerView, placementID,extra);
}

-(void) didFailToAutorefreshNativeBannerAdInView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra error:(NSError*)error {
    NSLog(@"ATNativeBannerViewController::didFailToAutorefreshNativeBannerAdInView:%@ placementID:%@ error:%@", bannerView, placementID, error);
}
@end
