//
//  ATOnewayInterstitialCustomEvent.h
//  AnyThinkOnewayInterstitialAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATOnewayInterstitialAdapter.h"
@interface ATOnewayInterstitialCustomEvent : ATInterstitialCustomEvent<oneWaySDKInterstitialAdDelegate>
-(void) showWithTag:(NSString*)tag;
@end
