//
//  ATFacebookCustomEvent.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATNativeADCustomEvent.h"
#import "ATFacebookNativeAdapter.h"
extern NSString *const kATFBNativeADAssetsADChoiceImageKey;
extern NSInteger const kATFBNativeAdViewIconMediaViewFlag;
@interface ATFacebookCustomEvent : ATNativeADCustomEvent<FBNativeAdDelegate, ATFBMediaViewDelegate, FBNativeBannerAdDelegate>
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *bidId;
@end
