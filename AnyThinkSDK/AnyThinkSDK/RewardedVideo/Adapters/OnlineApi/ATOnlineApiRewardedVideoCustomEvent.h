//
//  ATOnlineApiRewardedVideoCustomEvent.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import "ATOnlineApiRewardedVideoDelegate.h"
#import "ATOnlineApiLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATOnlineApiRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<ATOnlineApiRewardedVideoDelegate>
@property(nonatomic, readwrite) ATPlacementModel *placementModel;
@property(nonatomic, readwrite) ATUnitGroupModel *unitGroupModel;
@property (nonatomic, strong) ATOnlineApiOfferModel *offerModel;
@end

NS_ASSUME_NONNULL_END
