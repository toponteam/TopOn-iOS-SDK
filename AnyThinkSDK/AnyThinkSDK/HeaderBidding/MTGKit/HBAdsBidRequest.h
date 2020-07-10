//
//  HBAdsBidRequest.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBAdsBidConstants.h"
#import "HBBidNetworkItem.h"
#import "HBAuctionResult.h"
#import "HBAdBidResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBAdsBidRequest : NSObject



/**
 Reqeust a series Nework Bid,and response the best suitable bid
 Default max time out is set to 1000 ms
 */
+ (void)getBidNetworks:(NSArray<HBBidNetworkItem *>*)networkItems statisticsInfo:(NSDictionary*)statisticsInfo unitId:(NSString *)unitId adFormat:(HBAdBidFormat)format maxTimeoutMS:(NSInteger)maxTimeoutMS responseCallback:(void(^)(HBAuctionResult *auctionResponse,NSError *error))callback;



@end

NS_ASSUME_NONNULL_END
