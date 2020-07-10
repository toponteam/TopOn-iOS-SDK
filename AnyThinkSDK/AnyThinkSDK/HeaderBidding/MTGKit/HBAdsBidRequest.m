//
//  HBAdsBidRequest.m
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBAdsBidRequest.h"
#import "HBBidRequestManager.h"

@implementation HBAdsBidRequest

-(void)dealloc{
    DLog(@"");
}

#pragma mark Public methods -
+(void)getBidNetworks:(NSArray *)networkItems statisticsInfo:(NSDictionary*)statisticsInfo unitId:(NSString *)unitId adFormat:(HBAdBidFormat)format maxTimeoutMS:(NSInteger)maxTimeoutMS responseCallback:(void(^)(HBAuctionResult *auctionResponse,NSError *error))callback{
    
    [[HBBidRequestManager alloc] getBidNetworks:networkItems statisticsInfo:statisticsInfo unitId:unitId adFormat:format maxTimeoutMS:maxTimeoutMS responseCallback:callback];
}

@end
