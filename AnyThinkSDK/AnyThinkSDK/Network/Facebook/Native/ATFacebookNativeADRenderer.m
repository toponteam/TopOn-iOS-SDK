//
//  ATFacebookNativeADRenderer.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookNativeADRenderer.h"
#import "ATFacebookCustomEvent.h"
#import "ATNativeADView+internal.h"
#import "NSObject+ATCustomEvent.h"
#import "ATNativeADCache.h"
#import "ATNativeADView+Internal.h"
#import "ATAPI+Internal.h"
#import "ATFacebookNativeAdapter.h"
#import "ATNativeAdConfiguration.h"

@implementation ATFacebookNativeADRenderer
-(id)createMediaView {
    ATNativeADCache *nativeAdCache = (ATNativeADCache*)self.ADView.nativeAd;
    if ([nativeAdCache.unitGroup.content[@"unit_type"] integerValue] == 0) {
        id<ATFBNativeAd> nativeAD = (id<ATFBNativeAd>)(nativeAdCache.customObject);
        id<ATFBMediaView> mediaView = [NSClassFromString(@"FBMediaView") new];
        [self bindCustomEventWithNativeAd:nativeAD mediaView:mediaView];
        return mediaView;
    } else {
        [self bindCustomEventWithNativeAd:nil mediaView:nil];
        return [UIView new];
    }
}

-(void) bindCustomEventWithNativeAd:(id<ATFBNativeAd>)nativeAd mediaView:(id<ATFBMediaView>)mediaView {
    ATFacebookCustomEvent *customEvent = (ATFacebookCustomEvent*)((ATNativeADCache*)self.ADView.nativeAd).customEvent;
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
    nativeAd.delegate = customEvent;
    mediaView.delegate = customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    if ([offer.unitGroup.content[@"unit_type"] integerValue] == 0) {
        id<ATFBNativeAd> nativeAD = offer.assets[kAdAssetsCustomObjectKey];
        if ([self.ADView respondsToSelector:@selector(advertiserLabel)]) [self.ADView advertiserLabel].text = nativeAD.advertiserName;
        if ([self.ADView respondsToSelector:@selector(titleLabel)]) [self.ADView titleLabel].text = nativeAD.headline;
        if ([self.ADView respondsToSelector:@selector(textLabel)]) [self.ADView textLabel].text = nativeAD.bodyText;
        if ([self.ADView respondsToSelector:@selector(ctaLabel)]) [self.ADView ctaLabel].text = nativeAD.callToAction;

        if ([self.ADView respondsToSelector:@selector(mainImageView)]) { [self.ADView mainImageView].image = nil;/*Image will be drawn on the media view.*/ }

        ((id<ATFBMediaView>)(self.ADView.mediaView)).nativeAd = nativeAD;

        if ([self.ADView respondsToSelector:@selector(iconImageView)]) {
            id<ATFBMediaView> iconView = [NSClassFromString(@"FBAdIconView") new];
            iconView.tag = kATFBNativeAdViewIconMediaViewFlag;
            iconView.nativeAd = nativeAD;
            iconView.frame = self.ADView.iconImageView.bounds;
            iconView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.ADView.iconImageView addSubview:(UIView*)iconView];
        }

        CGRect frame = [self.configuration.context[kATNativeAdConfigurationContextAdOptionsViewFrameKey] respondsToSelector:@selector(CGRectValue)] ? [self.configuration.context[kATNativeAdConfigurationContextAdOptionsViewFrameKey] CGRectValue] : CGRectMake(CGRectGetWidth(self.ADView.bounds) - kATFBAdOptionsViewWidth, CGRectGetHeight(self.ADView.bounds) - kATFBAdOptionsViewHeight, kATFBAdOptionsViewWidth, kATFBAdOptionsViewHeight);
        id<ATFBAdOptionsView> optionsView = [[NSClassFromString(@"FBAdOptionsView") alloc] initWithFrame:frame];
        optionsView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        optionsView.nativeAd = nativeAD;
        [self.ADView addSubview:(UIView*)optionsView];
    } else {//@{@1:@100, @2:@120, @5:@50}
        CGFloat height = [offer.unitGroup.content[@"height"] doubleValue];
        id<ATFBNativeBannerAdView> nativeBannerView = [NSClassFromString(@"FBNativeBannerAdView") nativeBannerAdViewWithNativeBannerAd:offer.customObject withType:[@{@50:@5, @100:@1, @120:@2}[@([offer.unitGroup.content[@"height"] integerValue])] integerValue]];
        nativeBannerView.frame = CGRectMake(.0f, CGRectGetMidY(self.ADView.bounds) - height / 2.0f, CGRectGetWidth(self.ADView.bounds), height);
        [self.ADView addSubview:(UIView*)nativeBannerView];
    }
}
@end
