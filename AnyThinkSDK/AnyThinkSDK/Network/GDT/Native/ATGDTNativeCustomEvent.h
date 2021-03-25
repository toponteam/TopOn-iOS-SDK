//
//  ATGDTNativeCustomEvent.h
//  AnyThinkGDTNativeAdapter
//
//  Created by Martin Lau on 26/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATGDTNativeAdapter.h"
@interface ATGDTNativeCustomEvent : ATNativeADCustomEvent<GDTNativeExpressAdDelegete, GDTNativeAdDelegate, GDTUnifiedNativeAdDelegate, GDTUnifiedNativeAdViewDelegate, GDTNativeExpressProAdManagerDelegate, GDTNativeExpressProAdViewDelegate>
@property(nonatomic, weak) id<ATGDTNativeAd> gdtNativeAd;
@property(nonatomic, weak) id<ATGDTVideoConfig> videoConfig;
@end
