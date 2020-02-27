//
//  ATInmobiNativeADRenderer.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 21/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiNativeADRenderer.h"
#import "ATInmobiNativeAdapter.h"
#import "ATNativeADView.h"
#import "ATNativeADConfiguration.h"
#import "ATInmobiCustomEvent.h"
#import "NSObject+ATCustomEvent.h"
#import "ATNativeADView+Internal.h"
#import "ATInmobiCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "ATNativeADCache.h"

@interface ATInmobiNativeADRenderer()
/**
 The IMNative need to do some cleanup
 */
@property(nonatomic, readonly) id<ATIMNative> currentNative;
@end
@implementation ATInmobiNativeADRenderer
-(void) dealloc {
    _currentNative.delegate = nil;
    [_currentNative recyclePrimaryView];
}

-(__kindof UIView*)createMediaView {
    id<ATIMNative> nativeAd = (id<ATIMNative>)(((ATNativeADCache*)(self.ADView.nativeAd)).assets[kAdAssetsCustomObjectKey]);
    
    self.currentNative = nativeAd;
    UIView *view = [nativeAd primaryViewOfWidth:CGRectGetWidth(self.configuration.ADFrame)];
    view.frame = self.configuration.ADFrame;
    return view;
}

-(void) setCurrentNative:(id<ATIMNative>)currentNative {
    _currentNative = currentNative;
   
    [self bindCustomEvent];
}

-(void) bindCustomEvent {
    ATInmobiCustomEvent *customEvent = [ATInmobiCustomEvent new];
    self.ADView.customEvent = customEvent;
    customEvent.adView = self.ADView;
    
    self.currentNative.delegate = customEvent;
}
@end
