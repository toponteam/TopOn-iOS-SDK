//
//  ATApplovinRewardedVideoCustomEvent.h
//  AnyThinkApplovinRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATRewardedVideoCustomEvent.h"
#import "ATApplovinRewardedVideoAdapter.h"
@interface ATApplovinRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate, ALAdRewardDelegate>
@property(nonatomic) id<ATALIncentivizedInterstitialAd> incentivizedInterstitialAd;
@end
