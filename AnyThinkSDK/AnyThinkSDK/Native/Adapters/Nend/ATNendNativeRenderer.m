//
//  ATNendNativeRenderer.m
//  AnyThinkNendNativeAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendNativeRenderer.h"
#import "NSObject+ATCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATPlacementModel.h"
#import "ATAdManager+Native.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "Utilities.h"
#import "ATAPI+Internal.h"
#import "ATAdManagement.h"
#import "ATNativeAdView+Internal.h"
#import <objc/runtime.h>
#import "ATNendNativeCustomEvent.h"
#import "ATNativeRendering.h"

@interface ATNativeADView(NendRendering)<NADNativeViewRendering>
@end

@implementation ATNativeADView (NendRendering)
- (UIImageView *)adImageView {
    return self.mainImageView;
}

- (UIImageView *)nadLogoImageView {
    return self.iconImageView;
}

- (UILabel *)shortTextLabel {
    return self.titleLabel;
}

- (UILabel *)longTextLabel {
    return self.textLabel;
}

- (UILabel *)promotionUrlLabel {
    return nil;
}

- (UILabel *)promotionNameLabel {
    return self.advertiserLabel;
}

- (UILabel *)actionButtonTextLabel {
    return self.ctaLabel;
}

- (UILabel *)prTextLabel {
    return self.advertiserLabel;
}
@end

@interface ATNendNativeRenderer()
@property(nonatomic, weak) id<ATNADNativeVideoView> videoView;
@end
@implementation ATNendNativeRenderer
-(__kindof UIView*)createMediaView {
    ATNendNativeCustomEvent *customEvent = ((ATNativeADCache*)(((ATNativeADView*)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    if (customEvent.isVideo) {
        id<ATNADNativeVideoView> videoViwe = [NSClassFromString(@"NADNativeVideoView") new];
        _videoView = videoViwe;
        id<ATNADNativeVideo> nativeVideo = ((ATNativeADCache*)(((ATNativeADView*)self.ADView).nativeAd)).assets[kAdAssetsCustomObjectKey];
        _videoView.videoAd = nativeVideo;
        if (self.ADView.customEvent != nil) { _videoView.delegate = (ATNendNativeCustomEvent*)self.ADView.customEvent; }
        return (UIView*)videoViwe;
    } else {
        return nil;
    }
}

-(void) bindCustomEvent {
    ATNendNativeCustomEvent *customEvent = ((ATNativeADCache*)(((ATNativeADView*)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
    if (_videoView != nil) { _videoView.delegate = customEvent; }
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    [self bindCustomEvent];
    ATNendNativeCustomEvent *customEvent = ((ATNativeADCache*)(((ATNativeADView*)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    id customObject = offer.assets[kAdAssetsCustomObjectKey];
    if (customEvent.isVideo) {
        id<ATNADNativeVideo> nativeVideo = (id<ATNADNativeVideo>)customObject;
        nativeVideo.delegate = customEvent;
        if ([[self.ADView clickableViews] count] > 0) { [nativeVideo registerInteractionViews:[self.ADView clickableViews]]; }
        _videoView.videoAd = nativeVideo;
    } else {
        id<ATNADNative> native = (id<ATNADNative>)customObject;
        native.delegate = customEvent;
        [native activateAdView:self.ADView withPrLabel:self.ADView.advertiserLabel];
    }
}

-(BOOL)isVideoContents {
    ATNendNativeCustomEvent *customEvent = ((ATNativeADCache*)(((ATNativeADView*)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    return customEvent.isVideo;
}
@end
