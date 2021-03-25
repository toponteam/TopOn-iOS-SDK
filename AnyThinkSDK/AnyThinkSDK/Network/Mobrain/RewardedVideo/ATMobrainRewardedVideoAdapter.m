//
//  ATMobrainRewardedVideoAdapter.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainRewardedVideoAdapter.h"
#import "ATMobrainRewardedVideoCustomEvent.h"
#import "ATMobrainRewardedVideoApis.h"
#import "ATMobrainBaseManager.h"
#import "ATAdManager+RewardedVideo.h"

@interface ATMobrainRewardedVideoAdapter ()
@property(nonatomic, readonly) ATMobrainRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATABURewardedVideoAd> rvAd;
@end

@implementation ATMobrainRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return customObject != nil;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATMobrainRewardedVideoCustomEvent *customEvent = (ATMobrainRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [((id<ATABURewardedVideoAd>)rewardedVideo.customObject) showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMobrainBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"ABURewardedVideoModel") != nil && NSClassFromString(@"ABURewardedVideoAd") != nil) {
        _customEvent = [[ATMobrainRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        
        NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[serverInfo[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        id<ATABURewardedVideoModel> model = [[NSClassFromString(@"ABURewardedVideoModel") alloc] init];
        if (localInfo[kATAdLoadingExtraUserIDKey] != nil) { model.userId = localInfo[kATAdLoadingExtraUserIDKey]; }
        if (localInfo[kATAdLoadingExtraMediaExtraKey] != nil) { model.extra = localInfo[kATAdLoadingExtraMediaExtraKey]; }
        if (localInfo[kATAdLoadingExtraRewardNameKey] != nil) { model.rewardName = localInfo[kATAdLoadingExtraRewardNameKey]; }
        if (localInfo[kATAdLoadingExtraRewardAmountKey] != nil) { model.rewardAmount = [localInfo[kATAdLoadingExtraRewardAmountKey] integerValue]; }
        
        _rvAd = [[NSClassFromString(@"ABURewardedVideoAd") alloc] initWithAdUnitID:serverInfo[@"slot_id"] rewardedVideoModel:model];
        _rvAd.getExpressAdIfCan = [slotInfo[@"common"][@"ad_style_type"] boolValue];
        _rvAd.delegate = _customEvent;
        
        __weak typeof(self) weakself = self;
        if (_rvAd.hasAdConfig) {
            [_rvAd loadAdData];
        } else {
            [_rvAd setConfigSuccessCallback:^{
                [weakself.rvAd loadAdData];
            }];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mobrain"]}]);
    }
}

@end
