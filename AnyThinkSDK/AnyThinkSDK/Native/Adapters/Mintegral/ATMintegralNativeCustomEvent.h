//
//  ATMintegralNativeCustomEvent.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATNativeADCustomEvent.h"
#import "ATMintegralNativeAdapter.h"
//@import AnyThinkNative;
extern NSString *const kMTGAssetsNativeAdManagerKey;
@interface ATMintegralNativeCustomEvent : ATNativeADCustomEvent<ATMTGNativeAdManagerDelegate, ATMTGMediaViewDelegate, MTGBidNativeAdManagerDelegate>
@property(nonatomic) id<ATMTGNativeAdManager> nativeAdManager;
@property(nonatomic) id<ATMTGBidNativeAdManager> bidNativeAdManager;
@end
