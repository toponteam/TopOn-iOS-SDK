//
//  HBBidAdapter.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBAdsBidConstants.h"
@class HBBidNetworkItem;
@class HBAdBidResponse;

NS_ASSUME_NONNULL_BEGIN

@interface HBBidAdapter : NSObject

@property (nonatomic,strong,readonly) HBAdBidResponse *bidResponse;

- (void)getBidNetwork:(HBBidNetworkItem *)networkItem adFormat:(HBAdBidFormat)format responseCallback:(void(^)(HBAdBidResponse *bidResponse))callback;

- (void)win;
- (void)loss;

@end

NS_ASSUME_NONNULL_END
