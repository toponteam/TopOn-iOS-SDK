//
//  ATMyTargetInterstitialCustomEvent.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import "ATMyTargetInterstitialApis.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATMyTargetInterstitialCustomEvent : ATInterstitialCustomEvent<MTRGInterstitialAdDelegate>

@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *bidID;

@end

NS_ASSUME_NONNULL_END
