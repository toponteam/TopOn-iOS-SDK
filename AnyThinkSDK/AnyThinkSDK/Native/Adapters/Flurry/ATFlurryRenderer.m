//
//  ATFlurryRenderer.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFlurryRenderer.h"
#import "ATAPI.h"
#import "ATNativeADView.h"
#import "ATFlurryCustomEvent.h"
#import "ATNativeADView+Internal.h"
#import "ATNativeADCache.h"
#import "ATNativeADRenderer.h"
#import "ATFlurryNativeAdapter.h"

@implementation ATFlurryRenderer
-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    id<ATFlurryAdNative> nativeAd = offer.customObject;
    nativeAd.viewControllerForPresentation = [UIApplication sharedApplication].keyWindow.rootViewController;
    nativeAd.trackingView = self.ADView;
    if (nativeAd.isVideoAd) nativeAd.videoViewContainer = self.ADView.mediaView;
    [self bindCustomEvent];
}

-(__kindof UIView*)createMediaView {
    UIView *view = [UIView new];
    view.userInteractionEnabled = NO;
    return view;
}

-(void) bindCustomEvent {
    ATFlurryCustomEvent *customEvent = [ATFlurryCustomEvent new];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
    ((id<ATFlurryAdNative>)(((ATNativeADCache*)(self.ADView.nativeAd)).customObject)).adDelegate = customEvent;
}

-(BOOL)isVideoContents {
    return ((id<ATFlurryAdNative>)(((ATNativeADCache*)self.ADView.nativeAd).customObject)).isVideoAd;
}
@end
