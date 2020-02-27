//
//  ATGeneralAdAgentEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2018/11/28.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGeneralAdAgentEvent.h"
#import "ATAd.h"
#import "ATPlacementSettingManager.h"
#import "ATAPI+Internal.h"
#import "ATCapsManager.h"
#import "ATAdManager+Internal.h"
#import "Utilities.h"

NSString *const kGeneralAdAgentEventExtraInfoErrorKey = @"error";
NSString *const kGeneralAdAgentEventExtraInfoNetworkFirmIDKey = @"network_firm_id";
NSString *const kGeneralAdAgentEventExtraInfoUnitGroupContentKey = @"unit_group_content";
NSString *const kGeneralAdAgentEventExtraInfoPriorityKey = @"priority";
NSString *const kGeneralAdAgentEventExtraInfoResultCodeKey = @"result_code";
NSString *const kGeneralAdAgentEventExtraInfoShortTimeoutFlagKey = @"short_timeout_flag";
NSString *const kGeneralAdAgentEventExtraInfoAutoRequestFlagKey = @"auto_request_flag";
NSString *const kGeneralAdAgentEventExtraInfoSDKCallFlagKey = @"sdk_call_flag";
NSString *const kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey = @"sdk_not_called_reason";
NSString *const kGeneralAdAgentEventExtraInfoRewardedFlagKey = @"rewarded_flag";
NSString *const kGeneralAdAgentEventExtraInfoDefaultLoadFlagKey = @"default_load";
NSString *const kATAPILoad = @"load";
NSString *const kATAPIIsReady = @"isReady";
NSString *const kATAPIShow = @"show";
static NSString *kEventKey = @"1004620";
@implementation ATGeneralAdAgentEvent
+(instancetype)sharedAgent {
    static ATGeneralAdAgentEvent *sharedEvent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEvent = [[ATGeneralAdAgentEvent alloc] init];
    });
    return sharedEvent;
}

+(NSDictionary*)apiLogInfoWithPlacementID:(NSString*)placementID format:(NSInteger)format api:(NSString*)api {
    return @{@"placement_id":[NSString stringWithFormat:@"%@", placementID],
             @"ad_type":[self adFormatStringWithFormat:format],
             @"api":[NSString stringWithFormat:@"%@", api],
             @"result":@"start"
             };
}

+(NSDictionary*)logInfoWithAd:(id<ATAd>)ad event:(NSInteger)eventType extra:(nullable NSDictionary*)extra error:(nullable NSError*)error {
    if ([self validateAd:ad event:eventType extra:extra error:error]) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:@{@"placement_id":[NSString stringWithFormat:@"%@", ad.placementModel.placementID],
                                                                                    @"ad_type":[self adFormatStringWithFormat:ad.placementModel.format],
                                                                                    @"action":[self actionStringWithEventType:eventType],
                                                                                    @"postion":@(ad.priority),
                                                                                    @"adsource_id":ad.unitGroup.unitID != nil ? ad.unitGroup.unitID : @"",
                                                                                    @"network":[self networkNameWithNetworkFirmID:ad.unitGroup.networkFirmID],
                                                                                    @"sdk_version":[[ATAPI sharedInstance] versionForNetworkFirmID:ad.unitGroup.networkFirmID] != nil ? [[ATAPI sharedInstance] versionForNetworkFirmID:ad.unitGroup.networkFirmID] : @"",
                                                                                    @"network_unit_info":ad.unitGroup.content != nil ? ad.unitGroup.content : @{},
                                                                                    @"hourly_frequency":@([[ATCapsManager sharedManager] capByHourWithPlacementID:ad.placementModel.placementID unitGroupID:ad.unitGroup.unitGroupID requestID:ad.requestID]),
                                                                                    @"daily_frequency":@([[ATCapsManager sharedManager] capByDayWithPlacementID:ad.placementModel.placementID unitGroupID:ad.unitGroup.unitGroupID requestID:ad.requestID]),
                                                                                    @"network_list":[self networksInAd:ad],
                                                                                    @"request_network_num":@(ad.placementModel.maxConcurrentRequestCount),
                                                                                    @"refresh":@([extra[kAdLoadingExtraRefreshFlagKey] boolValue] ? 1 : 0),
                                                                                    @"result":[self eventStringWithEvent:eventType]
                                                                                    }];
        if (error != nil) { info[@"msg"] = error; }
        return info;
    } else {
        return @{};
    }
}

+(NSArray<NSString*>*)networksInAd:(id<ATAd>)ad {
    NSMutableArray<NSString*>* nws = [NSMutableArray<NSString*> array];
    NSArray<ATUnitGroupModel*>* unitGroups = nil;
    if ([ad.placementModel.headerBiddingUnitGroups count] > 0) { unitGroups = [ad.placementModel unitGroupsForRequestID:ad.requestID]; }
    unitGroups = [unitGroups count] > 0 ? unitGroups : ad.placementModel.unitGroups;
    [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [nws addObject:[self networkNameWithNetworkFirmID:obj.networkFirmID]];
    }];
    return nws;
}

+(BOOL) validateAd:(id<ATAd>)ad event:(NSInteger)eventType extra:(nullable NSDictionary*)extra error:(nullable NSError*)error {
    return ([ad conformsToProtocol:@protocol(ATAd)] && (extra == nil || [extra isKindOfClass:[NSDictionary class]]) && (error == nil || [error isKindOfClass:[NSError class]]));
}

+(NSString*)eventStringWithEvent:(NSInteger)event {
    NSDictionary<NSNumber*, NSString*>* eventMap = @{@(ATGeneralAdAgentEventTypeRequest):@"start",
                                                     @(ATGeneralAdAgentEventTypeRequestSuccess):@"success",
                                                     @(ATGeneralAdAgentEventTypeRequestFailure):@"fail",
                                                     @(ATGeneralAdAgentEventTypeImpression):@"success",
                                                     @(ATGeneralAdAgentEventTypeClick):@"success",
                                                     @(ATGeneralAdAgentEventTypeClose):@"success",
                                                     };
    return eventMap[@(event)] != nil ? eventMap[@(event)] : @"";
}

+(NSString*)networkNameWithNetworkFirmID:(NSInteger)nwFirmID {
    return [ATAPI networkNameMap][@(nwFirmID)] != nil ? [ATAPI networkNameMap][@(nwFirmID)] : @"";
}

+(NSString*)actionStringWithEventType:(NSInteger)eventType {
    NSDictionary<NSNumber*, NSString*>* actionMap = @{@(ATGeneralAdAgentEventTypeRequest):@"request", @(ATGeneralAdAgentEventTypeRequestSuccess):@"request_result", @(ATGeneralAdAgentEventTypeRequestFailure):@"request_result", @(ATGeneralAdAgentEventTypeImpression):@"impression", @(ATGeneralAdAgentEventTypeClick):@"click", @(ATGeneralAdAgentEventTypeClose):@"close", @(ATGeneralAdAgentEventTypeBannerVisible):@"banner_visible", @(ATGeneralAdAgentEventTypeBannerLeaveApp):@"banner_leave_app", @(ATGeneralAdAgentEventTypeBannerPresentScreen):@"banner_present_screen"};
    return actionMap[@(eventType)] != nil ? actionMap[@(eventType)] : @"";
}

+(NSString*)adFormatStringWithFormat:(NSInteger)format {
    NSDictionary<NSNumber*, NSString*>* formatMap = @{@0:@"native", @1:@"reward", @2:@"banner", @3:@"inter", @4:@"splash"};
    return formatMap[@(format)] != nil ? formatMap[@(format)] : @"";
}
@end

@interface ATPlacementholderAd()
@end

@implementation ATPlacementholderAd
+(instancetype)placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATPlacementholderAd alloc] initWithPlacementModel:placementModel requestID:requestID unitGroup:unitGroup];
}

-(instancetype) initWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    self = [super init];
    if (self != nil) {
        _showTimes = 0;
        NSArray<ATUnitGroupModel*>* unitGroups = [placementModel unitGroupsForRequestID:requestID];
        unitGroups = [unitGroups count] > 0 ? unitGroups : placementModel.unitGroups;
        _priority = [unitGroups indexOfObject:unitGroup];
        _placementModel = placementModel;
        _requestID = requestID;
        _cacheDate = [NSDate date];
        _unitGroup = unitGroup;
        _unitID = placementModel.placementID;
    }
    return self;
}
@end
