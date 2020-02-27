//
//  ATYeahmobiNativeRenderer.m
//  AnyThinkYeahmobiNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATYeahmobiNativeRenderer.h"
#import "ATYeahmobiNativeAdapter.h"
#import "ATYeahmobiNativeCustomEvent.h"
#import "ATNativeADView+Internal.h"
#import "ATAdManager+Native.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "Utilities.h"
#import "ATAPI+Internal.h"
#import "ATNativeADCache.h"

@protocol ATNativeADView<NSObject>
@property(nonatomic, readonly) ATNativeADCache *nativeAd;
@end
@implementation ATYeahmobiNativeRenderer
-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    [self bindCustomEvent];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped)];
    [self.ADView addGestureRecognizer:tap];
    id<ATCTNativeAdModel> nativeAd = offer.assets[kAdAssetsCustomObjectKey];
    [nativeAd impressionForAd];
}

-(void) adViewTapped {
    id<ATCTNativeAdModel> nativeAd = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomObjectKey];
    [nativeAd clickAdJumpToMarker];
    [self.ADView notifyNativeAdClick];
    ATYeahmobiNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kYearmobiNativeAssetsCustomEventKey];
    [customEvent trackClick];
}

-(__kindof UIView*)createMediaView {
    UIView *view = [UIView new];
    return view;
}

-(void) bindCustomEvent {
    ATYeahmobiNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kYearmobiNativeAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
    id<ATCTNativeAdModel> nativeAd = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomObjectKey];
    nativeAd.delegate = customEvent;
}

-(BOOL)isVideoContents {
    return NO;
}
@end
