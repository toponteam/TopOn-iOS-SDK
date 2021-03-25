//
//  ATMyOfferRewardedVideoAdapter.m
//  AnyThinkMyOfferRewardedVideoAdapter
//
//  Created by Topon on 2019/10/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATMyOfferRewardedVideoCustomEvent.h"
#import "ATAgentEvent.h"
@interface  ATMyOfferRewardedVideoAdapter()
@property(nonatomic, readonly) ATMyOfferRewardedVideoCustomEvent *customEvent;

@end
@implementation ATMyOfferRewardedVideoAdapter
//+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
//    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"my_oid"]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    ATMyOfferOfferModel *offerModel = RV_FindMyOfferModel(placementModel.offers, unitGroup.content[@"my_oid"]);
    if (offerModel != nil && ![[ATMyOfferOfferManager sharedManager] checkExcludedWithOfferModel:offerModel] && [[ATMyOfferOfferManager sharedManager] resourceReadyForOfferModel:offerModel]) {
        ATMyOfferRewardedVideoCustomEvent *customEvent = [[ATMyOfferRewardedVideoCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
        ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:offerModel.offerID, kRewardedVideoAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:offerModel} unitGroup:unitGroup finalWaterfall:finalWaterfall];
        return ad;
    } else {
        return nil;
    }
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return YES;
}

+(ATMyOfferOfferModel*) resourceReadyMyOfferForPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info {
    ATMyOfferOfferModel *offerModel = RV_FindMyOfferModel(placementModel.offers, unitGroupModel.content[@"my_oid"]);
    return [[ATMyOfferOfferManager sharedManager] resourceReadyForOfferModel:offerModel] ? offerModel : nil;
}

+(BOOL) adReadyWithCustomObject:(ATMyOfferOfferModel*)customObject info:(NSDictionary*)info {
    return [[ATMyOfferOfferManager sharedManager]offerReadyForOfferModel:customObject];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATMyOfferRewardedVideoCustomEvent *customEvent = (ATMyOfferRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    customEvent.rewardedVideo = rewardedVideo;
    [[ATMyOfferOfferManager sharedManager] showRewardedVideoWithOfferModel:rewardedVideo.customObject setting:rewardedVideo.placementModel.myOfferSetting viewController:viewController delegate:customEvent];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

ATMyOfferOfferModel* RV_FindMyOfferModel(NSArray<ATMyOfferOfferModel*>* offers, NSString *offerID) {
    ATMyOfferOfferModel *offerModel = nil;
    @try {
        offerModel = offers[[[offers mutableArrayValueForKey:@"offerID"] indexOfObject:offerID]];
    } @catch (NSException *exception) {
        [ATLogger logError:[NSString stringWithFormat:@"Exception occured while finding offer with id:%@ in offers:%@", offerID, offers] type:ATLogTypeExternal];
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyCrashInfoKey placementID:nil unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoCrashReason: exception.reason, kAgentEventExtraInfoCallStackSymbols: [NSThread callStackSymbols].firstObject}];

    } @finally {
        return offerModel;
    }
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    ATMyOfferOfferModel *offerModel = RV_FindMyOfferModel(placementModel.offers, serverInfo[@"my_oid"]);
    
    _customEvent = [[ATMyOfferRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    __weak typeof(self) weakSelf = self;
    [[ATMyOfferOfferManager sharedManager] loadOfferWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:localInfo completion:^(NSError *error) {
        if (error == nil) {
            if (offerModel != nil && offerModel.offerID != nil && weakSelf.customEvent != nil) {
                [weakSelf.customEvent trackRewardedVideoAdLoaded:offerModel adExtra:nil];
            }
        }else{
            [weakSelf.customEvent trackRewardedVideoAdLoadFailed:error];
        }
    }];
}

@end
