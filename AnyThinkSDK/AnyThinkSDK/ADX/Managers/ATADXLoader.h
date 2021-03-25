//
//  ATADXLoader.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATUnitGroupModel.h"
#import "ATADXOfferModel.h"
#import "ATBidInfo.h"
#import "ATPlacementModel.h"

@interface ATADXLoader : NSObject
+(instancetype) sharedLoader;
-(void) requestADXAdsWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel bidInfo:(ATBidInfo*) bidInfo requestID:(NSString*)requestID placementModel:(ATPlacementModel *)placementModel content:(NSDictionary *)content completion:(void(^)(ATADXOfferModel *offerModel, NSError *error))completion;
-(BOOL) readyADXAdWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel placementID:(NSString *)placementID;
-(ATADXOfferModel*) offerModelWithPlacementID:(NSString *) placementID unitGroupModel:(ATUnitGroupModel*)unitGroupModel;
-(void) removeOfferModel:(ATADXOfferModel*)offerModel;
-(void) clearOfferModelWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel placementID:(NSString *) placementID;
-(void) saveOfferWithDictionary:(NSDictionary*)resultDictionary offerModel:(ATADXOfferModel *) offerModel saveKey:(NSString *) saveKey;
-(NSString*) saveKeyWithPlacementID:(NSString*)placementID unitID:(NSString *) unitID;
@end
