//
//  ATTTNativeRenderer.m
//  AnyThinkTTNativeAdapter
//
//  Created by Martin Lau on 2018/12/29.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTNativeRenderer.h"
#import "NSObject+ATCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATPlacementModel.h"
#import "ATTTNativeCustomEvent.h"
#import "ATNativeADView+Internal.h"
#import "ATAdManager+Native.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "Utilities.h"
#import "ATAPI+Internal.h"
#import "ATAdManagement.h"
#import "ATNativeAdView.h"
#import <objc/runtime.h>
#import "ATNativeADConfiguration.h"

@protocol ATNativeADView<NSObject>
@property(nonatomic, readonly) ATNativeADCache *nativeAd;
@end

@interface ATNativeADView(DrawRender)
-(void) bindRelatedView:(id<ATBUNativeAdRelatedView>)relatedView;
-(void) detatchRelatedView;
@property (nonatomic, strong, nullable) UIButton *dislikeButton;
@property (nonatomic, strong, nullable) UILabel *adLabel;
@property (nonatomic, strong, nullable) UIImageView *logoImageView;
@property (nonatomic, strong, nullable) UIImageView *logoADImageView;
@property (nonatomic, strong, nullable) UIView *videoAdView;
@end

@interface ATTTNativeRenderer()
@property(nonatomic, readonly) id<ATBUNativeAdRelatedView> relatedView;
@end
@implementation ATTTNativeRenderer
-(__kindof UIView*)createMediaView {
    return nil;
}


-(void) bindCustomEvent {
    ATTTNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
}

-(void) dealloc {
    [self.ADView detatchRelatedView];
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    [self bindCustomEvent];
    id<ATBUNativeAd> nativeAd = offer.assets[kAdAssetsCustomObjectKey];
    nativeAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    ATTTNativeCustomEvent *customEvent = (ATTTNativeCustomEvent*)self.ADView.customEvent;
    if (customEvent.isVideo && NSClassFromString(@"BUNativeAdRelatedView") != nil && [nativeAd isKindOfClass:NSClassFromString(@"BUNativeAd")]) {
        _relatedView = [[NSClassFromString(@"BUNativeAdRelatedView") alloc] init];
        _relatedView.videoAdView.drawVideoClickEnable = YES;
        _relatedView.videoAdView.delegate = (ATTTNativeCustomEvent*)self.ADView.customEvent;
        _relatedView.videoAdView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self.ADView bindRelatedView:_relatedView];
        [_relatedView refreshData:nativeAd];
        if ([self.ADView respondsToSelector:@selector(makeConstraintsDrawVideoAssets)]) { [self.ADView makeConstraintsDrawVideoAssets]; }
        self.ADView.mediaView.hidden = YES;
        [self.ADView sendSubviewToBack:self.ADView.videoAdView];
    } else if (NSClassFromString(@"BUNativeExpressAdView") != nil && [nativeAd isKindOfClass:NSClassFromString(@"BUNativeExpressAdView")]) {
        id<ATBUNativeExpressAdManager> nativeExpressAd = offer.assets[kATTTNativeExpressAdManager];
        nativeExpressAd.delegate = customEvent;
        id<ATBUNativeExpressAdView> nativeFeed = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomObjectKey];
        nativeFeed.rootViewController = self.configuration.rootViewController;
        [nativeFeed render];
        [self.ADView addSubview:(UIView*)nativeFeed];
        nativeFeed.center = CGPointMake(CGRectGetMidX(self.ADView.bounds), CGRectGetMidY(self.ADView.bounds));
    } else {
        [self.ADView detatchRelatedView];
    }
    
    if ([nativeAd respondsToSelector:@selector(setDelegate:)]) {
        nativeAd.delegate = customEvent;
    }
    if ([nativeAd respondsToSelector:@selector(registerContainer:withClickableViews:)]) {
        [nativeAd registerContainer:self.ADView withClickableViews:[self.ADView clickableViews]];
    }
}

-(BOOL)isVideoContents {
    ATTTNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    return customEvent.isVideo;
}
@end

#pragma mark - draw video
static NSString *const kDislikeButtonKey = @"dislike_button";
static NSString *const kAdLabelKey = @"ad_label";
static NSString *const kLogoImageViewKey = @"logo_image_view";
static NSString *const kLogoAdImageViewKey = @"logo_ad_image_view";
static NSString *const kVideoAdViewKey = @"video_ad_view";
@implementation ATNativeADView (DrawRender)
-(void) detatchRelatedView {
    [self.dislikeButton removeFromSuperview];
    [self.adLabel removeFromSuperview];
    [self.logoImageView removeFromSuperview];
    [self.logoADImageView removeFromSuperview];
    [self.videoAdView removeFromSuperview];
}

-(void) bindRelatedView:(id<ATBUNativeAdRelatedView>)relatedView {
    self.dislikeButton = relatedView.dislikeButton;
    self.adLabel = relatedView.adLabel;
    self.logoImageView = relatedView.logoImageView;
    self.logoADImageView = relatedView.logoADImageView;
    self.videoAdView = relatedView.videoAdView;
}

-(void) setDislikeButton:(UIButton *)dislikeButton {
    if (dislikeButton != nil) {
        [self addSubview:dislikeButton];
        objc_setAssociatedObject(self, (__bridge_retained void*)kDislikeButtonKey, dislikeButton, OBJC_ASSOCIATION_RETAIN);
    }
}

-(UIButton*)dislikeButton {
    return objc_getAssociatedObject(self, (__bridge_retained void*)kDislikeButtonKey);
}

-(void) setAdLabel:(UILabel *)adLabel {
    if (adLabel != nil) {
        [self addSubview:adLabel];
        objc_setAssociatedObject(self, (__bridge_retained void*)kAdLabelKey, adLabel, OBJC_ASSOCIATION_RETAIN);
    }
}

-(UILabel*)adLabel {
    return objc_getAssociatedObject(self, (__bridge_retained void*)kAdLabelKey);
}

-(void) setLogoImageView:(UIImageView *)logoImageView {
    if (logoImageView != nil) {
        [self addSubview:logoImageView];
        objc_setAssociatedObject(self, (__bridge_retained void*)kLogoImageViewKey, logoImageView, OBJC_ASSOCIATION_RETAIN);
    }
}

-(UIImageView*)logoImageView {
    return objc_getAssociatedObject(self, (__bridge_retained void*)kLogoImageViewKey);
}

-(void) setLogoADImageView:(UIImageView *)logoADImageView {
    if (logoADImageView != nil) {
        [self addSubview:logoADImageView];
        objc_setAssociatedObject(self, (__bridge_retained void*)kLogoAdImageViewKey, logoADImageView, OBJC_ASSOCIATION_RETAIN);
    }
}

-(UIImageView*)logoADImageView {
    return objc_getAssociatedObject(self, (__bridge_retained void*)kLogoAdImageViewKey);
}

-(void) setVideoAdView:(UIView *)videoAdView {
    if (videoAdView != nil) {
        [self addSubview:videoAdView];
        objc_setAssociatedObject(self, (__bridge_retained void*)kVideoAdViewKey, videoAdView, OBJC_ASSOCIATION_RETAIN);
    }
}

-(UIView*)videoAdView {
    return objc_getAssociatedObject(self, (__bridge_retained void*)kVideoAdViewKey);
}
@end
