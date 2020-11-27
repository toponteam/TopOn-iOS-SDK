//
//  ATAdLoader.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ATMyOfferOfferModel;
@class ATMyOfferSetting;
@class ATPlacementModel;
@class ATUnitGroupModel;
@class ATWaterfall;
@protocol ATAdLoadingDelegate;
@interface ATAdLoader : NSObject
+(instancetype)sharedLoader;
/**
 Kick off the ad loading process
 */
-(void) loadADWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATAdLoadingDelegate>)delegate;
//
+(NSArray<ATUnitGroupModel*>*)rankAndShuffleUnitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID;
+(NSDictionary*)statisticsInfoWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID bidRequest:(BOOL)bidRequest;
+(NSDictionary*) bidSortTKExtraWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID bidStartDate:(NSDate*)bidStartDate inactiveHBUnitGroupInfo:(NSArray<NSDictionary*>*)inactiveHBUGInfo inactiveUGInfo:(NSArray<NSDictionary*>*)inactiveUGInfo failedHBUGInfo:(NSDictionary<NSString*, NSError*>*)failedHBUGInfo sortedUGs:(NSArray<ATUnitGroupModel*>*)sortedUGs offerCachedUnitGroups:(NSArray<ATUnitGroupModel*>*)offerCachedUGs unitGroupsWithHistoryBidInfo:(NSArray<ATUnitGroupModel*>*)unitGroupsWithHistoryBidInfo;

-(void) updateS2SBidRequestFailureForPlacemetModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel;
-(void) continueLoadingWaterfall:(ATWaterfall*)waterfall finalWaterfall:(ATWaterfall*)finalWaterfall placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID startDate:(NSDate*)loadStartDate extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate;
-(void) continueLoadingHeaderBiddingWaterfall:(ATWaterfall*)headerBiddingWaterfall finalWaterfall:(ATWaterfall*)finalWaterfall placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID startDate:(NSDate*)loadStartDate extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate;
-(void) notifyFailureWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID extra:(NSDictionary*)extra error:(NSError*)error delegate:(id<ATAdLoadingDelegate>)delegate;
@end

@protocol ATMyOfferWrapper<NSObject>
+(instancetype) sharedManager;
-(void) loadOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion;
@end
