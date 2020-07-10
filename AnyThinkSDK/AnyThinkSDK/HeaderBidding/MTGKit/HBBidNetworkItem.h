//
//  HBBidNetworkItem.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBAdsBidConstants.h"


NS_ASSUME_NONNULL_BEGIN

@interface HBBidNetworkItem : NSObject


@property (nonatomic,  copy)  NSString *customEventClassName;
@property (nonatomic,  copy)  NSString *appId;
@property (nonatomic,  copy)  NSString *placementId;
@property (nonatomic,  copy)  NSString *unitId;
@property (nonatomic,  copy)  NSString *platformId;
@property (nonatomic,strong)  NSDictionary *extraParams;

@property (nonatomic,assign)  HBAdBidNetwork network;
@property (nonatomic,assign)  NSInteger maxTimeoutMS;
@property (nonatomic,assign)  BOOL      testMode;

@property (nonatomic,copy,readonly) NSString *itemInstanceKey;

+ (HBBidNetworkItem *)buildItemNetwork:(HBAdBidNetwork)network
                  customEventClassName:(NSString *)className
                                 appId:(NSString *)appId
                                unitId:(NSString *)unitId;

/**
 @param maxTimeoutMS will be passed this value to the sdk for processing
 */
+ (HBBidNetworkItem *)buildItemNetwork:(HBAdBidNetwork)network
                  customEventClassName:(NSString *)className
                                 appId:(NSString *)appId
                                unitId:(NSString *)unitId
                               maxTimeoutMS:(NSInteger)maxTimeoutMS;

+ (HBBidNetworkItem *)buildItemNetwork:(HBAdBidNetwork)network
                  customEventClassName:(NSString *)className
                                 appId:(NSString *)appId
                                unitId:(NSString *)unitId
                            platformId:(NSString *)platformId
                               maxTimeoutMS:(NSInteger)maxTimeoutMS
                           extraParams:(NSDictionary *)extraParams
                              testMode:(BOOL)test;


@end

NS_ASSUME_NONNULL_END
