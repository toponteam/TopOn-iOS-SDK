//
//  ATBaiduRewardedVideoAdapter.m
//  AnyThinkBaiduRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBaiduRewardedVideoAdapter.h"
#import "ATBaiduRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
@interface ATBaiduRewardedVideoAdapter()
@property(nonatomic, readonly) ATBaiduRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATBaiduMobAdRewardVideo> rewardedVideo;
@end

@implementation ATBaiduRewardedVideoAdapter
//+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
//    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"ad_place_id"]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//}

+(BOOL) adReadyWithCustomObject:(id<ATBaiduMobAdRewardVideo>)customObject info:(NSDictionary*)info {
    return [customObject isReady];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATBaiduRewardedVideoCustomEvent *customEvent = (ATBaiduRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [rewardedVideo.customObject showFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameBaidu];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameBaidu]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameBaidu];
                id<BaiduMobAdSetting> setting = [NSClassFromString(@"BaiduMobAdSetting") sharedInstance];
                setting.supportHttps = YES;
                [NSClassFromString(@"BaiduMobAdSetting") setMaxVideoCacheCapacityMb:30];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BaiduMobAdRewardVideo") != nil) {
        _customEvent = [[ATBaiduRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        _rewardedVideo = [[NSClassFromString(@"BaiduMobAdRewardVideo") alloc] init];
        _rewardedVideo.delegate = _customEvent;
        _rewardedVideo.AdUnitTag = serverInfo[@"ad_place_id"];
        _rewardedVideo.publisherId = serverInfo[@"app_id"];
        [_rewardedVideo load];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Baidu"]}]);
    }
}
@end
