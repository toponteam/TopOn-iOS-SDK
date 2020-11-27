//
//  ATAdLoader+S2SHeaderBidding.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/5/26.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAdLoader.h"
#import "ATBidInfo.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"
@interface ATAdLoader (S2SHeaderBidding)
+(void) sendS2SBidRequestWithPlacementModel:(ATPlacementModel*)placementModel headerBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)headerBiddingUnitGroups requestID:(NSString*)requestID extra:(NSDictionary *) extra completion:(void(^)(NSDictionary<NSString*, ATBidInfo*>*bidInfos, NSDictionary<NSString*, NSError*>*errors))completion;
@end
