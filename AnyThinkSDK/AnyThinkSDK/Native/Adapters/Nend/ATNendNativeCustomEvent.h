//
//  ATNendNativeCustomEvent.h
//  AnyThinkNendNativeAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATNendNativeAdapter.h"
@interface ATNendNativeCustomEvent : ATNativeADCustomEvent<NADNativeDelegate, NADNativeVideoViewDelegate, NADNativeVideoDelegate>
-(void) handleNativeAds:(NSArray*)nativeAds error:(NSError*)error;
@property(nonatomic, getter=isVideo) BOOL video;
@end
