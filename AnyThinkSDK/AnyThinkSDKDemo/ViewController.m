//
//  ViewController.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2019/10/31.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "ViewController.h"
#import "Utilities.h"
#import "ATPlacementSettingManager.h"
#import "ATAPI.h"
#import "ATNativeViewController.h"
#import "ATVideoView.h"
#import "ATRewardedVideoVideoViewController.h"
#import "ATBannerViewController.h"
#import "ATInterstitialViewController.h"
#import "ATNativeBannerViewController.h"

@import AnyThinkSplash;
@import AnyThinkNative;
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, ATSplashDelegate, ATNativeSplashDelegate>
@property(nonatomic, readonly) UITableView *tableView;
@property(nonatomic, readonly) NSArray<NSArray<NSString*>*>* placementNames;
@property(nonatomic) NSInteger currentRow;
@property(nonatomic, readonly) NSIndexPath *splashSelection;
@end

static NSString *const kCellIdentifier = @"cell";
@implementation ViewController
-(void) enterNextBanner {
#ifdef BANNER_AUTO_TEST
    if (_currentRow < [_placementNames[1] count]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:_currentRow++ inSection:1]];
        });
    } else {
        _currentRow = 0;
    }
#endif
}

-(void)getProxyStatus {
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com/"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSDictionary *settings = proxies[0];
    if (![[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]){
        //检测到连接代理
    }
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self enterNextBanner];
}

-(void) handlerBannerEvent:(NSNotification*)notification {
    [self enterNextBanner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getProxyStatus];
    /*
     extern const CGFloat FBAdOptionsViewWidth;
     extern const CGFloat FBAdOptionsViewHeight;
     */
    _placementNames = @[@[kSigmobPlacement, kGDTPlacement, kBaiduPlacement, kTTPlacementName, kAllPlacementName],
                        @[kSigmobPlacement, kMyOfferPlacement, kOguryPlacement,kKSPlacement, kHeaderBiddingPlacement, kNendPlacement, kNendInterstitialVideoPlacement, kNendFullScreenInterstitialPlacement, kMaioPlacement, kUnityAdsPlacementName, kFacebookPlacement, kAdMobPlacement, kInmobiPlacement, kFlurryPlacement, kApplovinPlacement, kMintegralPlacement, kMintegralVideoPlacement, kMopubPlacementName, kGDTPlacement, kChartboostPlacementName, kTapjoyPlacementName, kIronsourcePlacementName, kVunglePlacementName, kAdcolonyPlacementName, kTTPlacementName, kTTVideoPlacement, kOnewayPlacementName, kYeahmobiPlacement, kAppnextPlacement, kBaiduPlacement, kAllPlacementName],
                        @[kHeaderBiddingPlacement,kNendPlacement, kFacebookPlacement, kMintegralPlacement,kAdMobPlacement, kInmobiPlacement, kFlurryPlacement, kApplovinPlacement, kGDTPlacement, kMopubPlacementName, kTTPlacementName, kYeahmobiPlacement, kAppnextPlacement, kBaiduPlacement, kAllPlacementName],
                        @[kSigmobPlacement, kMyOfferPlacement, kOguryPlacement,kKSPlacement, kHeaderBiddingPlacement, kNendPlacement, kMaioPlacement, kFacebookPlacement, kAdMobPlacement, kInmobiPlacement, kFlurryPlacement, kApplovinPlacement, kMintegralPlacement, kMopubPlacementName, kGDTPlacement, kChartboostPlacementName, kTapjoyPlacementName, kIronsourcePlacementName, kVunglePlacementName, kAdcolonyPlacementName, kUnityAdsPlacementName, kTTPlacementName, kOnewayPlacementName, kYeahmobiPlacement, kAppnextPlacement, kBaiduPlacement, kAllPlacementName],
                        @[kHeaderBiddingPlacement, kNendPlacement, kNendVideoPlacement, kTTFeedPlacementName, kTTDrawPlacementName, kMPPlacement, kFacebookPlacement, kAdMobPlacement, kInmobiPlacement, kFlurryPlacement, kApplovinPlacement, kMintegralPlacement, kMopubPlacementName, kGDTPlacement, kGDTTemplatePlacement, kYeahmobiPlacement, kAppnextPlacement, kBaiduPlacement,kKSPlacement, kAllPlacementName],
                        @[kKSPlacement,kNendPlacement, kTTFeedPlacementName, kTTDrawPlacementName, kMPPlacement, kFacebookPlacement, kAdMobPlacement, kInmobiPlacement, kFlurryPlacement, kApplovinPlacement, kMintegralPlacement, kMopubPlacementName, kGDTPlacement, kGDTTemplatePlacement, kYeahmobiPlacement, kAppnextPlacement, kAllPlacementName],
                        @[kKSPlacement,kTTFeedPlacementName, kMPPlacement, kFacebookPlacement, kAdMobPlacement, kApplovinPlacement, kMintegralPlacement, kGDTPlacement, kYeahmobiPlacement, kAppnextPlacement, kAllPlacementName]];
    
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"GDPR" style:UIBarButtonItemStylePlain target:self action:@selector(policyButtonTapped)];
    self.navigationItem.rightBarButtonItem = item;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerBannerEvent:) name:kBannerShownNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerBannerEvent:) name:kBannerLoadingFailedNotification object:nil];
}


-(void)policyButtonTapped {
    [[ATAPI sharedInstance] presentDataConsentDialogInViewController:self dismissalCallback:^{
        NSLog(@"gdpr idalog dismissed");
    }];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [_placementNames count];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_placementNames[section] count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[@"Splash", @"Interstitial", @"Banner", @"RV", @"Native", @"Native Banner", @"Native Splash"][section];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.textLabel.text = _placementNames[[indexPath section]][[indexPath row]];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([indexPath section] == 3) {
        ATRewardedVideoVideoViewController *tVC = [[ATRewardedVideoVideoViewController alloc] initWithPlacementName:_placementNames[[indexPath section]][[indexPath row]]];
        [self.navigationController pushViewController:tVC animated:YES];
    } else if ([indexPath section] == 6) {
        _splashSelection = indexPath;
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kExtraInfoNativeAdTypeKey:@(ATGDTNativeAdTypeSelfRendering), kExtraInfoNativeAdSizeKey:[NSValue valueWithCGSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 300.0f)], kATExtraNativeImageSizeKey:kATExtraNativeImageSize690_388, kATNativeSplashShowingExtraCountdownIntervalKey:@3}];
        [ATNativeSplashWrapper loadNativeSplashAdWithPlacementID:[ATNativeViewController nativePlacementIDs][_placementNames[[indexPath section]][[indexPath row]]] extra:extra customData:nil delegate:self];
    } else if ([indexPath section] == 5) {
        ATNativeBannerViewController *tVC = [[ATNativeBannerViewController alloc] initWithPlacementName: _placementNames[[indexPath section]][[indexPath row]]];
        [self.navigationController pushViewController:tVC animated:YES];
    } else if ([indexPath section] == 4) {
        ATNativeViewController *tVC = [[ATNativeViewController alloc] initWithPlacementName: _placementNames[[indexPath section]][[indexPath row]]];
        [self.navigationController pushViewController:tVC animated:YES];
    } else if ([indexPath section] == 2) {
        ATBannerViewController *tVC = [[ATBannerViewController alloc] initWithPlacementName:_placementNames[[indexPath section]][[indexPath row]]];
        [self.navigationController pushViewController:tVC animated:YES];
    } else if ([indexPath section] == 1) {
        ATInterstitialViewController *tVC = [[ATInterstitialViewController alloc] initWithPlacementName:_placementNames[[indexPath section]][[indexPath row]]];
        [self.navigationController pushViewController:tVC animated:YES];
    } else if ([indexPath section] == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth([UIScreen mainScreen].bounds), 100.0f)];
        label.text = @"Splash Container View";
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;

        UILabel *skipBtn = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - 80.0f, CGRectGetMidY(self.view.bounds) - 40.0f, 160.0f, 80.0f)];
        skipBtn.text = @"Skip Button";
        skipBtn.backgroundColor = [UIColor blueColor];
        skipBtn.textAlignment = NSTextAlignmentCenter;
        UIWindow *mainWindow = nil;
        if ( @available(iOS 13.0, *) ) {
           mainWindow = [UIApplication sharedApplication].windows.firstObject;
           [mainWindow makeKeyWindow];
        } else {
            mainWindow = [UIApplication sharedApplication].keyWindow;
        }
        [[ATAdManager sharedManager] loadADWithPlacementID:@[@"b5d771f34bc73d", @"b5c1b0470c7e4a", @"b5c1b047a970fe", @"b5c1b048c498b9", @"b5c22f0e5cc7a0"][[indexPath row]] extra:@{kATSplashExtraTolerateTimeoutKey:@3.0f} customData:nil delegate:self window:mainWindow containerView:label];
    }
}

#pragma mark - native splash delegate(s)
#define PORTRAIT 1
-(void) finishLoadingNativeSplashAdForPlacementID:(NSString*)placementID {
    NSLog(@"ViewController::finishLoadingNativeSplashAdForPlacementID:%@", placementID);
#ifdef PORTRAIT
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(.0f, .0f, width, 79.0f)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor whiteColor];
    label.text = @"Joypac";
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATNatievSplashShowingExtraStyleKey:kATNativeSplashShowingExtraStylePortrait, kATNativeSplashShowingExtraCountdownIntervalKey:@3, kATNativeSplashShowingExtraContainerViewKey:label}];
    if ([kTTFeedPlacementName isEqualToString:_placementNames[[_splashSelection section]][[_splashSelection row]]]) {//for tt template
        extra[kATNativeSplashShowingExtraCTAButtonBackgroundColorKey] = [UIColor clearColor];
        extra[kATNativeSplashShowingExtraCTAButtonTitleColorKey] = [UIColor clearColor];
    }
    
    [ATNativeSplashWrapper showNativeSplashAdWithPlacementID:placementID extra:extra delegate:self];
#else
    CGFloat width = 100.0f;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - width, .0f, width, CGRectGetHeight([UIScreen mainScreen].bounds))];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor whiteColor];
    label.text = @"Joypac";
    [ATNativeSplashWrapper showNativeSplashAdWithPlacementID:placementID extra:@{kATNatievSplashShowingExtraStyleKey:kATNativeSplashShowingExtraStyleLandscape, kATNativeSplashShowingExtraCountdownIntervalKey:@3, kATNativeSplashShowingExtraContainerViewKey:label} delegate:self];
#endif
    
}

-(void) failedToLoadNativeSplashAdForPlacementID:(NSString*)placementID error:(NSError*)error {
    NSLog(@"ViewController::failedToLoadNativeSplashAdForPlacementID:%@ error:%@", placementID, error);
}

-(void) didShowNativeSplashAdForPlacementID:(NSString*)placementID {
    NSLog(@"ViewController::didShowNativeSplashAdForPlacementID:%@", placementID);
}

-(void) didClickNaitveSplashAdForPlacementID:(NSString*)placementID {
    NSLog(@"ViewController::didClickNaitveSplashAdForPlacementID:%@", placementID);
}

-(void) didCloseNativeSplashAdForPlacementID:(NSString*)placementID {
    NSLog(@"ViewController::didCloseNativeSplashAdForPlacementID:%@", placementID);
}
#pragma mark - AT Splash Delegate method(s)
-(void) didFinishLoadingADWithPlacementID:(NSString *)placementID {
    NSLog(@"ViewController::didFinishLoadingADWithPlacementID:%@", placementID);
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID error:(NSError*)error {
    NSLog(@"ViewController::didFailToLoadADWithPlacementID:%@ error:%@", placementID, error);
}

-(void)splashDidShowForPlacementID:(NSString*)placementID {
    NSLog(@"ViewController::splashDidShowForPlacementID:%@", placementID);
}

-(void)splashDidClickForPlacementID:(NSString*)placementID {
    NSLog(@"ViewController::splashDidClickForPlacementID:%@", placementID);
}

-(void)splashDidCloseForPlacementID:(NSString*)placementID {
    NSLog(@"ViewController::splashDidCloseForPlacementID:%@", placementID);
}

#pragma mark - splash delegate with networkID and adsourceID
-(void)didShowNativeSplashAdForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ViewController::splashDidShowForPlacementID:%@ with extra: %@", placementID,extra);
}

-(void)didClickNaitveSplashAdForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ViewController::splashDidClickForPlacementID:%@ with extra: %@", placementID,extra);
}

-(void)didCloseNativeSplashAdForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ViewController::splashDidCloseForPlacementID:%@ with extra: %@", placementID,extra);
}
-(void)splashDidShowForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra {
    NSLog(@"AppDelegate::splashDidShowForPlacementID:%@ with extra: %@", placementID,extra);
    
}

-(void)splashDidClickForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"AppDelegate::splashDidClickForPlacementID:%@ with extra: %@", placementID,extra);
    
}

-(void)splashDidCloseForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"AppDelegate::splashDidCloseForPlacementID:%@ with extra: %@", placementID,extra);
}
@end
