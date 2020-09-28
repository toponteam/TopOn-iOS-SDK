//
//  ATGoogleAdManagerNativeCustomEvent.h
//  AnyThinkGoogleAdManagerNativeAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATGoogleAdManagerNativeAdapter.h"
@protocol GADUnifiedNativeAdLoaderDelegate<NSObject>
@end
@protocol GADVideoControllerDelegate<NSObject>
@end
@protocol GADUnifiedNativeAdDelegate<NSObject>
@end
@interface ATGoogleAdManagerNativeCustomEvent : ATNativeADCustomEvent<GADUnifiedNativeAdLoaderDelegate, GADVideoControllerDelegate, GADUnifiedNativeAdDelegate, ATGADAdLoaderDelegate>

@end
