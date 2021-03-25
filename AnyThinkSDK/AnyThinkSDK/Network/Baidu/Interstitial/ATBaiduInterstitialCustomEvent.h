//
//  ATBaiduInterstitialCustomEvent.h
//  AnyThinkBaiduInterstitialAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATBaiduInterstitialAdapter.h"
NS_ASSUME_NONNULL_BEGIN

@interface ATBaiduInterstitialCustomEvent : ATInterstitialCustomEvent<BaiduMobAdInterstitialDelegate,BaiduMobAdExpressFullScreenVideoDelegate>

@end

NS_ASSUME_NONNULL_END
