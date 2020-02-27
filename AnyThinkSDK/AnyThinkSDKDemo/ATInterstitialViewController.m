//
//  ATInterstitialViewController.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialViewController.h"
@import AnyThinkSDK;
@import AnyThinkInterstitial;

NSString *const kMintegralVideoPlacement = @"Mintegral(Video)";
NSString *const kTTVideoPlacement = @"TT(Video)";
NSString *const kNendInterstitialVideoPlacement = @"Nend(Video)";
NSString *const kNendFullScreenInterstitialPlacement = @"Nend(Full Screen)";
NSString *const kHeaderBiddingPlacement = @"Header Bidding";

static NSString *const kGDTPlacementID = @"b5bacad8ea3036";
static NSString *const kTTPlacementID = @"b5bacad7373b89";
static NSString *const kTTVideoPlacementID = @"b5bacad80a0fb1";
static NSString *const kAdmobPlacementID = @"b5bacad6860972";
static NSString *const kMintegralPlacementID = @"b5bacad46a8bbb";
static NSString *const kMintegralVideoPlacementID = @"b5bacad5962e84";
static NSString *const kMintegralHeaderBiddingPlacementID = @"b5d13340a1dd21";
static NSString *const kApplovinPlacementID = @"b5bacad34e4294";
static NSString *const kFacebookPlacementID = @"b5baf4bf9829e4";
static NSString *const kFacebookHeaderBiddingPlacementID = @"b5d133421525a6";
static NSString *const kAllPlacementID = @"b5bacad26a752a";
static NSString *const kOnewayPlacementID = @"b5baf65b3b8631";
static NSString *const kInmobiPlacementID = @"b5baf524062aca";
static NSString *const kFlurryPlacementID = @"b5baf52ed8b418";
static NSString *const kMopubPlacementID = @"b5baf56f03dbe9";
static NSString *const kChartboostPlacementID = @"b5baf5cd422553";
static NSString *const kTapjoyPlacementID = @"b5baf5ebe8df89";
static NSString *const kIronsourcePlacementID = @"b5baf617891a2e";
static NSString *const kVunglePlacementID = @"b5baf61edafdbb";
static NSString *const kAdColonyPlacementID = @"b5baf620280a65";
static NSString *const kYeahmobiPlacementID = @"b5bc7fb8d54acc";
static NSString *const kAppnextPlacementID = @"b5bc7fb9cbfff1";
static NSString *const kBaiduPlacementID = @"b5c04ddc6ba49e";
static NSString *const kUnityAdsPlacementID = @"b5c21a055a51ab";
static NSString *const kNendPlacementID = @"b5cb96db9b3b0f";
static NSString *const kNendVideoPlacementID = @"b5cb96dd930c57";
static NSString *const kNendFullScreenPlacementID = @"b5cb96df0f1914";
static NSString *const kMaioPlacementID = @"b5cb96cf795c4b";
static NSString *const kSigmobPlacementID = @"b5d771f79e4a32";
static NSString *const kKSPlacementID = @"b5d807a4846f50";
static NSString *const kMyOfferPlacementID = @"b5db6c26999c31";
static NSString *const kOguryPlacementID = @"b5dde238f2d2ce";

@interface ATInterstitialViewController ()<ATInterstitialDelegate>
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*>* placementIDs;
@property(nonatomic, readonly) UIActivityIndicatorView *loadingView;
@property(nonatomic, readonly) UILabel *failureTipsLabel;
@property(nonatomic, readonly) UIButton *reloadADButton;
@property(nonatomic, readonly) UIButton *clearAdButton;
@property(nonatomic, readonly) UIButton *showAdButton;
@property(nonatomic, readonly) UIButton *removeAdButton;
@end

@implementation ATInterstitialViewController
-(instancetype) initWithPlacementName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
        _placementIDs = @{
                          kGDTPlacement:kGDTPlacementID,
                          kTTPlacementName:kTTPlacementID,
                          kTTVideoPlacement:kTTVideoPlacementID,
                          kAdMobPlacement:kAdmobPlacementID,
                          kMintegralPlacement:kMintegralPlacementID,
                          kMintegralVideoPlacement:kMintegralVideoPlacementID,
                          kHeaderBiddingPlacement:kMintegralHeaderBiddingPlacementID,
                          kApplovinPlacement:kApplovinPlacementID,
                          kFacebookPlacement:kFacebookPlacementID,
                          kFacebookHeaderBiddingPlacement:kFacebookHeaderBiddingPlacementID,
                          kOnewayPlacementName:kOnewayPlacementID,
                          kInmobiPlacement:kInmobiPlacementID,
                          kFlurryPlacement:kFlurryPlacementID,
                          kMopubPlacementName:kMopubPlacementID,
                          kChartboostPlacementName:kChartboostPlacementID,
                          kTapjoyPlacementName:kTapjoyPlacementID,
                          kIronsourcePlacementName:kIronsourcePlacementID,
                          kVunglePlacementName:kVunglePlacementID,
                          kAdcolonyPlacementName:kAdColonyPlacementID,
                          kAllPlacementName:kAllPlacementID,
                          kYeahmobiPlacement:kYeahmobiPlacementID,
                          kAppnextPlacement:kAppnextPlacementID,
                          kBaiduPlacement:kBaiduPlacementID,
                          kUnityAdsPlacementName:kUnityAdsPlacementID,
                          kNendPlacement:kNendPlacementID,
                          kNendInterstitialVideoPlacement:kNendVideoPlacementID,
                          kNendFullScreenInterstitialPlacement:kNendFullScreenPlacementID,
                          kMaioPlacement:kMaioPlacementID,
                          kSigmobPlacement:kSigmobPlacementID,
                          kKSPlacement:kKSPlacementID,
                          kMyOfferPlacement:kMyOfferPlacementID,
                          kOguryPlacement:kOguryPlacementID
                          };
    }
    return self;
}

-(void) viewDidLoad {
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
    [_showAdButton addTarget:self action:@selector(showAD) forControlEvents:UIControlEventTouchUpInside];
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
    [_removeAdButton setTitle:@"Ad Ready?" forState:UIControlStateNormal];
    _removeAdButton.frame = CGRectMake(CGRectGetMaxX(_clearAdButton.frame) + 40.0f, CGRectGetMinY(_clearAdButton.frame), (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_removeAdButton];
    
    _failureTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(.0f, 64.0f, CGRectGetWidth(self.view.bounds), 400.0f)];
    _failureTipsLabel.text = @"Failed to load ad";
    _failureTipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_failureTipsLabel];
    _failureTipsLabel.hidden = YES;
}


//Ad ready?
-(void) removeAdButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[ATAdManager sharedManager] interstitialReadyForPlacementID:_placementIDs[_name]] ? @"Ready!" : @"Not Yet!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) clearAdButtonTapped {
    [[ATAdManager sharedManager] clearCache];
}

-(void) dealloc {
    NSLog(@"dealloc");
}

-(void) reloadADButtonTapped {
    NSLog(@"Begin loading interstitial ad");
    _failureTipsLabel.hidden = YES;
    [self.view addSubview:_loadingView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[ATAdManager sharedManager] loadADWithPlacementID:_placementIDs[_name] extra:nil delegate:self];
    });
}

-(void) showAD {
    [[ATAdManager sharedManager] showInterstitialWithPlacementID:_placementIDs[_name] scene:@"f5e549727efc49" inViewController:self delegate:self];
}

#pragma mark - delegate method(s)
-(void) didFinishLoadingADWithPlacementID:(NSString *)placementID {
    NSLog(@"ATInterstitialViewController::didFinishLoadingADWithPlacementID:%@", placementID);
    _showAdButton.enabled = YES;
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID error:(NSError*)error {
    NSLog(@"ATInterstitialViewController::didFailToLoadADWithPlacementID:%@ error:%@", placementID, error);
}


#pragma mark - delegate with networkID and adsourceID

-(void) interstitialDidShowForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"ATInterstitialViewController::interstitialDidShowForPlacementID:%@ extra:%@", placementID, extra);
}

-(void) interstitialFailedToShowForPlacementID:(NSString*)placementID error:(NSError*)error extra:(NSDictionary *)extra {
    NSLog(@"ATInterstitialViewController::interstitialFailedToShowForPlacementID:%@ error:%@ extra:%@", placementID, error, extra);
}

-(void) interstitialDidFailToPlayVideoForPlacementID:(NSString*)placementID error:(NSError*)error extra:(NSDictionary*)extra {
    NSLog(@"ATInterstitialViewController::interstitialDidFailToPlayVideoForPlacementID:%@ error:%@ extra:%@", placementID, error, extra);
}

-(void) interstitialDidStartPlayingVideoForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra {
    NSLog(@"ATInterstitialViewController::interstitialDidStartPlayingVideoForPlacementID:%@ extra:%@", placementID, extra);
}

-(void) interstitialDidEndPlayingVideoForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra {
    NSLog(@"ATInterstitialViewController::interstitialDidEndPlayingVideoForPlacementID:%@ extra:%@", placementID, extra);
}

-(void) interstitialDidCloseForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra {
    NSLog(@"ATInterstitialViewController::interstitialDidCloseForPlacementID:%@ extra:%@", placementID, extra);
}

-(void) interstitialDidClickForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra {
    NSLog(@"ATInterstitialViewController::interstitialDidClickForPlacementID:%@ extra:%@", placementID, extra);
}
@end
