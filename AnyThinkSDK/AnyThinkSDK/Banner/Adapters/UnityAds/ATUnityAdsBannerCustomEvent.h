//
//  ATUnityAdsBannerCustomEvent.h
//  AnyThinkUnityAdsBannerAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATUnityAdsBannerAdapter.h"

@interface ATUnityAdsBannerCustomEvent : ATBannerCustomEvent<UnityAdsBannerDelegate, UnityAdsDelegate>
@property(nonatomic) UIView *bannerContainerView;
@end
