//
//  ATMintegralInterstitialCustomEvent.h
//  AnyThinkMintegralInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATMintegralInterstitialAdapter.h"
@interface ATMintegralInterstitialCustomEvent : ATInterstitialCustomEvent<ATMTGInterstitialAdLoadDelegate, ATMTGInterstitialAdShowDelegate, ATMTGInterstitialVideoDelegate>
@property(nonatomic) double price;
@end
