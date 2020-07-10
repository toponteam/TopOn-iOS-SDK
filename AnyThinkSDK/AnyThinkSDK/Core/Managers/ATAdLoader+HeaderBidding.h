//
//  ATAdLoader+HeaderBidding.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/6/13.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATAdLoader.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"

@interface ATPlacementModel(HeaderBidding)
@property (nonatomic, readonly) NSInteger headerBiddingFormat;
@end

extern NSString *const kUnitGroupBidInfoPriceKey;
extern NSString *const kUnitGroupBidInfoBidTokenKey;
@interface ATUnitGroupModel(HeaderBidding)
@property(nonatomic, readonly) NSDictionary *adSrouceInfo;
@end

extern NSString *const kATHeaderBiddingExtraInfoTotalErrorKey;
extern NSString *const kATHeaderBiddingExtraInfoDetailErrorKey;//the value keyed by this key is a dictionary which contains the corresponding errors produced by hb, stored using the unit groups' hash as keys.
extern NSString *const kATHeaderBiddingExtraInfoUnitGroupsUsingLatestBidInfoKey;

extern NSString *const kATHeaderBiddingBidRequestExtraStatisticsInfoKey;

@interface ATAdLoader (HeaderBidding)
+(BOOL) headerBiddingSupported;
-(void) runHeaderBiddingWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID completion:(void(^)(NSDictionary *context))completion;
-(void) sendHeaderBiddingRequestWithPlacementModel:(ATPlacementModel*)placementModel nonHeaderBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)nonHBUnitGroups headerBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)hbUnitGroups completion:(void(^)(NSArray<ATUnitGroupModel*>*, NSDictionary*))completion;
//Unit groups filter
+(NSMutableArray<ATUnitGroupModel*>*)activeUnitGroupsInPlacementModel:(ATPlacementModel*)placementModel unitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups inactiveUnitGroupInfos:(NSArray<NSDictionary*>* __autoreleasing*)inactiveActiveUnitGroupInfos requestID:(NSString*)requestID;
+(NSMutableArray<ATUnitGroupModel*>*) offerCachedActiveUnitGroupsInPlacementModel:(ATPlacementModel*)placementModel hbUnitGroups:(NSArray<ATUnitGroupModel*>*)hbUnitGroups;
@end


extern NSString *const kATHeaderBiddingAdSourceInfoAppIDKey_internal;
extern NSString *const kATHeaderBiddingAdSourceInfoUnitIDKey_internal;
@protocol ATHeaderBiddingManager<NSObject>
+(instancetype) sharedManager;
-(void) runHeaderBiddingWithForamt:(NSInteger)format unitID:(NSString*)unitID adSources:(NSArray<ATUnitGroupModel*>*)adsrouces headerBiddingAdSources:(NSArray<ATUnitGroupModel*>*)HBAdSources extra:(NSDictionary*)extra timeout:(NSTimeInterval)timeout completion:(void(^)(NSArray<ATUnitGroupModel*>*, NSDictionary*))completion;
@end


