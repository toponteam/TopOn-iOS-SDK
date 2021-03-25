//
//  ATFacebookInterstitialCustomEvent.h
//  AnyThinkFacebookInterstitialAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATFacebookInterstitialAdapter.h"
@interface ATFacebookInterstitialCustomEvent : ATInterstitialCustomEvent<FBInterstitialAdDelegate>
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *bidId;
@end
