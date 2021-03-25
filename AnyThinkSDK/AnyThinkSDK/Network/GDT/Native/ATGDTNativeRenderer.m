//
//  ATGDTNativeRenderer.m
//  AnyThinkGDTNativeAdapter
//
//  Created by Martin Lau on 26/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTNativeRenderer.h"
#import "ATGDTNativeAdapter.h"
#import "NSObject+ATCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATPlacementModel.h"
#import "ATGDTNativeCustomEvent.h"
#import "ATNativeADView+Internal.h"
#import "ATAdManager+Native.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "Utilities.h"
#import "ATAPI+Internal.h"
#import "ATNativeADConfiguration.h"

@interface ATNativeADCache(GDTNative)
@property(nonatomic, readonly) NSInteger unitVersion;
@end
@implementation ATNativeADCache (GDTNative)
-(NSInteger) unitVersion { return [self.unitGroup.content[@"unit_version"] integerValue]; }
@end

@protocol ATNativeADView<NSObject>
@property(nonatomic, readonly) ATNativeADCache *nativeAd;
@end
@implementation ATGDTNativeRenderer
-(__kindof UIView*)createMediaView {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    [self bindCustomEvent];
    if ([cache.assets containsObjectForKey:kGDTNativeAssetsExpressAdViewKey]) {
        return [UIView new];
    } else {
        if (cache.unitVersion == 2) {
            return (UIView*)[NSClassFromString(@"GDTMediaView") new];
        } else {
            return [UIView new];
        }
    }
}

-(void) bindCustomEvent {
    ATGDTNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kGDTNativeAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    if ([offer.assets containsObjectForKey:kGDTNativeAssetsExpressAdViewKey]) {//template
        if (offer.unitVersion == 2) {
            id<ATGDTNativeExpressProAdManager> adManager = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kGDTNativeAssetsExpressAdKey];
            adManager.adParams.videoAutoPlayOnWWAN = offer.placementModel.wifiAutoSwitch;
            id<ATGDTNativeExpressProAdView> expressProAdView = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kGDTNativeAssetsExpressAdViewKey];
            expressProAdView.controller = self.configuration.rootViewController;
            expressProAdView.delegate = (ATGDTNativeCustomEvent*)offer.assets[kGDTNativeAssetsCustomEventKey];
            [expressProAdView render];
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth(expressProAdView.bounds), CGRectGetHeight(expressProAdView.bounds))];
            [containerView addSubview:(UIView*)expressProAdView];
            [self.ADView addSubview:containerView];
            containerView.center = CGPointMake(CGRectGetMidX(self.ADView.bounds), CGRectGetMidY(self.ADView.bounds));
        }else {
            id<ATGDTNativeExpressAd> expressAd = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kGDTNativeAssetsExpressAdKey];
            expressAd.videoAutoPlayOnWWAN = offer.placementModel.wifiAutoSwitch;
            id<ATGDTNativeExpressAdView> expressAdView = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kGDTNativeAssetsExpressAdViewKey];
            expressAdView.controller = self.configuration.rootViewController;
            [expressAdView render];
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth(expressAdView.bounds), CGRectGetHeight(expressAdView.bounds))];
            [containerView addSubview:(UIView*)expressAdView];
            [self.ADView addSubview:containerView];
            containerView.center = CGPointMake(CGRectGetMidX(self.ADView.bounds), CGRectGetMidY(self.ADView.bounds));
        }
    } else {
        if (offer.unitVersion == 2) {
            CGRect frame = [self.configuration.context[kATNativeAdConfigurationContextNetworkLogoViewFrameKey] respondsToSelector:@selector(CGRectValue)] ? [self.configuration.context[kATNativeAdConfigurationContextNetworkLogoViewFrameKey] CGRectValue] : CGRectMake(CGRectGetWidth(self.ADView.bounds) - 54.0f, CGRectGetHeight(self.ADView.bounds) - 18.0f, 54.0f, 18.0f);
            id<ATGDTLogoView> logoView = [[NSClassFromString(@"GDTLogoView") alloc] initWithFrame:frame];
            logoView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
            [self.ADView addSubview:(UIView*)logoView];
            
            id<ATGDTUnifiedNativeAdView> unifiedAdView = [[NSClassFromString(@"GDTUnifiedNativeAdView") alloc] initWithFrame:self.configuration.mediaViewFrame];
            unifiedAdView.delegate = (ATGDTNativeCustomEvent*)offer.assets[kGDTNativeAssetsCustomEventKey];
            unifiedAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            if (((id<ATGDTUnifiedNativeAdDataObject>)offer.customObject).isVideoAd) {
                [self.ADView addSubview:(UIView*)unifiedAdView];
            } else {
                [self.ADView insertSubview:(UIView*)unifiedAdView atIndex:0];
            }
            
            unifiedAdView.viewController = self.configuration.rootViewController;
            [unifiedAdView registerDataObject:(id<ATGDTUnifiedNativeAdDataObject>)offer.customObject clickableViews:[self.ADView clickableViews]];
            self.ADView.mediaView.frame = self.configuration.mediaViewFrame;
        } else {
            if ([offer.assets containsObjectForKey:kAdAssetsCustomObjectKey] && [offer.assets containsObjectForKey:kGDTNativeAssetsNativeAdDataKey]) {
                id<ATGDTNativeAdData> nativeAdData = offer.assets[kGDTNativeAssetsNativeAdDataKey];
                id<ATGDTNativeAd> nativeAd = offer.assets[kAdAssetsCustomObjectKey];
                [nativeAd attachAd:nativeAdData toView:self.ADView];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped)];
                [self.ADView addGestureRecognizer:tap];
            }
        }
    }
}

-(void) adViewTapped {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    if ([cache.assets containsObjectForKey:kAdAssetsCustomObjectKey]) {
        id<ATGDTNativeAd> nativeAd = cache.assets[kAdAssetsCustomObjectKey];
        id<ATGDTNativeAdData> nativeAdData = cache.assets[kGDTNativeAssetsNativeAdDataKey];
        [nativeAd clickAd:nativeAdData];
        [self.ADView.customEvent trackNativeAdClick];
    }
}

-(BOOL)isVideoContents {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    if ([cache.assets containsObjectForKey:kGDTNativeAssetsExpressAdViewKey]) {
        id<ATGDTNativeExpressAdView> expressAdView = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kGDTNativeAssetsExpressAdViewKey];
        return expressAdView.isVideoAd;
    } else {
        if (cache.unitVersion == 2) {
            return ((id<ATGDTUnifiedNativeAdDataObject>)cache.customObject).isVideoAd;
        } else {
            return NO;
        }
    }
}
@end
