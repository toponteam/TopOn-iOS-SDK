//
//  HBAuctionResult.m
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/15.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBAuctionResult.h"

@interface HBAuctionResult()

@property (nonatomic,strong,readwrite) HBAdBidResponse *winner;
@property (nonatomic,strong,readwrite) NSArray<HBAdBidResponse *> *otherResponse;

@end

@implementation HBAuctionResult


+ (HBAuctionResult *)buildAuctionResult:(HBAdBidResponse *)winner otherResponses:(NSArray *)responses{
    HBAuctionResult *result = [[HBAuctionResult alloc] init];
    result.winner = winner;
    result.otherResponse = responses;
    return result;
}



@end
