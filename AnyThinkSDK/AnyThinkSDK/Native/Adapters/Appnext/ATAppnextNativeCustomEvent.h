//
//  ATAppnextNativeCustomEvent.h
//  AnyThinkAppnextNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATAppnextNativeAdapter.h"
NS_ASSUME_NONNULL_BEGIN

@interface ATAppnextNativeCustomEvent : ATNativeADCustomEvent<AppnextNativeAdsRequestDelegate, AppnextNativeAdOpenedDelegate>
@property(nonatomic) id<ATAppnextNativeAdsSDKApi> api;
@end

NS_ASSUME_NONNULL_END
