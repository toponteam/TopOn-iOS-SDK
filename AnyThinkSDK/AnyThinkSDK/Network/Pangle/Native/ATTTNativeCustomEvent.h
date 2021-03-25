//
//  ATTTNativeCustomEvent.h
//  AnyThinkTTNativeAdapter
//
//  Created by Martin Lau on 2018/12/29.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATTTNativeAdapter.h"
extern NSString *const kATTTNativeExpressAdManager;
@interface ATTTNativeCustomEvent : ATNativeADCustomEvent<BUNativeAdsManagerDelegate, BUNativeAdDelegate, BUVideoAdViewDelegate ,ATBUNativeExpressAdViewDelegate>
@property(nonatomic) BOOL isVideo;
@property(nonatomic) BOOL isFailed;
@end
