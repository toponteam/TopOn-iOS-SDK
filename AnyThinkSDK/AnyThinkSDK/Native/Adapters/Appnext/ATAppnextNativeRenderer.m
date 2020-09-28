//
//  ATAppnextNativeRenderer.m
//  AnyThinkAppnextNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextNativeRenderer.h"
#import "ATAPI+Internal.h"
#import "ATNativeADView.h"
#import "ATAppnextNativeCustomEvent.h"
#import "ATNativeADView+Internal.h"
#import "ATNativeADCache.h"
#import "ATNativeADRenderer.h"
#import "ATAppnextNativeAdapter.h"
@protocol ATNativeADView<NSObject>
@property(nonatomic, readonly) ATNativeADCache *nativeAd;
@end
@implementation ATAppnextNativeRenderer
-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    id<ATAppnextNativeAdsSDKApi> api = offer.assets[kAppnextNativeAssetsAPIObjectKey];
    [api adImpression:offer.assets[kAdAssetsCustomObjectKey]];
    [self bindCustomEvent];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped)];
    [self.ADView addGestureRecognizer:tap];
}

-(void) adViewTapped {
    [self.ADView.customEvent trackNativeAdClick];
    id<ATAppnextNativeAdsSDKApi> api = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAppnextNativeAssetsAPIObjectKey];
    id<ATAppnextAdData> nativeAd = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomObjectKey];
    [api adClicked:nativeAd withAdOpenedDelegate:(ATAppnextNativeCustomEvent*)self.ADView.customEvent];
}

-(__kindof UIView*)createMediaView {
    UIView *view = [UIView new];
    return view;
}

-(void) bindCustomEvent {
    ATAppnextNativeCustomEvent *customEvent = [ATAppnextNativeCustomEvent new];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
}

-(BOOL)isVideoContents {
    id<ATAppnextAdData> nativeAd = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomObjectKey];
    return [nativeAd.urlVideo length] > 0;
}
@end
