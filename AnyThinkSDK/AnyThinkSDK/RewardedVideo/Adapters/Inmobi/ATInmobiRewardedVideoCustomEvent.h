//
//  ATInmobiRewardedVideoCustomEvent.h
//  AnyThinkInmobiRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATRewardedVideoCustomEvent.h"
#import "ATInmobiRewardedVideoAdapter.h"
@interface ATInmobiRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<ATIMInterstitialDelegate>
@property(nonatomic) id<ATIMInterstitial> interstitial;
@end
