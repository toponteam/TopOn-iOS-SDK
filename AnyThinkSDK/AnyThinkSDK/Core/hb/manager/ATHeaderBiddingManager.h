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

@interface ATHeaderBiddingManager : NSObject
//+(instancetype)sharedManager;

-(void) startLoadingHeaderBiddingWithRequestID:(NSString*)requestID headerBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)headerBiddingUnitGroups s2sHBUnitGroups:(NSArray<ATUnitGroupModel*>*)s2sHBUnitGroups offerCachedHBUnitGroups:(NSArray<ATUnitGroupModel*>*)offerCachedHBUGs unitGroupsWithHistoryBidInfo:(NSArray<ATUnitGroupModel*>*)unitGroupsWithHistoryBidInfo inactiveUGInfo:(NSArray<NSDictionary*>*)inactiveUGInfo inactiveHBUGInfo:(NSArray<NSDictionary*>*)inactiveHBUGInfo placementModel:(ATPlacementModel*)placementModel extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate;

@end
