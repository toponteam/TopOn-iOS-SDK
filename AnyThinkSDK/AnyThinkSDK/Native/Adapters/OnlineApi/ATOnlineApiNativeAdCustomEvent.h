//
//  ATOnlineApiNativeAdCustomEvent.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import "ATOnlineApiNativeDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class ATOnlineApiPlacementSetting, ATOnlineApiOfferModel, ATUnitGroupModel;
@interface ATOnlineApiNativeAdCustomEvent : ATNativeADCustomEvent<ATOnlineApiNativeDelegate>

@property(nonatomic, strong) ATUnitGroupModel *unitGroupModel;
@property (nonatomic, strong) ATOnlineApiOfferModel *offerModel;
@property (nonatomic, strong) ATOnlineApiPlacementSetting *setting;

@end

NS_ASSUME_NONNULL_END
