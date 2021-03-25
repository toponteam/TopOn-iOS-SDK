//
//  ATSigmobInterstitialRewardedVideoDelegate.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/6/4.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATSigmobInterstitialAdapter.h"

@interface ATSigmobInterstitialRewardedVideoDelegate : NSObject<WindRewardedVideoAdDelegate>
+(instancetype) sharedDelegate;
@end
