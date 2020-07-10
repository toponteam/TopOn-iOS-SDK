//
//  ATMintegralRewardedVideoAdapter.m
//  AnyThinkMintegralRewardedVideoAdapter
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralRewardedVideoAdapter.h"
#import "ATMintegralRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdLoader+HeaderBidding.h"
#import "ATAppSettingManager.h"
@interface ATMintegralRewardedVideoAdapter()
@property(nonatomic, readonly) ATMintegralRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kUnitIDKey = @"unitid";
@implementation ATMintegralRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kUnitIDKey]} unitGroup:unitGroup];
}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATMintegralRewardedVideoCustomEvent *customEvent = [[ATMintegralRewardedVideoCustomEvent alloc] initWithUnitID:unitGroup.content[kUnitIDKey] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:customEvent.unitID, kAdAssetsCustomObjectKey:unitGroup.headerBidding ? [NSClassFromString(@"MTGBidRewardAdManager") sharedInstance] : [NSClassFromString(@"MTGRewardAdManager") sharedInstance], kRewardedVideoAssetsCustomEventKey:customEvent} unitGroup:unitGroup];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    if ([info[@"is_hb_adsource"] boolValue]) {
        id<ATRVMTGRewardAdManager> mgr = [NSClassFromString(@"MTGBidRewardAdManager") sharedInstance];
        return [mgr isVideoReadyToPlayWithPlacementId:info[@"placement_id"] unitId:info[kUnitIDKey]];
    } else {
        id<ATRVMTGRewardAdManager> mgr = [NSClassFromString(@"MTGRewardAdManager") sharedInstance];
        return [mgr isVideoReadyToPlayWithPlacementId:info[@"placement_id"] unitId:info[kUnitIDKey]];
    }
    
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    id<ATRVMTGRewardAdManager> mgr = [[customObject class] sharedInstance];
    return [mgr isVideoReadyToPlayWithPlacementId:info[@"placement_id"] unitId:info[kUnitIDKey]];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATMintegralRewardedVideoCustomEvent *customEvent = (ATMintegralRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [rewardedVideo.customObject showVideoWithPlacementId:rewardedVideo.unitGroup.content[@"placement_id"] unitId:rewardedVideo.unitGroup.content[kUnitIDKey] withRewardId:@"1" userId:[[ATAdManager sharedManager] extraInfoForPlacementID:rewardedVideo.placementModel.placementID requestID:rewardedVideo.requestID][kATAdLoadingExtraUserIDKey] delegate:customEvent viewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) {
                        /*
                         consentStatus: 1 Personalized, 0 Nonpersonalized
                         */
                        id<ATRVMTGSDK> mtgSDK = [NSClassFromString(@"MTGSDK") sharedInstance];
                        mtgSDK.consentStatus = !limit;
                    }
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
                };
                if ([NSThread currentThread].isMainThread) blk();
                else dispatch_sync(dispatch_get_main_queue(), blk);
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MTGBidRewardAdManager") != nil && NSClassFromString(@"MTGRewardAdManager") != nil) {
        _customEvent = [[ATMintegralRewardedVideoCustomEvent alloc] initWithUnitID:info[kUnitIDKey] customInfo:info];
        _customEvent.requestNumber = [info[@"request_num"] longValue];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
        if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
            if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:info[@"unitid"]];
            }
            id<ATMTGBidRewardAdManager> mgr = [NSClassFromString(@"MTGBidRewardAdManager") sharedInstance];
            _customEvent.rewardedVideoMgr = mgr;
            [mgr loadVideoWithBidToken:[unitGroupModel bidTokenWithRequestID:requestID] placementId:info[@"placement_id"] unitId:info[@"unitid"] delegate:_customEvent];
            [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
        } else {
            if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:info[@"unitid"]];
            }
            id<ATRVMTGRewardAdManager> mgr = [NSClassFromString(@"MTGRewardAdManager") sharedInstance];
            _customEvent.rewardedVideoMgr = mgr;
            [mgr loadVideoWithPlacementId:info[@"placement_id"] unitId:info[@"unitid"] delegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mintegral"]}]);
    }
}
@end
