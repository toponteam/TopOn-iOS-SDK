//
//  ATAdStorageUtility.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/2/22.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATAdStorageUtility.h"
#import "ATPlacementModel.h"
#import "ATPlacementSettingManager.h"
#import "ATCapsManager.h"
#import "ATAPI+Internal.h"
#import "ATAgentEvent.h"
#import "ATLogger.h"
#import "ATTracker.h"
#import "ATAppSettingManager.h"
#import "ATAdAdapter.h"
#import "Utilities.h"
#import "ATLoadingScheduler.h"
#import "ATAdCustomEvent.h"
#import "ATBidInfoManager.h"

// v5.7.20
#import "OFMSDKApis.h"

NSString *const kAdStorageExtraNotReadyReasonKey = @"reason";
NSString *const kAdStorageExtraNeedReloadFlagKey = @"need_reload_flag";
NSString *const kAdStorageExtraPlacementIDKey = @"placement_id";
NSString *const kAdStorageExtraRequestIDKey = @"request_id";
NSString *const kAdStorageExtraCallerInfoKey = @"caller_info";
NSString *const kAdStorageExtraReadyFlagKey = @"ready_flag";
NSString *const kAdStorageExtraPSIDKey = @"ps_id";
NSString *const kAdStorageExtraSessionIDKey = @"session_id";
NSString *const kAdStoreageExtraUnitGroupUnitID = @"unit_id";
NSString *const kAdStorageExtraNetworkFirmIDKey = @"nw_firm_id";
NSString *const kAdStorageExtraNetworkSDKVersion = @"nw_ver";
NSString *const kAdStorageExtraPriorityKey = @"priority";
NSString *const kAdStorageExtraHeaderBiddingInfo = @"header_bidding_info";
NSString *const kAdStorageExtraUnitGroupInfosKey = @"unit_group_info";
NSString *const kAdStorageExtraUnitGroupInfoContentKey = @"content";
NSString *const kAdStorageExtraUnitGroupInfoPriorityKey = @"priority";
NSString *const kAdStorageExtraUnitGroupInfoNetworkFirmIDKey = @"nw_firm_id";
NSString *const kAdStorageExtraUnitGroupInfoUnitIDKey = @"unit_id";
NSString *const kAdStorageExtraUnitGroupInfoNetworkSDKVersionKey = @"nw_ver";
NSString *const kAdStorageExtraUnitGroupInfoReadyFlagKey = @"result";
NSString *const kAdStorageExtraFinalWaterfallKey = @"final_waterfall";

@protocol ATMyOfferDefault<NSObject>
+(instancetype) sharedManager;
-(ATMyOfferOfferModel*) defaultOfferInOfferModels:(NSArray<ATMyOfferOfferModel*>*)offerModels;
@end

/*
The structure of offer storage is as follows:
{
    placement_id:{
        request_id:request_id,
        final_waterfall:finalWaterfall
        offers:{
            unit_group_id_1:[offer_1, offer_2],
            unit_group_id_2:[offer_1, offer_2],
            //Other unit groups follow.
        }
    },
    //Other placements follow.
}
*/
static NSString *const kOffersKey = @"offers";
static NSString *const kRequestIDKey = @"request_id";
static NSString *const kFinalWaterfallKey = @"final_waterfall";
@implementation ATAdStorageUtility
+(NSInteger) highestPriorityOfShownAdInStorage:(NSMutableDictionary*)storage placementID:(NSString*)placementID requestID:(NSString*)requestID {
    __block NSInteger priority = NSNotFound;
    NSString *requestIDInStorage = storage[placementID][kRequestIDKey];
    if ([requestIDInStorage isEqualToString:requestID]) {
        NSDictionary *offers = storage[placementID][kOffersKey];
        ATWaterfall *finalWaterfall = storage[placementID][kFinalWaterfallKey];
        [finalWaterfall.unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull unitGroup, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[offers[unitGroup.unitGroupID] valueForKeyPath:@"@sum.showTimes"] integerValue]> 0) {
                *stop = YES;
                priority = idx;
            }
        }];
    }
    return priority;
}

+(BOOL) lastOfferShownForPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID inStorage:(NSMutableDictionary*)storage {
    return [[storage[placementID][kOffersKey][unitGroupID] valueForKeyPath:@"@sum.showTimes"] integerValue] == [storage[placementID][kOffersKey][unitGroupID] count];
}

+(void) removeAdForPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID inStorage:(NSMutableDictionary*)storage {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATAdStorageUtility::Before clearAd: %@", storage] type:ATLogTypeInternal];
    [storage[placementID][kOffersKey] removeObjectForKey:unitGroupID];
    [ATLogger logMessage:[NSString stringWithFormat:@"ATAdStorageUtility::After clearAd: %@", storage] type:ATLogTypeInternal];
}

+(void) removeAdForPlacementID:(NSString*)placementID unitGroupModel:(ATUnitGroupModel*)unitGroupModel inStorage:(NSMutableDictionary*)storage statusStorage:(NSMutableDictionary*)statusStorage {
    [storage[placementID][kOffersKey] removeObjectForKey:unitGroupModel.unitGroupID];
    [statusStorage[placementID] removeObjectForKey:unitGroupModel.unitID];
}

/*
 *status storage
 {
     placement_id:{
         ad_source_id:[{
            status:YES/NO
            date:2019.11.14 16:07
            offer:offer
         }]
        // Other Ad Sources
     }
     // Other Placements
 }
 */
static NSString *const kStatusStorageStatusKey = @"status";
static NSString *const kStatusStorageDateKey = @"date";
static NSString *const kStatusStorageOfferKey = @"offer";
+(BOOL) validateAdSourceStatusEntry:(NSDictionary*)entry {
    return [entry[kStatusStorageStatusKey] boolValue] && [entry[kStatusStorageDateKey] timeIntervalSinceDate:[NSDate date]] > .0f;
}

+(void) renewOffersWithPlacementModel:(ATPlacementModel*)placementModel finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID inStatusStorage:(NSMutableDictionary*)statusStorage offerStorate:(NSMutableDictionary*)offerStorage extraInfo:(NSArray<NSDictionary*>*__autoreleasing*)extraInfo {
    NSMutableDictionary *placementEntry = statusStorage[placementModel.placementID];
    NSMutableArray<NSDictionary*> *extra = [NSMutableArray<NSDictionary*> array];
    if (placementEntry != nil) {
        NSArray<ATUnitGroupModel*>* activeUnitGroups = finalWaterfall.unitGroups;
        [activeUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull unitGroup, NSUInteger priority, BOOL * _Nonnull stop) {
            NSArray<NSDictionary*> *adSourceEntries = placementEntry[unitGroup.unitID];
            __block BOOL extraInfoAdded = NO;
            [adSourceEntries enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([self validateAdSourceStatusEntry:obj]) {
                    id<ATAd> ad = obj[kStatusStorageOfferKey];
                    [ad renewAdWithPriority:priority placementModel:placementModel unitGroup:unitGroup requestID:requestID];
                    [self saveAd:ad finalWaterfall:finalWaterfall toStorage:offerStorage requestID:requestID];
                    if (!extraInfoAdded) {
                        [extra addObject:@{kAgentEventExtraInfoNetworkFirmIDKey:@(ad.unitGroup.networkFirmID), kAgentEventExtraInfoAdSourceIDKey:unitGroup.unitID, kAgentEventExtraInfoPriorityKey:@(priority), kAgentEventExtraInfoOriginalRequestIDKey:ad.originalRequestID, kAgentEventExtraInfoRequestIDKey:requestID}];
                        extraInfoAdded = YES;
                    }
                }
            }];
        }];
    }
    if (extraInfo != nil) { *extraInfo = extra; }
}

+(void) invalidateStatusForAd:(id<ATAd>)ad inStatusStorage:(NSMutableDictionary*)statusStorage {
    NSMutableDictionary *placementEntry = statusStorage[ad.placementModel.placementID];
    if (placementEntry != nil) {
        NSArray<NSMutableDictionary*>* adSourceEntries = placementEntry[ad.unitGroup.unitID];
        [adSourceEntries enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (ad == obj[kStatusStorageOfferKey]) {
                obj[kStatusStorageStatusKey] = @NO;
                *stop = YES;
            }
        }];
    }
}

+(BOOL) adSourceStatusInStorage:(NSDictionary*)storage placementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup {
    __block BOOL status = NO;
    NSDictionary *placementEntry = storage[placementModel.placementID];
    if (placementEntry != nil) {
        NSArray<NSDictionary*> *adSourceEntries = placementEntry[unitGroup.unitID];
        [adSourceEntries enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger priority, BOOL * _Nonnull stop) { *stop = status = ((id<ATAd>)obj[kStatusStorageOfferKey]).showTimes <= 0 && [self validateAdSourceStatusEntry:obj]; }];
    }
    return status;
}

+(void) saveAd:(id<ATAd>)ad toStatusStorage:(NSMutableDictionary*)storage {
    NSMutableDictionary *placementEntry = storage[ad.placementModel.placementID];
    NSMutableDictionary *newEntry = [NSMutableDictionary dictionaryWithDictionary:@{kStatusStorageStatusKey:@YES, kStatusStorageDateKey:[[NSDate date] dateByAddingTimeInterval:ad.unitGroup.statusTime], kStatusStorageOfferKey:ad}];
    if (placementEntry != nil) {
        NSMutableArray *adSourceEntry = placementEntry[ad.unitGroup.unitID];
        if (adSourceEntry != nil) {
            NSMutableArray *entriesToBeRemove = [NSMutableArray array];
            [adSourceEntry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *entry = obj;
                id<ATAd> entryAd = entry[kStatusStorageOfferKey];
                if (entryAd.showTimes >= 1) { [entriesToBeRemove addObject:entry]; }
            }];
            [adSourceEntry removeObjectsInArray:entriesToBeRemove];
            [adSourceEntry addObject:newEntry];
        } else {
            adSourceEntry = [NSMutableArray arrayWithObject:newEntry];
            placementEntry[ad.unitGroup.unitID] = adSourceEntry;
        }
    } else {
        NSMutableArray *adSourceEntry = [NSMutableArray arrayWithObject:newEntry];
        placementEntry = [NSMutableDictionary dictionaryWithObject:adSourceEntry forKey:ad.unitGroup.unitID];
        storage[ad.placementModel.placementID] = placementEntry;
    }
}

+(NSDictionary<NSString*, NSArray<id<ATAd>>*>*) saveAd:(id<ATAd>)ad finalWaterfall:(ATWaterfall*)finalWaterfall toStorage:(NSMutableDictionary*)storage requestID:(NSString*)requestID {
    NSDictionary<NSString*, NSArray<id<ATAd>>*>* discardedAds = nil;
    NSMutableDictionary *placementInfo = storage[ad.placementModel.placementID];
    if (placementInfo == nil) {
        placementInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:requestID, kRequestIDKey, [NSMutableDictionary dictionary], kOffersKey, nil];
        storage[ad.placementModel.placementID] = placementInfo;
    } else {
        if (![placementInfo[kRequestIDKey] isEqualToString:requestID]) {
            placementInfo[kRequestIDKey] = requestID;
            discardedAds = placementInfo[kOffersKey];
            [placementInfo[kOffersKey] removeAllObjects];
        }
    }
    if (finalWaterfall != nil) { placementInfo[kFinalWaterfallKey] = finalWaterfall; }
    
    NSMutableArray<id<ATAd>>* adsInUnitGroup = placementInfo[kOffersKey][ad.unitGroup.unitGroupID];
    if (adsInUnitGroup == nil) {
        adsInUnitGroup = [NSMutableArray<id<ATAd>> array];
        placementInfo[kOffersKey][ad.unitGroup.unitGroupID] = adsInUnitGroup;
    }
    [adsInUnitGroup addObject:ad];
    return discardedAds;
}

+(id<ATAd>) adInStorage:(NSMutableDictionary*)storage statusStorage:(NSMutableDictionary*)statusStorage forPlacementID:(NSString*)placementID caller:(ATAdManagerReadyAPICaller)caller extra:(NSDictionary* __autoreleasing*)extra {
    __block id<ATAd> ad = nil;
    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
    __block NSInteger firstExpiredPriority = [placementModel.unitGroups count];
    NSDictionary<NSString*, NSArray<id<ATAd>>*> *adsInPlacement = storage[placementID][kOffersKey];
    __block NSString *requestID = storage[placementID][kRequestIDKey] != nil ? storage[placementID][kRequestIDKey] : @"";//Might be modified by ready_fill
    NSMutableArray<NSDictionary*>*unitGroupInfos = [NSMutableArray<NSDictionary*> array];
    __block NSDictionary *headerBiddingInfo = nil;
    __block NSInteger networkFirmID = 0;
    __block NSString *unitID = @"";
    __block NSString *networkSDKVer = @"";
    __block NSInteger priority = NSNotFound;
    BOOL usingMyOfferDefaultOffer = NO;
    BOOL adsInPlacementHasBeenShown = NO;
    NSMutableDictionary<NSString*, NSMutableDictionary*>* myOfferUnitGroupInfos = [NSMutableDictionary<NSString*, NSMutableDictionary*> dictionary];
    NSMutableArray<ATMyOfferOfferModel*>* myOfferModels = [NSMutableArray<ATMyOfferOfferModel*> array];
    NSMutableDictionary<NSString*, id<ATAd>>* myOfferAds = [NSMutableDictionary<NSString*, id<ATAd>> dictionary];
    
    ATWaterfall *finalWaterfall = storage[placementID][kFinalWaterfallKey];
    NSArray<ATUnitGroupModel*>* unitGroups = finalWaterfall.unitGroups;
    if (unitGroups.count == 0 && placementModel.usesDefaultMyOffer != 0) {
        unitGroups = placementModel.unitGroups;
    }
    [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *unitGroupInfo = [NSMutableDictionary dictionaryWithDictionary:@{kAdStorageExtraUnitGroupInfoPriorityKey:@(idx), kAdStorageExtraUnitGroupInfoNetworkFirmIDKey:@(obj.networkFirmID), kAdStorageExtraUnitGroupInfoUnitIDKey:obj.unitID != nil ? obj.unitID : @"", kAdStorageExtraUnitGroupInfoNetworkSDKVersionKey:[[ATAPI sharedInstance] versionForNetworkFirmID:obj.networkFirmID] }];
        if ([self validateCapsForUnitGroup:obj placementID:placementID]) {
            if ([self validatePacingForUnitGroup:obj placementID:placementID]) {
                
                if ([adsInPlacement[obj.unitGroupID] count] > 0) {
                    [adsInPlacement[obj.unitGroupID] enumerateObjectsUsingBlock:^(id<ATAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj ready]) {
                            if ([obj expired]) {
                                unitGroupInfo[kAdStorageExtraNotReadyReasonKey] = @1;
                                unitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @(0);
                                firstExpiredPriority = firstExpiredPriority == [unitGroups count] ? obj.priority : firstExpiredPriority;
                            } else {
                                //if unitgroup is adx, check the token expire time first
                                if(obj.unitGroup.networkFirmID == ATNetworkFirmIdADX && [self checkExpireForAdxUnitGroup:obj.unitGroup]){
                                    unitGroupInfo[kAdStorageExtraNotReadyReasonKey] = @5;
                                    unitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @(0);
                                    firstExpiredPriority = firstExpiredPriority == [unitGroups count] ? obj.priority : firstExpiredPriority;
                                }else{//adx is not expired or another type of offer
                                    if (obj.showTimes < 1) {
                                          unitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @(1);
                                          headerBiddingInfo = [ATTracker headerBiddingTrackingExtraWithAd:obj requestID:obj.requestID];
                                          networkFirmID = obj.unitGroup.networkFirmID;
                                          unitID = obj.unitGroup.unitID;
                                          networkSDKVer = [[ATAPI sharedInstance] versionForNetworkFirmID:obj.unitGroup.networkFirmID];
                                          priority = obj.priority;
                                          ad = obj;
                                          *stop = YES;
                                      } else {//offer's been shown
                                          if (idx == [adsInPlacement[obj.unitGroup.unitGroupID] count] - 1) {
                                              id<ATAd> filledAd = [self fillIfReadyWithPlacementModel:placementModel unitGroupModel:obj.unitGroup requestID:requestID priority:obj.priority storage:storage statusStorage:statusStorage finalWaterfall:finalWaterfall];
                                              if (filledAd != nil) {
                                                  unitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @(1);
                                                  headerBiddingInfo = [ATTracker headerBiddingTrackingExtraWithAd:filledAd requestID:requestID];
                                                  networkFirmID = filledAd.unitGroup.networkFirmID;
                                                  unitID = filledAd.unitGroup.unitID;
                                                  networkSDKVer = [[ATAPI sharedInstance] versionForNetworkFirmID:filledAd.unitGroup.networkFirmID];
                                                  priority = filledAd.priority;
                                                  ad = filledAd;
                                                  *stop = YES;
                                              }
                                          }
                                      }
                                }
                                
  
                            }
                        } else {//Not ready
                            unitGroupInfo[kAdStorageExtraNotReadyReasonKey] = @0;
                            unitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @0;
                            if ([obj.unitGroup.adapterClass respondsToSelector:@selector(resourceReadyMyOfferForPlacementModel:unitGroupModel:info:)]) {
                                ATMyOfferOfferModel *offerModel = [obj.unitGroup.adapterClass resourceReadyMyOfferForPlacementModel:obj.placementModel unitGroupModel:obj.unitGroup info:nil];
                                if (offerModel != nil) {
                                    [myOfferModels addObject:offerModel];
                                    NSMutableDictionary *myOfferUnitGroupInfo = [NSMutableDictionary dictionaryWithDictionary:unitGroupInfo];
                                    [myOfferUnitGroupInfo removeObjectForKey:kAdStorageExtraNotReadyReasonKey];
                                    myOfferUnitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @1;
                                    myOfferUnitGroupInfos[offerModel.offerID] = myOfferUnitGroupInfo;
                                    myOfferAds[offerModel.offerID] = obj;
                                }
                            }
                        }
                    }];
                } else {//No offer for the unit group
                    id<ATAd> filledAd = [self fillIfReadyWithPlacementModel:placementModel unitGroupModel:obj requestID:[requestID length] > 0 ? requestID : [Utilities generateRequestID] priority:idx storage:storage statusStorage:statusStorage finalWaterfall:finalWaterfall];
                    if (filledAd != nil) {
                        requestID = filledAd.requestID;
                        unitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @(1);
                        headerBiddingInfo = [ATTracker headerBiddingTrackingExtraWithAd:filledAd requestID:requestID];
                        networkFirmID = obj.networkFirmID;
                        unitID = obj.unitID;
                        networkSDKVer = [[ATAPI sharedInstance] versionForNetworkFirmID:obj.networkFirmID];
                        priority = filledAd.priority;
                        if ([filledAd ready]) {
                            ad = filledAd;
                        } else {//MyOffer
                            if ([filledAd.unitGroup.adapterClass respondsToSelector:@selector(resourceReadyMyOfferForPlacementModel:unitGroupModel:info:)]) {
                                ATMyOfferOfferModel *offerModel = [filledAd.unitGroup.adapterClass resourceReadyMyOfferForPlacementModel:filledAd.placementModel unitGroupModel:filledAd.unitGroup info:nil];
                                if (offerModel != nil) {
                                    [myOfferModels addObject:offerModel];
                                    NSMutableDictionary *myOfferUnitGroupInfo = [NSMutableDictionary dictionaryWithDictionary:unitGroupInfo];
                                    [myOfferUnitGroupInfo removeObjectForKey:kAdStorageExtraNotReadyReasonKey];
                                    myOfferUnitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @1;
                                    myOfferUnitGroupInfos[offerModel.offerID] = myOfferUnitGroupInfo;
                                    myOfferAds[offerModel.offerID] = filledAd;
                                }
                            }
                        }
                    } else {
                        unitGroupInfo[kAdStorageExtraNotReadyReasonKey] = @4;
                        unitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @(0);
                    }
                }
            } else {//Pacing
                unitGroupInfo[kAdStorageExtraNotReadyReasonKey] = @3;
                unitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @(0);
                if ([obj.adapterClass respondsToSelector:@selector(resourceReadyMyOfferForPlacementModel:unitGroupModel:info:)]) {
                    ATMyOfferOfferModel *offerModel = [obj.adapterClass resourceReadyMyOfferForPlacementModel:placementModel unitGroupModel:obj info:nil];
                    id<ATAd> myOfferAd = ([adsInPlacement[obj.unitGroupID] isKindOfClass:[NSArray class]] && [adsInPlacement[obj.unitGroupID] count] > 0) ? ((NSArray*)adsInPlacement[obj.unitGroupID])[0] : [self fillIfReadyWithPlacementModel:placementModel unitGroupModel:obj requestID:[requestID length] > 0 ? requestID : [Utilities generateRequestID] priority:idx storage:storage statusStorage:statusStorage finalWaterfall:finalWaterfall];
                    if (offerModel != nil && myOfferAd != nil) {
                        [myOfferModels addObject:offerModel];
                        NSMutableDictionary *myOfferUnitGroupInfo = [NSMutableDictionary dictionaryWithDictionary:unitGroupInfo];
                        [myOfferUnitGroupInfo removeObjectForKey:kAdStorageExtraNotReadyReasonKey];
                        myOfferUnitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @1;
                        myOfferUnitGroupInfos[offerModel.offerID] = myOfferUnitGroupInfo;
                        myOfferAds[offerModel.offerID] = myOfferAd;
                    }
                }
            }
        } else {//end of caps
            unitGroupInfo[kAdStorageExtraNotReadyReasonKey] = @2;
            unitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @(0);
            if ([obj.adapterClass respondsToSelector:@selector(resourceReadyMyOfferForPlacementModel:unitGroupModel:info:)]) {
                ATMyOfferOfferModel *offerModel = [obj.adapterClass resourceReadyMyOfferForPlacementModel:placementModel unitGroupModel:obj info:nil];
                id<ATAd> myOfferAd = ([adsInPlacement[obj.unitGroupID] isKindOfClass:[NSArray class]] && [adsInPlacement[obj.unitGroupID] count] > 0) ? ((NSArray*)adsInPlacement[obj.unitGroupID])[0] : [self fillIfReadyWithPlacementModel:placementModel unitGroupModel:obj requestID:[requestID length] > 0 ? requestID : [Utilities generateRequestID] priority:idx storage:storage statusStorage:statusStorage finalWaterfall:finalWaterfall];
                if (offerModel != nil && myOfferAd != nil) {
                    [myOfferModels addObject:offerModel];
                    NSMutableDictionary *myOfferUnitGroupInfo = [NSMutableDictionary dictionaryWithDictionary:unitGroupInfo];
                    [myOfferUnitGroupInfo removeObjectForKey:kAdStorageExtraNotReadyReasonKey];
                    myOfferUnitGroupInfo[kAdStorageExtraUnitGroupInfoReadyFlagKey] = @1;
                    myOfferUnitGroupInfos[offerModel.offerID] = myOfferUnitGroupInfo;
                    myOfferAds[offerModel.offerID] = myOfferAd;
                }
            }
        }
        *stop = ad != nil;
        firstExpiredPriority = *stop ? [unitGroups count] : firstExpiredPriority;
        [unitGroupInfos addObject:unitGroupInfo];
    }];
    if ((caller == ATAdManagerReadyAPICallerReady && placementModel.usesDefaultMyOffer == 1) || (caller == ATAdManagerReadyAPICallerShow && placementModel.usesDefaultMyOffer != 0)) {
        if (ad == nil && ([myOfferAds count] > 0 && [myOfferModels count] > 0 && [myOfferUnitGroupInfos count] > 0)) {
            ATMyOfferOfferModel *offerModel = [[NSClassFromString(@"ATMyOfferOfferManager") sharedManager] defaultOfferInOfferModels:myOfferModels];
            id<ATAd> myOfferAd = myOfferAds[offerModel.offerID];
            NSMutableDictionary *myOfferUnitGroupInfo = myOfferUnitGroupInfos[offerModel.offerID];
            if (myOfferAd != nil && [myOfferAd respondsToSelector:@selector(setDefaultPlayIfRequired:)] && myOfferUnitGroupInfo != nil) {
                myOfferAd.defaultPlayIfRequired = YES;
                headerBiddingInfo = [ATTracker headerBiddingTrackingExtraWithAd:myOfferAd requestID:myOfferAd.requestID];
                networkFirmID = myOfferAd.unitGroup.networkFirmID;
                unitID = myOfferAd.unitGroup.unitID;
                networkSDKVer = [[ATAPI sharedInstance] versionForNetworkFirmID:myOfferAd.unitGroup.networkFirmID];
                priority = myOfferAd.priority;
                usingMyOfferDefaultOffer = YES;
                [unitGroupInfos addObject:myOfferUnitGroupInfo];
                ad = myOfferAd;
            }
        }
    }
    
    if (extra != nil) {
        NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementID, kAdStorageExtraPlacementIDKey, requestID, kAdStorageExtraRequestIDKey, @(firstExpiredPriority < [placementModel.unitGroups count]), kAdStorageExtraNeedReloadFlagKey, unitGroupInfos, kAdStorageExtraUnitGroupInfosKey, placementModel.psID != nil ? placementModel.psID : @"", kAdStorageExtraPSIDKey, placementModel.sessionID != nil ? placementModel.sessionID : @"", kAdStorageExtraSessionIDKey, headerBiddingInfo, kAdStorageExtraHeaderBiddingInfo, @(networkFirmID), kAdStorageExtraNetworkFirmIDKey, unitID, kAdStoreageExtraUnitGroupUnitID, networkSDKVer, kAdStorageExtraNetworkSDKVersion, @(ad.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (priority != NSNotFound) { extraInfo[kAdStorageExtraPriorityKey] = @(priority); }
        if (usingMyOfferDefaultOffer) { extraInfo[kAgentEventExtraInfoMyOfferDefaultFlagKey] = @1; }
        if (adsInPlacementHasBeenShown) {
            extraInfo[kAdStorageExtraNotReadyReasonKey] = @7;
        } else {
            if (ad == nil) { extraInfo[kAdStorageExtraNotReadyReasonKey] = @(firstExpiredPriority < [placementModel.unitGroups count] ? ATAdNotReadyReasonAdAllExpired : ATAdNotReadyReasonNoReadyAd); }
        }
        if ([ad respondsToSelector:@selector(filledByReady)] && ad.filledByReady) { extraInfo[kAdLoadingExtraFilledByReadyFlagKey] = @YES;}
        if ([ad respondsToSelector:@selector(filledByAutoloadOnClose)] && ad.filledByAutoloadOnClose) { extraInfo[kAdLoadingExtraAutoLoadOnCloseFlagKey] = @YES;}
        if ([ad respondsToSelector:@selector(fillByAutorefresh)] && ad.fillByAutorefresh) { extraInfo[kATTrackerExtraRefreshFlagKey] = @YES; }
        if (ad != nil) { extraInfo[kATTrackerExtraAdObjectKey] = ad; }
        if (finalWaterfall != nil) { extraInfo[kAdStorageExtraFinalWaterfallKey] = finalWaterfall; }
        if([ATAPI isOfm]){
            id<ATOFMAPI> ofmApi = [NSClassFromString(@"OFMAPI") sharedInstance];
            id<ATOFMMediationConfig> config = ofmApi.currentMediationConfig;
            extraInfo[kATTrackerExtraOFMTrafficIDKey] = @(config.mediationTrafficId);
            extraInfo[kATTrackerExtraOFMSystemKey] = @1;
        }
        if (ad.autoReqType == 5) { extraInfo[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
        *extra = extraInfo;
    }
    return ad;
}

+(id<ATAd>) fillIfReadyWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID priority:(NSInteger)priority storage:(NSMutableDictionary*)storage statusStorage:(NSMutableDictionary*)statusStorage finalWaterfall:(ATWaterfall*)finalWaterfall {
    id<ATAd> ad = nil;
    if (unitGroupModel.canAutoReady) {
        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithObject:@(unitGroupModel.headerBidding) forKey:@"is_hb_adsource"];
        if ([unitGroupModel.content isKindOfClass:[NSDictionary class]]) { [content addEntriesFromDictionary:unitGroupModel.content]; }
        if ([unitGroupModel.adapterClass respondsToSelector:@selector(adReadyForInfo:)] && [unitGroupModel.adapterClass adReadyForInfo:content]) {
            ad = [unitGroupModel.adapterClass respondsToSelector:@selector(readyFilledAdWithPlacementModel:requestID:priority:unitGroup:finalWaterfall:)] ? [unitGroupModel.adapterClass readyFilledAdWithPlacementModel:placementModel requestID:requestID priority:priority unitGroup:unitGroupModel finalWaterfall:finalWaterfall] : nil;
            if (ad != nil) {
                [self saveAd:ad finalWaterfall:finalWaterfall toStorage:storage requestID:requestID];
                [self saveAd:ad toStatusStorage:statusStorage];
                [[ATLoadingScheduler sharedScheduler] scheduleLoadingWithPlacementModel:placementModel unitGroup:unitGroupModel requestID:requestID extra:@{}];
            }
        }
    }
    return ad;
}

+(void) clearPlacementContainingAd:(id<ATAd>)ad fromStorage:(NSMutableDictionary*)storage {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATAdStorageUtility::Before clearAd: %@", storage] type:ATLogTypeInternal];
    __block BOOL shouldRemove = NO;
    NSDictionary<NSString*, NSArray<id<ATAd>>*> *placementStorage = storage[ad.placementModel.placementID][kOffersKey];
    [placementStorage enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<id<ATAd>> * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(id<ATAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            shouldRemove = *stop = [obj.requestID isEqualToString:ad.requestID];
        }];
        *stop = shouldRemove;
    }];
    if (shouldRemove) { [storage removeObjectForKey:ad.placementModel.placementID]; }
    [ATLogger logMessage:[NSString stringWithFormat:@"ATAdStorageUtility::After clearAd: %@", storage] type:ATLogTypeInternal];
}

+(BOOL) validateCapsForUnitGroup:(ATUnitGroupModel*)unitGroup placementID:(NSString*)placementID {
    return unitGroup.capByDay > [[ATCapsManager sharedManager] capByDayWithPlacementID:placementID unitGroupID:unitGroup.unitGroupID requestID:nil] && unitGroup.capByHour > [[ATCapsManager sharedManager] capByHourWithPlacementID:placementID unitGroupID:unitGroup.unitGroupID requestID:nil];
}

+(BOOL) validatePacingForUnitGroup:(ATUnitGroupModel*)unitGroup placementID:(NSString*)placementID {
    return unitGroup.showingInterval < 0 || [[ATCapsManager sharedManager] lastShowTimeOfPlacementID:placementID unitGroupID:unitGroup.unitGroupID] == nil || [[NSDate date] timeIntervalSinceDate:[[ATCapsManager sharedManager] lastShowTimeOfPlacementID:placementID unitGroupID:unitGroup.unitGroupID]] >= unitGroup.showingInterval / 1000.0f;
}

+(BOOL) checkExpireForAdxUnitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATBidInfoManager sharedManager] checkAdxBidInfoExpireForUnitGroupModel:unitGroup];
}
@end
