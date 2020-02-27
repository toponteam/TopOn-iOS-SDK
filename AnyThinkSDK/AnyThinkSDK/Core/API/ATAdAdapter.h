//
//  ATAdAdapter.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#ifndef ATAdAdapter_h
#define ATAdAdapter_h
extern NSString *const kAdapterCustomInfoPlacementModelKey;
extern NSString *const kAdapterCustomInfoUnitGroupModelKey;
extern NSString *const kAdapterCustomInfoRequestIDKey;
extern NSString *const kAdapterCustomInfoExtraKey;
@protocol ATAd;
@class ATPlacementModel;
@class ATUnitGroupModel;
@class ATMyOfferOfferModel;
@protocol ATAdAdapter<NSObject>
/*
 * Create a rewarded instance for download event and FOR DOWNLOAD EVENT ONLY.
 */
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup;
+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup;
+(ATMyOfferOfferModel*) resourceReadyMyOfferForPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info;
+(BOOL) adReadyForInfo:(NSDictionary*)info;
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info;
-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion;
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end
#endif /* ATAdAdapter_h */
