//
//  ATKSNativeCustomEvent.h
//  AnyThinkKSNaitveAdapter
//
//  Created by Topon on 2020/2/5.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATNativeADCustomEvent.h"
#import "ATKSNativeAdapter.h"
extern NSString *const kATKSNativeExpressAdManager;

@interface ATKSNativeCustomEvent : ATNativeADCustomEvent <ATKSNativeAdDelegate,ATKSNativeAdsManagerDelegate,ATKSFeedAdDelegate,ATKSFeedAdsManagerDelegate,ATKSDrawAdsManagerDelegate,ATKSDrawAdDelegate>
@property (nonatomic)BOOL videoSoundEnable;
@property (nonatomic)BOOL isVideo;
@end


