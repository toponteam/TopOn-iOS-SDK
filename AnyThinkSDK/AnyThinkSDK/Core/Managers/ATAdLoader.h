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
@end

@protocol ATMyOfferWrapper<NSObject>
+(instancetype) sharedManager;
-(void) loadOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion;
@end
