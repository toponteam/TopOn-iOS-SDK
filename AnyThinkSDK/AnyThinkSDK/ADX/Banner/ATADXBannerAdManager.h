//
//  ATADXBannerAdManager.h
//  AnyThinkSDK
//
//  Created by Topon on 10/22/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXAdManager.h"
#import "ATADXBannerDelegate.h"
#import "ATADXOfferModel.h"
#import "ATADXPlacementSetting.h"
#import "ATOfferBannerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATADXBannerAdManager : ATADXAdManager
+(instancetype) sharedManager;
- (ATOfferBannerView *)retrieveBannerViewWithOfferModel:(ATADXOfferModel *)offerModel setting:(ATADXPlacementSetting *)setting  extra:(NSDictionary *)extra delegate:(id<ATADXBannerDelegate>) delegate;
@end

NS_ASSUME_NONNULL_END
