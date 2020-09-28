//
//  ATOguryRewardedVideoAdapter.m
//  AnyThinkOguryRewardedVideoAdapter
//
//  Created by Topon on 2019/11/27.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "ATOguryRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATOguryRewardedVideoCustomEvent.h"

static NSString *const kOguryRewardedVideoClassName = @"OguryAdsOptinVideo";

@interface ATOguryRewardedVideoAdapter ()
@property (nonatomic,readonly) ATOguryRewardedVideoCustomEvent *customEvent;
@property (nonatomic,readonly) id<ATOguryAdsOptinVideo> rewardedVideo;
@property (nonatomic) NSDictionary *adInfo;
@property (nonatomic) NSDictionary *localInfo;
@property (nonatomic,copy) void (^complet)(NSArray<NSDictionary *> *, NSError *);
@property (nonatomic,assign) BOOL isReload;
@property (nonatomic)id<ATOguryAds> ad;
@end
@implementation ATOguryRewardedVideoAdapter

//+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
//    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"unit_id"]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATOguryAdsOptinVideo>)customObject).isLoaded;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATOguryRewardedVideoCustomEvent *customEvent = (ATOguryRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [((id<ATOguryAdsOptinVideo>)rewardedVideo.customObject)  showInViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if(self != nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameOgury]) {
                    // to do consent with gdpr
                    [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameOgury];
                    _ad = [NSClassFromString(@"OguryAds") shared];
                    [_ad setupWithAssetKey:serverInfo[@"key"]];
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

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NSClassFromString(kOguryRewardedVideoClassName) != nil) {
            self.adInfo = serverInfo;
            self.localInfo = localInfo;
            self.complet = completion;
            if ([[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameOgury] && !_isReload) {
                _isReload = YES;
                _customEvent = [[ATOguryRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
                _customEvent.requestCompletionBlock = completion;
                _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
                _rewardedVideo = [[NSClassFromString(kOguryRewardedVideoClassName) alloc]initWithAdUnitID:serverInfo[@"unit_id"]];
                _rewardedVideo.optInVideoDelegate = _customEvent;
                _customEvent.OguryAd = _rewardedVideo;
                [_rewardedVideo load];
            }
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Ogury"]}]);
        }
    });
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[object valueForKey:@"state"]intValue] == 1 && !_isReload) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameOgury];
            _isReload = YES;
            _customEvent = [[ATOguryRewardedVideoCustomEvent alloc] initWithInfo:self.adInfo localInfo:self.localInfo];
            _customEvent.requestCompletionBlock = self.complet;
            _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
            _rewardedVideo = [[NSClassFromString(kOguryRewardedVideoClassName) alloc]initWithAdUnitID:self.adInfo[@"unit_id"]];
            _rewardedVideo.optInVideoDelegate = _customEvent;
            _customEvent.OguryAd = _rewardedVideo;
            [_rewardedVideo load];

        }
    });
}

-(void) dealloc {
    [(NSObject*)_ad removeObserver:self forKeyPath:@"state"];
}
@end
