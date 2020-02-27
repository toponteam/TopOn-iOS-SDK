//
//  HBAdBidResponse+Addition.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBAdBidResponse.h"


@interface HBAdBidResponse (Addition)

+ (HBAdBidResponse *)buildResponseWithError:(NSError *)error withNetwork:(HBBidNetworkItem *)networkItem;

+ (HBAdBidResponse *)buildResponseWithPrice:(double)price
                                   currency:(NSString *)currency
                                    payLoad:(NSObject *)payLoad
                                    network:(HBBidNetworkItem *)networkItem
                                  adsRender:(id)adsRender
                                  notifyWin:(void (^)(void))win
                                 notifyLoss:(void (^)(void))loss;

- (void)appendUnitId:(NSString *)unitId;

- (void)loss;
- (void)win;


@end

