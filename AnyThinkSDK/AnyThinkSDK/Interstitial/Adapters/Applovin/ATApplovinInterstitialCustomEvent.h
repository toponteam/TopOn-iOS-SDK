//
//  ATApplovinInterstitialCustomEvent.h
//  AnyThinkApplovinInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATApplovinInterstitialAdapter.h"
@interface ATApplovinInterstitialCustomEvent : ATInterstitialCustomEvent<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>
@end
