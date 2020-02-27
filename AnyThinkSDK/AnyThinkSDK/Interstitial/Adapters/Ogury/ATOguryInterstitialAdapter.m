//
//  ATOguryInterstitialAdapter.m
//  AnyThinkOguryInterstitialAdapter
//
//  Created by Topon on 2019/11/27.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "ATOguryInterstitialAdapter.h"
#import "ATOguryInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import <objc/runtime.h>
#import "ATAdManager+Interstitial.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"

static NSString *const kOguryInterstitialClassName = @"OguryAdsInterstitial";
@interface ATOguryInterstitialAdapter ()
@property (nonatomic,readonly) id<ATOguryAdsInterstitial> interstitial;
@property (nonatomic,readonly) ATOguryInterstitialCustomEvent *customEvent;
@property (nonatomic) NSDictionary *adInfo;
@property (nonatomic,copy) void (^complet)(NSArray<NSDictionary *> *, NSError *);
@property (nonatomic,assign) BOOL isReload;
@property (nonatomic)id<ATOguryAds> ad;
@end

@implementation ATOguryInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATOguryAdsInterstitial>)customObject info:(NSDictionary*)info {
    return ((id<ATOguryAdsInterstitial>)customObject).isLoaded;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((id<ATOguryAdsInterstitial>)interstitial.customObject) showInViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if(self != nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameOgury]) {
                    [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameOgury];
                    _ad = [NSClassFromString(@"OguryAds") shared];
                    [_ad setupWithAssetKey:info[@"key"]];
                    if ([[(NSObject*)_ad valueForKey:@"state"]intValue] == 1) {
                        [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameOgury];
                    }
                    [(NSObject*)_ad addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
                }
            });
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NSClassFromString(kOguryInterstitialClassName) != nil) {
            self.adInfo = info;
            self.complet = completion;
            if ([[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameOgury] && !_isReload) {
                _isReload = YES;
                _customEvent = [[ATOguryInterstitialCustomEvent alloc] initWithUnitID:info[@"unit_id"] customInfo:info];
                _customEvent.requestCompletionBlock = completion;
                _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
                _interstitial = [[NSClassFromString(kOguryInterstitialClassName) alloc]initWithAdUnitID:info[@"unit_id"]];
                _interstitial.interstitialDelegate = _customEvent;
                _customEvent.oguryAds = _interstitial;
                [_interstitial load];
            }
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Ogury"]}]);
        }
    });
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[object valueForKey:@"state"]intValue] == 1 && !_isReload) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameOgury];
            _isReload = YES;
            _customEvent = [[ATOguryInterstitialCustomEvent alloc] initWithUnitID:self.adInfo[@"unit_id"] customInfo:self.adInfo];
            _customEvent.requestCompletionBlock = self.complet;
            _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
            _interstitial = [[NSClassFromString(kOguryInterstitialClassName) alloc]initWithAdUnitID:self.adInfo[@"unit_id"]];
            _interstitial.interstitialDelegate = _customEvent;
            _customEvent.oguryAds = _interstitial;
            [_interstitial load];
        }
    });
}

-(void) dealloc {
    [(NSObject*)_ad removeObserver:self forKeyPath:@"state"];
}
@end
