//
//  ATAdMobCustomEvent.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 26/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATAdmobNativeAdapter.h"
@protocol GADUnifiedNativeAdLoaderDelegate<NSObject>
@end
@protocol GADVideoControllerDelegate<NSObject>
@end
@protocol GADUnifiedNativeAdDelegate<NSObject>
@end
@interface ATAdMobCustomEvent : ATNativeADCustomEvent<GADUnifiedNativeAdLoaderDelegate, GADVideoControllerDelegate, GADUnifiedNativeAdDelegate, ATGADAdLoaderDelegate>

@end
