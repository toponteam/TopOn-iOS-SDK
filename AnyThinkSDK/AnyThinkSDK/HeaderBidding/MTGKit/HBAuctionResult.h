//
//  HBAuctionResult.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/15.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBAdBidResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBAuctionResult : NSObject

@property (nonatomic,strong,readonly)  HBAdBidResponse *winner;
@property (nonatomic,strong,readonly) NSArray<HBAdBidResponse *> *otherResponse;

@end

NS_ASSUME_NONNULL_END
