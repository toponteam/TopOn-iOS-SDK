//
//  ATHeaderBiddingManager.h
//  AnyThinkSDK
//
//  Created by stephen on 9/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ATMyOfferOfferModel;
@class ATMyOfferSetting;
@class ATPlacementModel;
@class ATUnitGroupModel;
@class ATWaterfall;
@protocol ATAdLoadingDelegate;

@interface ATHBRequest : NSObject

@property(nonatomic, copy) NSString *requestID;
@property(nonatomic, copy) NSArray<ATUnitGroupModel *> *unitGroups;
@property(nonatomic, copy) NSArray<ATUnitGroupModel *> *headerBiddingUnitGroups;
@property(nonatomic, copy) NSArray<ATUnitGroupModel *> *s2sHBUnitGroups;
@property(nonatomic, copy) NSArray<ATUnitGroupModel *> *offerCachedHBUGs;
@property(nonatomic, copy) NSArray<ATUnitGroupModel *> *unitGroupsWithHistoryBidInfo;
@property(nonatomic, copy) NSArray<NSDictionary *> *inactiveUGInfo;
@property(nonatomic, copy) NSArray<NSDictionary *> *inactiveHBUGInfo;
@property(nonatomic, copy) NSDictionary *extra;
@property(nonatomic, weak) id<ATAdLoadingDelegate> delegate;
@property(nonatomic, strong) ATPlacementModel *placementModel;

@end

@interface ATHeaderBiddingManager : NSObject
//+(instancetype)sharedManager;

//- (void)startLoadingHeaderBiddingWithRequestID:(NSString*)requestID headerBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)headerBiddingUnitGroups s2sHBUnitGroups:(NSArray<ATUnitGroupModel*>*)s2sHBUnitGroups offerCachedHBUnitGroups:(NSArray<ATUnitGroupModel*>*)offerCachedHBUGs unitGroupsWithHistoryBidInfo:(NSArray<ATUnitGroupModel*>*)unitGroupsWithHistoryBidInfo inactiveUGInfo:(NSArray<NSDictionary*>*)inactiveUGInfo inactiveHBUGInfo:(NSArray<NSDictionary*>*)inactiveHBUGInfo placementModel:(ATPlacementModel*)placementModel extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate;

/**
 This method supports some situations which need to process common unit groups(e.g. facebook inhouse list).
 */
- (void)startLoadingHeaderBidingInfoWithRequest:(ATHBRequest *)request;

@end
