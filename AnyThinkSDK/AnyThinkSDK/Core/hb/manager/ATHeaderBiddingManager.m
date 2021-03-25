//
//  ATHeaderBiddingManager.m
//  AnyThinkSDK
//
//  Created by stephen on 9/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAdLoader.h"
#import "ATThreadSafeAccessor.h"
#import "ATAPI+Internal.h"
#import "ATPlacementModel.h"
#import "ATPlacementSettingManager.h"
#import "Utilities.h"
#import "ATTracker.h"
#import "ATAgentEvent.h"
#import "ATAdManager+Internal.h"
#import "ATAdLoadingDelegate.h"
#import "ATCapsManager.h"
#import "ATAdManagement.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATLoadingScheduler.h"
#import "ATAdStorageUtility.h"
#import "ATAdCustomEvent.h"
#import "ATAppSettingManager.h"
#import "ATAdManager.h"
#import "ATBidInfoManager.h"
#import "ATWaterfallManager.h"
#import "ATBidInfo.h"
#import "ATAdLoader+S2SHeaderBidding.h"
#import "ATHeaderBiddingManager.h"
#import "ATBidJobModel.h"
#import "ATBidTrackingModel.h"
#import "ATThreadSafeAccessor.h"

@implementation ATHBRequest

@end

@interface ATHeaderBiddingManager()
@property(nonatomic, readonly) ATSerialThreadSafeAccessor *headerBiddingResponseAccessor;
@property(nonatomic, readwrite) BOOL bidSortTKSent;
@property(nonatomic, readwrite) NSInteger bidResponseNum;
@property(nonatomic, readwrite) NSInteger bidTotalNum;
@property(nonatomic, readwrite) NSMutableDictionary<NSString*, ATBidInfo*>* cacheResponseSuccessList;
@property(nonatomic, readwrite) NSMutableDictionary<NSString*, ATBidInfo*>* responseSuccessList;
@property(nonatomic, readwrite) NSMutableDictionary<NSString*, NSError*>* responseFailedList;
@property(nonatomic, readwrite) NSMutableArray<NSDictionary*>* processingResultList;
@property(nonatomic, readonly) ATBidJobModel *bidJobModel;
@property(nonatomic, readonly) ATBidTrackingModel *bidTrackingModel;
@property(nonatomic, readonly) NSArray<ATUnitGroupModel*> *headerBiddingUnitGroups;
@property(nonatomic, readonly) NSArray<ATUnitGroupModel*> *s2sHBUnitGroups;

@end

@implementation ATHeaderBiddingManager

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _cacheResponseSuccessList = [[NSMutableDictionary<NSString*, ATBidInfo*> alloc] init];
        _responseSuccessList = [[NSMutableDictionary<NSString*, ATBidInfo*> alloc] init];
        _responseFailedList = [[NSMutableDictionary<NSString*, NSError*> alloc] init];
        _processingResultList = [NSMutableArray<NSDictionary*> array];
        _bidResponseNum = 0;
        _bidSortTKSent = false;
        _headerBiddingResponseAccessor = [ATSerialThreadSafeAccessor new];
    }
    return self;
}

void LogHeaderBiddingLog(NSString* log) { [ATLogger logMessage:[NSString stringWithFormat:@"HeaderBidding::%@", log] type:ATLogTypeInternal]; }

//TODO hb wait for 2s
//TODO hb error upload for tk11
//check adapter support c2s
-(void) headerBiddingResponseWithBidInfos:(NSDictionary<NSString*, ATBidInfo*>*) bidInfos bidTime:(NSTimeInterval)bidTime delegate:(id<ATAdLoadingDelegate>)delegate {
    
    [self.headerBiddingResponseAccessor readWithBlock:^id{
        __block NSInteger loadingStatus = 1;
        
        if ([bidInfos count] > 0) {
            [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:self.bidJobModel.placementModel.placementID requestID:self.bidJobModel.requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                loadingStatus = waterfallWrapper.filled ? 2 : 1;
                //             NSMutableArray<NSDictionary*>* processingResultList = [NSMutableArray<NSDictionary*> array];
                LogHeaderBiddingLog([NSString stringWithFormat:@"Bid req finished, filled:%@", @(waterfallWrapper.filled)]);
                if (bidTime > self.bidJobModel.placementModel.headerBiddingRequestTimeout) {
                    LogHeaderBiddingLog(@"But timeout");
                    if (finished && !waterfallWrapper.filled) {
                        loadingStatus = 3;
                    }
                    [bidInfos enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ATBidInfo * _Nonnull obj, BOOL * _Nonnull stop) {
                        [[ATBidInfoManager sharedManager] saveBidInfo:obj forRequestID:self.bidJobModel.requestID];
                        ATUnitGroupModel* unitGroupModel = [self unitGroupModelWithUnitID:key];
                        [self.processingResultList addObject:@{@"unit_id":key, @"nw_firm_id":@(unitGroupModel.networkFirmID), @"bidprice":obj.price, @"result":@3}];
                    }];
                } else {
                    LogHeaderBiddingLog(@"Will start inserting");
                    //processing result can't be 3 here since loading DID NOT return before placementModel.headerBiddingRequestTimeout as long as S2S HB request has been kicked off.
                    NSString *maxMarkingPrice = [ATBidInfoManager priceForUnitGroup:[waterfallWrapper filledUnitGroupWithMaximumPrice] placementID:self.bidJobModel.placementModel.placementID requestID:self.bidJobModel.requestID];
                    NSString *minMarkingPrice = [ATBidInfoManager priceForUnitGroup:[waterfall unitGroupWithMinimumPrice] placementID:self.bidJobModel.placementModel.placementID requestID:self.bidJobModel.requestID];
                    
                    [bidInfos enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ATBidInfo * _Nonnull bidInfo, BOOL * _Nonnull stop) {
                        [[ATBidInfoManager sharedManager] saveBidInfo:bidInfo forRequestID:self.bidJobModel.requestID];
                        ATUnitGroupModel* unitGroupModel = [self unitGroupModelWithUnitID:key];
                        NSMutableDictionary *processingResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"unit_id", @(unitGroupModel.networkFirmID), @"nw_firm_id", bidInfo.price, @"bidprice", nil];
                        [self.processingResultList addObject:processingResult];
                        NSString *processingResultKey = @"result";
                        NSString *ctypeKey = @"ctype";
                        LogHeaderBiddingLog([NSString stringWithFormat:@"Bid price:%@, max making price:%@, min making price:%@, waterfall.filled:%@", bidInfo.price, maxMarkingPrice, minMarkingPrice, waterfallWrapper.filled ? @YES : @NO]);
                        processingResult[ctypeKey] = waterfallWrapper.filled ? maxMarkingPrice : minMarkingPrice;
                        NSString *bidInfoPrice = [NSString stringWithFormat:@"%@", bidInfo.price];
                        NSDecimalNumber *bidInfoNum = [NSDecimalNumber decimalNumberWithString:bidInfoPrice];
                        NSDecimalNumber *maxMarkingNum = [NSDecimalNumber decimalNumberWithString:maxMarkingPrice];
                        NSDecimalNumber *minMarkingNum = [NSDecimalNumber decimalNumberWithString:minMarkingPrice];
                        
                        BOOL condition_max = waterfallWrapper.filled && [bidInfoNum compare: maxMarkingNum] == NSOrderedDescending;
                        BOOL condition_min = !waterfallWrapper.filled && [bidInfoNum compare: minMarkingNum] == NSOrderedDescending;
                        if (condition_max || condition_min) {
                            LogHeaderBiddingLog(@"Insert into hb waterfall");
                            [finalWaterfall insertUnitGroup:unitGroupModel price:bidInfoPrice];
                            [headerBiddingWaterfall addUnitGroup:unitGroupModel];
                            processingResult[processingResultKey] = @(1);
                            
                        }else{
                            LogHeaderBiddingLog(@"Insert into waterfall");
                            [finalWaterfall insertUnitGroup:unitGroupModel price:bidInfoPrice];
                            [waterfall addUnitGroup:unitGroupModel];
                            processingResult[processingResultKey] = waterfallWrapper.filled ? @(3) : @(2);
                        }
                    }];
                    
                    //resume waterfall loading
                    if ([waterfall canContinueLoading:YES]) {
                        LogHeaderBiddingLog(@"waterfall not loading, will start");
                        [[ATAdLoader sharedLoader] continueLoadingWaterfall:waterfall finalWaterfall:finalWaterfall placementModel:self.bidJobModel.placementModel requestID:self.bidJobModel.requestID startDate:loadStartDate extra:self.bidTrackingModel.extra delegate:delegate];
                    }
                    
                    //resume hb waterfall loading
                    if ([headerBiddingWaterfall canContinueLoading:YES]) {
                        LogHeaderBiddingLog(@"hbwaterfall not loading, will start");
                        [[ATAdLoader sharedLoader] continueLoadingHeaderBiddingWaterfall:headerBiddingWaterfall finalWaterfall:finalWaterfall placementModel:self.bidJobModel.placementModel requestID:self.bidJobModel.requestID startDate:loadStartDate extra:self.bidTrackingModel.extra delegate:delegate];
                    }
                }
                
                
            }];
        }
        //send tk11
        if(self.bidResponseNum == self.bidTotalNum){
            [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:self.bidJobModel.placementModel.placementID requestID:self.bidJobModel.requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                if(self.responseSuccessList.count == 0){
                    //Bid request failed
                    waterfallWrapper.headerBiddingFailed = YES;
                    if(bidTime > self.bidJobModel.placementModel.headerBiddingRequestTolerateInterval || [waterfall.unitGroups count] == 0) {
                        if (!finished && (![waterfall canContinueLoading:YES] && waterfall.numberOfTimeoutRequests == 0)) {
                            LogHeaderBiddingLog(@"Not finish, will check waterfall&headerBiddingWaterfall status");
                            [waterfallWrapper finish];
                            [[ATAdLoader sharedLoader] notifyFailureWithPlacementModel:self.bidJobModel.placementModel requestID:self.bidJobModel.requestID extra:self.bidTrackingModel.extra error:[NSError errorWithDomain:ATSDKAdLoadingErrorMsg code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Bid request have failed"}] delegate:delegate];
                        }
                    }
                }
                //Send tk11
                if (!self.bidSortTKSent) {
                    [[ATTracker sharedTracker] trackWithPlacementID:self.bidJobModel.placementModel.placementID requestID:self.bidJobModel.requestID trackType:ATNativeAdTrackTypeBidSort extra:@{kATTrackerExtraHeaderBiddingInfoKey:[ATAdLoader bidSortTKExtraWithPlacementID:self.bidJobModel.placementModel.placementID requestID:self.bidJobModel.requestID bidStartDate:self.bidTrackingModel.bidStartDate inactiveHBUnitGroupInfo:self.bidTrackingModel.inactiveHBUGInfo inactiveUGInfo:self.bidTrackingModel.inactiveUGInfo failedHBUGInfo:self.responseFailedList sortedUGs:finalWaterfall.unitGroups offerCachedUnitGroups:self.bidTrackingModel.offerCachedHBUGs unitGroupsWithHistoryBidInfo:self.bidTrackingModel.unitGroupsWithHistoryBidInfo]}];
                    self.bidSortTKSent = YES;
                }
                
            }];
            //Send processing result da
            [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyBidInfoProcessingKey placementID:self.bidJobModel.placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.bidJobModel.requestID, kAgentEventExtraInfoBidInfoBatProcessResultKey:@{@"bid_time":@((NSInteger)(bidTime * 1000)), @"load_status":@(loadingStatus), @"result_list":self.processingResultList}}];
            
        }
        return nil;
    }];
    
}

-(ATUnitGroupModel *) unitGroupModelWithUnitID:(NSString *) unitID {
    __block ATUnitGroupModel *unitGroupModel = nil;
    if(self.bidJobModel != nil) {
        [self.bidJobModel.s2sHBUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.unitID isEqualToString:unitID]){
                unitGroupModel = obj;
                *stop = YES;
            }}];
        [self.bidJobModel.headerBiddingUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.unitID isEqualToString:unitID]){
                unitGroupModel = obj;
                *stop = YES;
            }}];
    }
    return unitGroupModel;
}

// MARK:- methods claimed in .h
//- (void)startLoadingHeaderBidingInfoWithRequest:(ATHBRequest *)request {
//
//}

- (void)startLoadingHeaderBidingInfoWithRequest:(ATHBRequest *)request {
    _headerBiddingUnitGroups = request.headerBiddingUnitGroups;
    _s2sHBUnitGroups = request.s2sHBUnitGroups;
    NSArray<ATUnitGroupModel *> *headerBiddingUnitGroups = request.headerBiddingUnitGroups;
    NSArray<ATUnitGroupModel *> *s2sHBUnitGroups = request.s2sHBUnitGroups;
    NSArray<ATUnitGroupModel *> *offerCachedHBUGs = request.offerCachedHBUGs;
    NSArray<ATUnitGroupModel *> *unitGroupsWithHistoryBidInfo = request.unitGroupsWithHistoryBidInfo;
    NSString *requestID = request.requestID;
    NSArray *inactiveUGInfo = request.inactiveUGInfo;
    NSArray *inactiveHBUGInfo = request.inactiveHBUGInfo;
    ATPlacementModel *placementModel = request.placementModel;
    NSDictionary *extra = request.extra;
    id<ATAdLoadingDelegate> delegate = request.delegate;
    
    self.bidTotalNum = [headerBiddingUnitGroups count] + [s2sHBUnitGroups count];
    _bidJobModel = [[ATBidJobModel alloc] initBidJobModelWithRequestID:requestID headerBiddingUnitGroups:headerBiddingUnitGroups s2sHBUnitGroups:s2sHBUnitGroups placementModel:placementModel];
    NSDate *bidStartDate = [NSDate date];
    _bidTrackingModel = [[ATBidTrackingModel alloc] initBidTrackingModelWithRequestID:requestID offerCachedHBUGs:offerCachedHBUGs unitGroupsWithHistoryBidInfo:unitGroupsWithHistoryBidInfo inactiveUGInfo:inactiveUGInfo inactiveHBUGInfo:inactiveHBUGInfo extra:extra bidStartDate:bidStartDate];
    
    if([s2sHBUnitGroups count] > 0){
        [ATAdLoader sendS2SBidRequestWithPlacementModel:placementModel headerBiddingUnitGroups:s2sHBUnitGroups requestID:requestID extra:extra completion:^(NSDictionary<NSString*, ATBidInfo*>*bidInfos, NSDictionary<NSString*, NSError*>*errors) {
            self.bidResponseNum = self.bidResponseNum + bidInfos.count + errors.count;
            NSTimeInterval bidTime = [[NSDate date] timeIntervalSinceDate:bidStartDate];
            if(bidInfos != nil){
                if(bidTime > placementModel.headerBiddingRequestTimeout){
                    [self.s2sHBUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        self.responseFailedList[obj.unitID] = [NSError errorWithDomain:@"com.anythink.headerbidding" code:-1 userInfo:nil];
                    }];
                }else{
                    [self.responseSuccessList addEntriesFromDictionary:bidInfos];
                }
               
            }
            if(errors != nil){
                [self.responseFailedList addEntriesFromDictionary:errors];
            }
            [errors enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSError * _Nonnull obj, BOOL * _Nonnull stop) {
                [[ATAdLoader sharedLoader] updateS2SBidRequestFailureForPlacemetModel:placementModel unitGroupModel:[self unitGroupModelWithUnitID:key]];
            }];
            if(bidTime < placementModel.headerBiddingRequestTolerateInterval && self.bidResponseNum < self.bidTotalNum){
                // <2s, just cache ,wait for other return
                [self.cacheResponseSuccessList addEntriesFromDictionary:bidInfos];
                
            }else{
                [self headerBiddingResponseWithBidInfos:bidInfos bidTime:bidTime delegate:delegate];
            }
            
        }];
    }
    
    if([headerBiddingUnitGroups count] > 0){
        [headerBiddingUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:obj.content != nil ? obj.content : @{}];
            info[kADapterCustomInfoStatisticsInfoKey] = [ATAdLoader statisticsInfoWithPlacementModel:placementModel unitGroupModel:obj finalWaterfall:nil requestID:requestID bidRequest:YES];
            if([obj.adapterClass respondsToSelector:@selector(bidRequestWithPlacementModel:unitGroupModel:info:completion:)]){
                
                if (obj.networkFirmID == 1) { // facebook in-house list
                    placementModel.waterfallA = request.unitGroups;
                }
                [obj.adapterClass bidRequestWithPlacementModel:placementModel unitGroupModel:obj info:info completion:^(ATBidInfo *bidInfo, NSError *error) {
                    //adapter callback block async
                    self.bidResponseNum = self.bidResponseNum + 1;
                    NSTimeInterval bidTime = [[NSDate date] timeIntervalSinceDate:bidStartDate];
                    if(bidInfo != nil){
                        if(bidTime > placementModel.headerBiddingRequestTimeout){
                            self.responseFailedList[obj.unitID] = [NSError errorWithDomain:@"com.anythink.headerbidding" code:-1 userInfo:nil];
                        } else {
                            self.responseSuccessList[obj.unitID] = bidInfo;
                        }
                    }else{
                        self.responseFailedList[obj.unitID] = error;
                        [[ATAdLoader sharedLoader] updateS2SBidRequestFailureForPlacemetModel:self.bidJobModel.placementModel unitGroupModel:obj];
                    }
                    NSMutableDictionary <NSString*, ATBidInfo*>*bidInfos = [NSMutableDictionary<NSString*, ATBidInfo*> dictionary];
                    if(bidInfo != nil){
                        bidInfos[bidInfo.unitGroupUnitID] = bidInfo;
                    }
                    if(bidTime < placementModel.headerBiddingRequestTolerateInterval && self.bidResponseNum < self.bidTotalNum){
                        // <2s, just cache ,wait for other return
                        if(bidInfo != nil){
                            [self.cacheResponseSuccessList addEntriesFromDictionary:bidInfos];
                        }
                    }else{
                        [self headerBiddingResponseWithBidInfos:bidInfos bidTime:bidTime delegate:delegate];
                    }
                    
                }];
            }else{
                [[ATAdLoader sharedLoader] updateS2SBidRequestFailureForPlacemetModel:self.bidJobModel.placementModel unitGroupModel:obj];
            }
        }];
    }
    //for hb wait time
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(placementModel.headerBiddingRequestTolerateInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self->_cacheResponseSuccessList.count > 0){
            [self headerBiddingResponseWithBidInfos:_cacheResponseSuccessList bidTime:self.bidJobModel.placementModel.headerBiddingRequestTolerateInterval delegate:delegate];
        }
    });
    
    //for request timeout
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(placementModel.headerBiddingRequestTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
            if (!self.bidSortTKSent) {
                self.bidSortTKSent = YES;
                //add timeout hb adsource to failed list
                if(self.headerBiddingUnitGroups.count > 0){
                    [self.headerBiddingUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if(self.responseSuccessList[obj.unitID] == nil && self.responseFailedList[obj.unitID] == nil){
                            self.responseFailedList[obj.unitID] = [NSError errorWithDomain:@"com.anythink.headerbidding" code:-1 userInfo:nil];
                        }
                    }];
                }
                if(self.s2sHBUnitGroups.count > 0){
                    [self.s2sHBUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if(self.responseSuccessList[obj.unitID] == nil && self.responseFailedList[obj.unitID] == nil){
                            self.responseFailedList[obj.unitID] = [NSError errorWithDomain:@"com.anythink.headerbidding" code:-1 userInfo:nil];
                        }
                    }];
                }
                
                [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeAdTrackTypeBidSort extra:@{kATTrackerExtraHeaderBiddingInfoKey:[ATAdLoader bidSortTKExtraWithPlacementID:placementModel.placementID requestID:requestID bidStartDate:bidStartDate inactiveHBUnitGroupInfo:inactiveHBUGInfo inactiveUGInfo:inactiveUGInfo failedHBUGInfo:self.responseFailedList sortedUGs:finalWaterfall.unitGroups offerCachedUnitGroups:offerCachedHBUGs unitGroupsWithHistoryBidInfo:unitGroupsWithHistoryBidInfo]}];
            }
            //TODO check finish waterfall
            if(!finished && [waterfall.unitGroups count] == 0 && headerBiddingWaterfall.unitGroups.count == 0){
                LogHeaderBiddingLog(@"Not finish, will check waterfall&headerBiddingWaterfall status");
                [waterfallWrapper finish];
                [[ATAdLoader sharedLoader] notifyFailureWithPlacementModel:placementModel requestID:requestID extra:extra error:[NSError errorWithDomain:ATSDKAdLoadingErrorMsg code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Bid request have failed"}] delegate:delegate];
            }
            
        }];
    });
}


@end
