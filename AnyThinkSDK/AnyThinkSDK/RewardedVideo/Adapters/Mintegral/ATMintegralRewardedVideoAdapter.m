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
#import "ATAppSettingManager.h"
#import "ATBidInfo.h"
#import "ATBidInfoManager.h"
@interface ATMintegralRewardedVideoAdapter()
@property(nonatomic, readonly) ATMintegralRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kUnitIDKey = @"unitid";
static NSString *const kATMintegralPluginNumber = @"Y+H6DFttYrPQYcIeicKwJQKQYrN=";//topon的渠道号
@implementation ATMintegralRewardedVideoAdapter
+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
    return @{@"display_manager_ver":[NSClassFromString(@"MTGSDK") sdkVersion],
             @"unit_id":unitGroupModel.content[@"unitid"] != nil ? unitGroupModel.content[@"unitid"] : @"",
             @"app_id":unitGroupModel.content[@"appid"] != nil ? unitGroupModel.content[@"appid"] : @"",
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"buyeruid":[NSClassFromString(@"MTGBiddingSDK") buyerUID] != nil ? [NSClassFromString(@"MTGBiddingSDK") buyerUID] : @"",
             @"ad_format":@(ATAdFormatRewardedVideo).stringValue
    };
}

+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
        [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
        void(^blk)(void) = ^{
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMintegral]) {
                NSDictionary *consent = [ATAPI sharedInstance].networkConsentInfo[kNetworkNameMintegral];
                if ([consent isKindOfClass:[NSDictionary class]]) {
                    [consent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        [[NSClassFromString(@"MTGSDK") sharedInstance] setUserPrivateInfoType:[key integerValue] agree:[obj boolValue]];
                    }];
                }
            } else {
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) {
                    /*
                     consentStatus: 1 Personalized, 0 Nonpersonalized
                     */
                    id<ATRVMTGSDK> mtgSDK = [NSClassFromString(@"MTGSDK") sharedInstance];
                    mtgSDK.consentStatus = !limit;
                }
            }
            Class class = NSClassFromString(@"MTGSDK");
            SEL selector = NSSelectorFromString(@"setChannelFlag:");
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if ([class respondsToSelector:selector]) {
                    [class performSelector:selector withObject:kATMintegralPluginNumber];
                }
            #pragma clang diagnostic pop
            
            [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
        };
        if ([NSThread mainThread]) blk();
        else dispatch_sync(dispatch_get_main_queue(), blk);
    }
    
    if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:2 unitId:info[@"unitid"]]; }
    [NSClassFromString(@"MTGBiddingRequest") getBidWithRequestParameter:[[NSClassFromString(@"MTGBiddingRequestParameter") alloc] initWithPlacementId:info[@"placement_id"] unitId:info[@"unitid"] basePrice:@0] completionHandler:^(id<ATMTGBiddingResponse> bidResponse) {
        if (completion != nil) { completion(bidResponse.success ? [ATBidInfo bidInfoWithPlacementID:placementModel.placementID unitGroupUnitID:unitGroupModel.unitID token:bidResponse.bidToken price:bidResponse.price expirationInterval:unitGroupModel.bidTokenTime customObject:bidResponse] : nil, bidResponse.success ? nil : (bidResponse.error != nil ? bidResponse.error : [NSError errorWithDomain:@"com.anythink.MTGInterstitialHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"MTGSDK has failed to get bid info"}])); }
    }];
}

//+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
//    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kUnitIDKey]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    ATMintegralRewardedVideoCustomEvent *customEvent = [[ATMintegralRewardedVideoCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:customEvent.unitID, kAdAssetsCustomObjectKey:unitGroup.headerBidding ? [NSClassFromString(@"MTGBidRewardAdManager") sharedInstance] : [NSClassFromString(@"MTGRewardAdManager") sharedInstance], kRewardedVideoAssetsCustomEventKey:customEvent} unitGroup:unitGroup finalWaterfall:finalWaterfall];
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

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMintegral]) {
                        NSDictionary *consent = [ATAPI sharedInstance].networkConsentInfo[kNetworkNameMintegral];
                        if ([consent isKindOfClass:[NSDictionary class]]) {
                            [consent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                [[NSClassFromString(@"MTGSDK") sharedInstance] setUserPrivateInfoType:[key integerValue] agree:[obj boolValue]];
                            }];
                        }
                    } else {
                        BOOL set = NO;
                        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                        if (set) {
                            /*
                             consentStatus: 1 Personalized, 0 Nonpersonalized
                             */
                            id<ATRVMTGSDK> mtgSDK = [NSClassFromString(@"MTGSDK") sharedInstance];
                            mtgSDK.consentStatus = !limit;
                        }
                    }
                    Class class = NSClassFromString(@"MTGSDK");
                    SEL selector = NSSelectorFromString(@"setChannelFlag:");
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        if ([class respondsToSelector:selector]) {
                            [class performSelector:selector withObject:kATMintegralPluginNumber];
                        }
                    #pragma clang diagnostic pop
                    
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:serverInfo[@"appid"] ApiKey:serverInfo[@"appkey"]];
                };
                if ([NSThread mainThread]) blk();
                else dispatch_sync(dispatch_get_main_queue(), blk);
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MTGBidRewardAdManager") != nil && NSClassFromString(@"MTGRewardAdManager") != nil) {
        _customEvent = [[ATMintegralRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestNumber = [serverInfo[@"request_num"] longValue];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
        NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
        ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
        if (bidInfo != nil) {
            if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:serverInfo[@"unitid"]];
            }
            
            if (bidInfo.nURL != nil) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
            
            id<ATMTGBidRewardAdManager> mgr = [NSClassFromString(@"MTGBidRewardAdManager") sharedInstance];
            _customEvent.rewardedVideoMgr = mgr;
            _customEvent.price = bidInfo.price;
            [mgr loadVideoWithBidToken:bidInfo.bidId placementId:serverInfo[@"placement_id"] unitId:serverInfo[@"unitid"] delegate:_customEvent];
            [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
        } else {
            if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:serverInfo[@"unitid"]];
            }
            id<ATRVMTGRewardAdManager> mgr = [NSClassFromString(@"MTGRewardAdManager") sharedInstance];
            _customEvent.rewardedVideoMgr = mgr;
            [mgr loadVideoWithPlacementId:serverInfo[@"placement_id"] unitId:serverInfo[@"unitid"] delegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mintegral"]}]);
    }
}

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    return content[@"unitid"];
}

@end
