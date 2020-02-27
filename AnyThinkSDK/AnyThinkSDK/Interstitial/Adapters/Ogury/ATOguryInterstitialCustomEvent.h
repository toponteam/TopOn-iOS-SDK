//
//  ATOguryInterstitialCustomEvent.h
//  AnyThinkOguryInterstitialAdapter
//
//  Created by Topon on 2019/11/27.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATOguryInterstitialAdapter.h"
#import "ATInterstitialCustomEvent.h"

@interface ATOguryInterstitialCustomEvent : ATInterstitialCustomEvent <ATOguryAdsInterstitialDelegate>

@property (nonatomic,strong)id<ATOguryAdsInterstitial> oguryAds;
@end


