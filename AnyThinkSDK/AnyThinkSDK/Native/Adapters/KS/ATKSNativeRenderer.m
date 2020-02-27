//
//  ATKSNativeRenderer.m
//  AnyThinkKSNaitveAdapter
//
//  Created by Topon on 2020/2/5.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKSNativeRenderer.h"
#import "NSObject+ATCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATPlacementModel.h"
#import "ATKSNativeCustomEvent.h"
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

@interface ATKSNativeRenderer ()
@property(nonatomic, readonly) ATKSNativeCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATKSNativeAd> nativeAd;
@property(nonatomic, readonly) id<ATKSFeedAd> feedAd;

@property(nonatomic) id<ATKSNativeAdRelatedView> relatedView;
@end

@implementation ATKSNativeRenderer
-(__kindof UIView*)createMediaView {
    return [UIView new];
}


-(void) bindCustomEvent {
    ATNativeADCache *offer = (ATNativeADCache*)self.ADView.nativeAd;
    _customEvent = [ATKSNativeCustomEvent new];
    _customEvent.unitID = offer.unitID;
    
    _customEvent.adView = self.ADView;
    self.ADView.customEvent = _customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    [self bindCustomEvent];
    id<KSAd> KSAD = offer.assets[kAdAssetsCustomObjectKey];
//    _customEvent = (ATKSNativeCustomEvent*)self.ADView.customEvent;
    if ([KSAD isKindOfClass:NSClassFromString(@"KSFeedAd")]) {
        id<ATKSFeedAd> feedAd = offer.assets[kAdAssetsCustomObjectKey];
        _feedAd = feedAd;
        _feedAd.delegate = _customEvent;
        _feedAd.feedView.frame = self.ADView.frame;
        [_feedAd setVideoSoundEnable:[offer.assets[kKSAdVideoSoundEnableFlag] boolValue]];
        [self.ADView addSubview:(UIView*)_feedAd.feedView];
        _feedAd.feedView.center = CGPointMake(CGRectGetMidX(self.ADView.bounds), CGRectGetMidY(self.ADView.bounds));
    } else if ([KSAD isKindOfClass:NSClassFromString(@"KSNativeAd")]) {
        id<ATKSNativeAd> nativeAd = offer.assets[kAdAssetsCustomObjectKey];
        _nativeAd = nativeAd;
        _nativeAd.delegate = _customEvent;
        _nativeAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([offer.assets[kKSNativeAdIsVideoFlag] boolValue]) {
            _relatedView = [NSClassFromString(@"KSNativeAdRelatedView") new];
            _relatedView.adLabel.text = nativeAd.data.actionDescription;
            if ([self.ADView respondsToSelector:@selector(mediaView)]) {
                self.relatedView.videoAdView.bounds = self.ADView.mediaView.bounds;
                self.relatedView.videoAdView.frame = CGRectMake(0, 0, self.relatedView.videoAdView.bounds.size.width, self.relatedView.videoAdView.bounds.size.height);
                [self.ADView.mediaView addSubview:(UIView *)self.relatedView.videoAdView];
            }
            self.relatedView.videoAdView.videoSoundEnable = [offer.assets[kKSAdVideoSoundEnableFlag] boolValue];
            [self.relatedView refreshData:_nativeAd];
        }
        if ([self.ADView respondsToSelector:@selector(makeConstraintsDrawVideoAssets)]) {
            [self.ADView makeConstraintsDrawVideoAssets];
        }
        if ([_nativeAd respondsToSelector:@selector(registerContainer:withClickableViews:)]) {
            [_nativeAd registerContainer:self.ADView withClickableViews:[self.ADView clickableViews]];
        }
    }

}

@end
