//
//  HBBidBaseCustomEvent.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBAdsBidConstants.h"
#import "HBBidNetworkItem.h"
#import "HBAdBidResponse.h"
#import "HBAdBidResponse+Addition.h"
#import "HBAdBidError.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBBidBaseCustomEvent : NSObject


- (void)getBidNetwork:(HBBidNetworkItem *)networkItem adFormat:(HBAdBidFormat)format responseCallback:(void(^)(HBAdBidResponse *bidResponse))callback;


@end

NS_ASSUME_NONNULL_END
