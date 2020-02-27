//
//  HBBidNetworkItem.m
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBBidNetworkItem.h"

NSString *const HBItemUniqueInstanceKey = @"HBItemUniqueInstanceKey";
@interface HBBidNetworkItem ()

@property (nonatomic,copy,readwrite) NSString *itemInstanceKey;

@end

@implementation HBBidNetworkItem

-(void)dealloc{
    DLog(@"");
}
#pragma mark  Private methods -

-(instancetype)initWithNetwork:(HBAdBidNetwork)network customEventClassName:(NSString *)className{
    self = [super init];
    if (self) {
        _maxTimeoutMS = -1;
        NSInteger instanceId = 0;

        @synchronized(HBItemUniqueInstanceKey) {
            static NSInteger __instance = 0;
            instanceId = __instance % (1024*1024);
            __instance++;
        }
        _itemInstanceKey = [NSString stringWithFormat:@"%ld", (long)instanceId];

        switch (network) {
            case HBAdBidNetworkFacebook:
                if (![className isEqualToString:@"FBBidAdapter"]) {
                    return nil;
                }
                break;
            case HBAdBidNetworkMintegral:
                if (![className isEqualToString:@"MTGBidAdapter"]) {
                    return nil;
                }
                break;

            default:
                break;
        }
    }
    return self;
}


#pragma mark  Public methods -

+ (HBBidNetworkItem *)buildItemNetwork:(HBAdBidNetwork)network
                  customEventClassName:(NSString *)className
                                 appId:(NSString *)appId
                                unitId:(NSString *)unitId
{
    
    HBBidNetworkItem *item = [[HBBidNetworkItem alloc] initWithNetwork:network customEventClassName:className];
    item.customEventClassName = className;
    item.network = network;
    item.appId   = appId;
    item.unitId  = unitId;
    
    return item;
}

+ (HBBidNetworkItem *)buildItemNetwork:(HBAdBidNetwork)network
                  customEventClassName:(NSString *)className
                                 appId:(NSString *)appId
                                unitId:(NSString *)unitId
                               maxTimeoutMS:(NSInteger)maxTimeoutMS
{
    
    HBBidNetworkItem *item = [[HBBidNetworkItem alloc] initWithNetwork:network customEventClassName:className];
    item.customEventClassName = className;
    item.network = network;
    item.appId   = appId;
    item.unitId  = unitId;
    item.maxTimeoutMS = maxTimeoutMS;
    
    return item;
}


+ (HBBidNetworkItem *)buildItemNetwork:(HBAdBidNetwork)network
                  customEventClassName:(NSString *)className
                                 appId:(NSString *)appId
                                unitId:(NSString *)unitId
                            platformId:(NSString *)platformId
                               maxTimeoutMS:(NSInteger)maxTimeoutMS
                           extraParams:(NSDictionary *)extraParams
                              testMode:(BOOL)test
{
    
    HBBidNetworkItem *item = [[HBBidNetworkItem alloc] initWithNetwork:network customEventClassName:className];
    item.customEventClassName = className;
    item.network = network;
    item.appId   = appId;
    item.unitId  = unitId;
    item.maxTimeoutMS = maxTimeoutMS;
    item.platformId  = platformId;
    item.extraParams = extraParams;
    item.testMode = test;

    return item;
}


@end
