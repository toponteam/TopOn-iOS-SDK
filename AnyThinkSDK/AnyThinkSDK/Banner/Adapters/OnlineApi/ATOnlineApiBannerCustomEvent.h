//
//  ATOnlineApiBannerCustomEvent.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkBanner/AnyThinkBanner.h>
#import "ATOnlineApiBannerDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@class ATOnlineApiOfferModel, ATOnlineApiPlacementSetting,ATUnitGroupModel;
@interface ATOnlineApiBannerCustomEvent : ATBannerCustomEvent<ATOnlineApiBannerDelegate>

@property (nonatomic, readwrite) ATUnitGroupModel *unitGroupModel;
@property (nonatomic, strong) ATOnlineApiOfferModel *offerModel;
@property (nonatomic, strong) ATOnlineApiPlacementSetting *setting;

@end

NS_ASSUME_NONNULL_END
