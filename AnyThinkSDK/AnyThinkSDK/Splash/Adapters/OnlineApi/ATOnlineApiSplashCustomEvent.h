//
//  ATOnlineApiSplashCustomEvent.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>

NS_ASSUME_NONNULL_BEGIN

@class ATOnlineApiOfferModel,ATPlacementModel,ATUnitGroupModel,ATOnlineApiPlacementSetting;

@interface ATOnlineApiSplashCustomEvent : ATSplashCustomEvent
@property(nonatomic) UIView *containerView;
@property(nonatomic, readwrite) ATPlacementModel *placementModel;
@property(nonatomic, readwrite) ATUnitGroupModel *unitGroupModel;
@property (nonatomic, strong) ATOnlineApiOfferModel *offerModel;
@property (nonatomic) ATOnlineApiPlacementSetting *setting;
@end

NS_ASSUME_NONNULL_END
