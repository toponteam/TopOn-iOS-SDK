//
//  ATGeneralAdAgentEvent.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2018/11/28.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAgentEvent.h"
NS_ASSUME_NONNULL_BEGIN
@protocol ATAd;

extern NSString *const kATAPILoad;
extern NSString *const kATAPICheckLoadStatus;
extern NSString *const kATAPIIsReady;
extern NSString *const kATAPIShow;
@interface ATGeneralAdAgentEvent : NSObject<ATAgentEventDataStructure>
+(NSDictionary*)logInfoWithAd:(id<ATAd>)ad event:(NSInteger)eventType extra:(nullable NSDictionary*)extra error:(nullable NSError*)error;
+(NSString*)adFormatStringWithFormat:(NSInteger)format;
+(NSDictionary*)apiLogInfoWithPlacementID:(NSString*)placementID format:(NSInteger)format api:(NSString*)api;
@end

@interface ATPlacementholderAd:NSObject<ATAd>
+(instancetype)placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall;
@property(nonatomic, readonly) NSInteger showTimes;
/**
 Priority is calculate by the index of the unit group in the placement's unit group list; zero is the highest
 */
@property(nonatomic, readonly) NSInteger priority;
@property(nonatomic, readonly) ATPlacementModel *placementModel;
@property(nonatomic, readonly) NSString *requestID;
@property(nonatomic, readonly) NSDate *cacheDate;
@property(nonatomic, readonly) ATUnitGroupModel *unitGroup;
/**
 * Third-party network native ad object.
 */
@property(nonatomic, readonly) id customObject;
@property(nonatomic, readonly) NSString *unitID;
@property(nonatomic, readonly) NSString *price;
@property(nonatomic, readonly, weak) ATWaterfall *finalWaterfall;
@end
NS_ASSUME_NONNULL_END
