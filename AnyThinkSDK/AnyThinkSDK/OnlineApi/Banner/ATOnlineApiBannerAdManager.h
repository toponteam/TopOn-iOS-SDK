//
//  ATOnlineApiBannerAdManager.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiAdManager.h"
#import "ATOfferBannerView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ATOnlineApiBannerDelegate;
@class ATOnlineApiPlacementSetting, ATOnlineApiOfferModel;
@interface ATOnlineApiBannerAdManager : ATOnlineApiAdManager

+ (instancetype)sharedManager;
- (ATOfferBannerView *)retrieveBannerViewWithOfferModel:(ATOnlineApiOfferModel *)offerModel setting:(ATOnlineApiPlacementSetting *)setting extra:(NSDictionary *)extra delegate:(id<ATOnlineApiBannerDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
