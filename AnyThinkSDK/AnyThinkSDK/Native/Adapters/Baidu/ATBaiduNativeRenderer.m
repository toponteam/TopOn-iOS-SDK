//
//  ATBaiduNativeRenderer.m
//  AnyThinkBaiduNativeAdapter
//
//  Created by Martin Lau on 2019/7/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATBaiduNativeRenderer.h"
#import "ATAdManagement.h"
#import "NSObject+ATCustomEvent.h"
#import "ATNativeADView.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATAPI+Internal.h"
#import "ATTracker.h"
#import "ATPlacementModel.h"
#import "ATBaiduNativeCustomEvent.h"
@interface ATBaiduNativeRenderer()
@property(nonatomic, readonly, weak) ATBaiduNativeCustomEvent *customEvent;
@end
@interface ATNativeADView(BaiduNative)
@property(nonatomic) ATBaiduNativeCustomEvent *customEvent;
@end
@implementation ATBaiduNativeRenderer
-(__kindof UIView*)createMediaView {
    [self bindCustomEvent];
    ATNativeADCache *offer = (ATNativeADCache*)self.ADView.nativeAd;
    id<ATBaiduMobAdNativeAdObject> nativeAdObject = offer.assets[kAdAssetsCustomObjectKey];
    if (nativeAdObject.materialType == ATBaiduMertialTypeVideo) {
        id<ATBaiduMobAdNativeVideoView> videoView = [[NSClassFromString(@"BaiduMobAdNativeVideoView") alloc] initWithFrame:CGRectZero andObject:offer.assets[kAdAssetsCustomObjectKey]];
        return (UIView*)videoView;
    } else if (nativeAdObject.materialType == ATBaiduMertialTypeHTML) {
        return [UIView new];
    } else {
        return [UIView new];
    }
}

-(void) bindCustomEvent {
    ATNativeADCache *offer = (ATNativeADCache*)self.ADView.nativeAd;
    _customEvent = offer.assets[kAdAssetsCustomEventKey];
    _customEvent.unitID = offer.unitID;
    
    _customEvent.adView = self.ADView;
    self.ADView.customEvent = _customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    id<ATBaiduMobAdNativeAdObject> nativeAdObject = offer.assets[kAdAssetsCustomObjectKey];
    id<ATBaiduMobAdNativeAdView> nativeAdView = nil;
    if (nativeAdObject.materialType == ATBaiduMertialTypeNormal) {
        nativeAdView = [[NSClassFromString(@"BaiduMobAdNativeAdView") alloc] initWithFrame:self.ADView.bounds brandName:nil title:nil text:nil icon:nil mainImage:nil];
    } else if (nativeAdObject.materialType == ATBaiduMertialTypeVideo) {
        nativeAdView = [[NSClassFromString(@"BaiduMobAdNativeAdView") alloc] initWithFrame:self.ADView.bounds brandName:nil title:nil text:nil icon:nil mainImage:nil videoView:(id<ATBaiduMobAdNativeVideoView>)self.ADView.mediaView];
        [((id<ATBaiduMobAdNativeVideoView>)(self.ADView.mediaView)) play];
    } else  if (nativeAdObject.materialType == ATBaiduMertialTypeHTML) {
        id<ATBaiduMobAdNativeWebView> webView = [[NSClassFromString(@"BaiduMobAdNativeWebView") alloc] initWithFrame:self.ADView.mediaView.frame andObject:nativeAdObject];
        nativeAdView = [[NSClassFromString(@"BaiduMobAdNativeAdView") alloc] initWithFrame:self.ADView.bounds webview:webView];
    }
    if (nativeAdView != nil) { [self.ADView insertSubview:(UIView*)nativeAdView atIndex:0]; }
    [[self.ADView clickableViews] enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(addGestureRecognizer:)]) {
            obj.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
            [obj addGestureRecognizer:tap];
        }
    }];
}

-(void) viewTapped:(UITapGestureRecognizer*)tap {
    ATNativeADCache *offer = (ATNativeADCache*)self.ADView.nativeAd;
    id<ATBaiduMobAdNativeAdObject> nativeAdObject = offer.assets[kAdAssetsCustomObjectKey];
    [nativeAdObject handleClick:tap.view];
}

-(BOOL)isVideoContents {
    ATNativeADCache *offer = (ATNativeADCache*)self.ADView.nativeAd;
    return ((id<ATBaiduMobAdNativeAdObject>)(offer.assets[kAdAssetsCustomObjectKey])).materialType == ATBaiduMertialTypeVideo;
}
@end
