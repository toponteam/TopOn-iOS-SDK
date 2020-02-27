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
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"ad_place_id"]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id<ATBaiduMobAdRewardVideo>)customObject info:(NSDictionary*)info {
    return [customObject isReady];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATBaiduRewardedVideoCustomEvent *customEvent = (ATBaiduRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [rewardedVideo.customObject showFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
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

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BaiduMobAdRewardVideo") != nil) {
        _customEvent = [[ATBaiduRewardedVideoCustomEvent alloc] initWithUnitID:info[@"ad_place_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        _rewardedVideo = [[NSClassFromString(@"BaiduMobAdRewardVideo") alloc] init];
        _rewardedVideo.delegate = _customEvent;
        _rewardedVideo.AdUnitTag = info[@"ad_place_id"];
        _rewardedVideo.publisherId = info[@"app_id"];
        [_rewardedVideo load];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Baidu"]}]);
    }
}
@end
