//
//  HBAuctionResult+Addition.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/15.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBAuctionResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBAuctionResult (Addition)

+ (HBAuctionResult *)buildAuctionResult:(HBAdBidResponse *)winner otherResponses:(NSArray *)responses;

@end

NS_ASSUME_NONNULL_END
