//
//  ATBaiduNativeCustomEvent.h
//  AnyThinkBaiduNativeAdapter
//
//  Created by Martin Lau on 2019/7/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATBaiduNativeAdapter.h"
@interface ATBaiduNativeCustomEvent : ATNativeADCustomEvent<BaiduMobAdNativeAdDelegate>
@property(nonatomic) id<ATBaiduMobAdNative> baiduNative;
@end
