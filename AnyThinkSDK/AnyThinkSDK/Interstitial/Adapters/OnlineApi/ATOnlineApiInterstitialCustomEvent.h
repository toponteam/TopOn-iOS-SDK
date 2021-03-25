//
//  ATOnlineApiInterstitialCustomEvent.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import "ATOnlineApiInterstitialDelegate.h"
#import "ATOnlineApiLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATOnlineApiInterstitialCustomEvent : ATInterstitialCustomEvent<ATOnlineApiInterstitialDelegate, ATOnlineApiLoadingDelegate>
@property(nonatomic, readwrite) ATPlacementModel *placementModel;
@property(nonatomic, readwrite) ATUnitGroupModel *unitGroupModel;
@property (nonatomic, strong) ATOnlineApiOfferModel *offerModel;
@end

NS_ASSUME_NONNULL_END
