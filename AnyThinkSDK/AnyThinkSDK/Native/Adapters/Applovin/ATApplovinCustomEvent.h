//
//  ATApplovinCustomEvent.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATVideoView.h"
#import "ATApplovinNativeAdapter.h"
@interface ATApplovinCustomEvent : ATNativeADCustomEvent<ALNativeAdLoadDelegate, ATVideoViewDelegate>
-(void) didClickAdView;
@end
