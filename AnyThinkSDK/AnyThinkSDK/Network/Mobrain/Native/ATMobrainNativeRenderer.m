//
//  ATMobrainNativeRenderer.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainNativeRenderer.h"
#import "ATMobrainNativeCustomEvent.h"
#import "ATMobrainNativeApis.h"
#import "Utilities.h"

@protocol ATNativeADView<NSObject>
@property(nonatomic, readonly) ATNativeADCache *nativeAd;
@end

@implementation ATMobrainNativeRenderer

-(__kindof UIView*)createMediaView {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    id<ATABUNativeAdView> nativeAdView = cache.assets[kAdAssetsCustomObjectKey];
    if (nativeAdView.hasExpressAdGot == YES) {
        return [UIView new];
    }else {
        if (nativeAdView.data.imageMode == ABUFeedVideoAdModeImage) {
            return [UIView new];
        }
    }
    return nil;
}

-(void) bindCustomEvent {
    ATMobrainNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    
    [self bindCustomEvent];
    NSMutableArray *clickables = [NSMutableArray array];
    id<ATABUNativeAdView> nativeView = offer.assets[kAdAssetsCustomObjectKey];

    if ([self.ADView respondsToSelector:@selector(titleLabel)] && self.ADView.titleLabel && [Utilities isEmpty:nativeView.titleLabel] == NO) {
        self.ADView.titleLabel.text = offer.assets[kNativeADAssetsMainTitleKey];
        nativeView.titleLabel.text = offer.assets[kNativeADAssetsMainTitleKey];
        if ([[self.ADView clickableViews] containsObject:self.ADView.titleLabel]) {
            [clickables addObject:nativeView.titleLabel];
        }
    }
    
    if ([self.ADView respondsToSelector:@selector(textLabel)] && self.ADView.textLabel && [Utilities isEmpty:nativeView.descLabel] == NO) {
        self.ADView.textLabel.text = offer.assets[kNativeADAssetsMainTextKey];
        nativeView.descLabel.text = offer.assets[kNativeADAssetsMainTextKey];
        if ([[self.ADView clickableViews] containsObject:self.ADView.textLabel]) {
            [clickables addObject:nativeView.descLabel];
        }
        
    }
    if ([self.ADView respondsToSelector:@selector(iconImageView)] && self.ADView.iconImageView && [Utilities isEmpty:nativeView.iconImageView] == NO) {
        self.ADView.iconImageView.image = offer.assets[kNativeADAssetsIconImageKey];
        nativeView.iconImageView.image = offer.assets[kNativeADAssetsIconImageKey];
        if ([[self.ADView clickableViews] containsObject:self.ADView.iconImageView]) {
            [clickables addObject:nativeView.iconImageView];
        }
    }
    if ([self.ADView respondsToSelector:@selector(mainImageView)] && self.ADView.mainImageView && [Utilities isEmpty:nativeView.imageView] == NO) {
        self.ADView.mainImageView.image = offer.assets[kNativeADAssetsMainImageKey];
        nativeView.imageView.image = offer.assets[kNativeADAssetsMainImageKey];
        if ([[self.ADView clickableViews] containsObject:self.ADView.mainImageView]) {
            [clickables addObject:nativeView.imageView];
        }
    }
    if ([self.ADView respondsToSelector:@selector(ctaLabel)] && self.ADView.ctaLabel && [Utilities isEmpty:nativeView.callToActionBtn] == NO) {
        [nativeView.callToActionBtn setTitle:offer.assets[kNativeADAssetsCTATextKey] forState:UIControlStateNormal];
        self.ADView.ctaLabel.text = offer.assets[kNativeADAssetsCTATextKey];

        if ([[self.ADView clickableViews] containsObject:self.ADView.ctaLabel]) {
            [clickables addObject:nativeView.callToActionBtn];
        }
    }

    
    if ([self.ADView respondsToSelector:@selector(dislikeButton)] && self.ADView.dislikeButton ) {
//        nativeView.dislikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];

////        [nativeView.dislikeBtn setTitle:[self.ADView.dislikeButton titleForState:0] forState:0];
////        [nativeView.dislikeBtn setTitleColor:[self.ADView.dislikeButton titleColorForState:0] forState:0];
////        nativeView.dislikeBtn.backgroundColor = self.ADView.dislikeButton.backgroundColor;
////        nativeView.dislikeBtn.titleLabel.font = self.ADView.dislikeButton.titleLabel.font;
        
//        if ([[self.ADView clickableViews] containsObject:self.ADView.dislikeButton]) {
//            [clickables addObject:nativeView.dislikeBtn];
//        }
    }
    if ([self.ADView respondsToSelector:@selector(sponsorImageView)] && self.ADView.sponsorImageView && [Utilities isEmpty:nativeView.adLogoView] == NO) {
        if ([[self.ADView clickableViews] containsObject:self.ADView.sponsorImageView]) {
            [clickables addObject:nativeView.adLogoView];
        }
    }
    
    [self.ADView setNeedsLayout];
    [self.ADView layoutIfNeeded];
    
    if ([self.ADView respondsToSelector:@selector(titleLabel)] && self.ADView.titleLabel && [Utilities isEmpty:nativeView.titleLabel] == NO) {
        nativeView.titleLabel.frame = self.ADView.titleLabel.frame;
        nativeView.titleLabel.textColor = self.ADView.titleLabel.textColor;
        nativeView.titleLabel.font = self.ADView.titleLabel.font;
        nativeView.titleLabel.backgroundColor = self.ADView.titleLabel.backgroundColor;
        [self.ADView.titleLabel removeFromSuperview];
    }
    if ([self.ADView respondsToSelector:@selector(textLabel)] && self.ADView.textLabel && [Utilities isEmpty:nativeView.descLabel] == NO) {
        nativeView.descLabel.frame = self.ADView.textLabel.frame;
        nativeView.descLabel.textColor = self.ADView.textLabel.textColor;
        nativeView.descLabel.font = self.ADView.textLabel.font;
        nativeView.descLabel.backgroundColor = self.ADView.textLabel.backgroundColor;
        [self.ADView.textLabel removeFromSuperview];
    }
    if ([self.ADView respondsToSelector:@selector(iconImageView)] && self.ADView.iconImageView && [Utilities isEmpty:nativeView.iconImageView] == NO) {
        nativeView.iconImageView.frame = self.ADView.iconImageView.frame;
        nativeView.iconImageView.backgroundColor = self.ADView.iconImageView.backgroundColor;
        [self.ADView.iconImageView removeFromSuperview];
    }
    if ([self.ADView respondsToSelector:@selector(mainImageView)] && self.ADView.mainImageView && [Utilities isEmpty:nativeView.imageView] == NO) {
        nativeView.imageView.frame = self.ADView.mainImageView.frame;
        nativeView.imageView.backgroundColor = self.ADView.mainImageView.backgroundColor;
        [self.ADView.mainImageView removeFromSuperview];
    }
    if ([self.ADView respondsToSelector:@selector(ctaLabel)] && self.ADView.ctaLabel && [Utilities isEmpty:nativeView.callToActionBtn] == NO) {
        nativeView.callToActionBtn.frame = self.ADView.ctaLabel.frame;
        [nativeView.callToActionBtn setTitleColor:self.ADView.ctaLabel.textColor forState:UIControlStateNormal];
        nativeView.callToActionBtn.titleLabel.font = self.ADView.ctaLabel.font;
        nativeView.callToActionBtn.backgroundColor = self.ADView.ctaLabel.backgroundColor;
        [self.ADView.ctaLabel removeFromSuperview];
    }
//    if ([self.ADView respondsToSelector:@selector(dislikeButton)] && self.ADView.dislikeButton ) {
//
////        nativeView.dislikeBtn.frame = self.ADView.dislikeButton.frame;
////        [nativeView.dislikeBtn setTitle:[self.ADView.dislikeButton titleForState:0] forState:0];
////        [nativeView.dislikeBtn setTitleColor:[self.ADView.dislikeButton titleColorForState:0] forState:UIControlStateNormal];
////        nativeView.dislikeBtn.titleLabel.font = self.ADView.dislikeButton.titleLabel.font;
////        nativeView.dislikeBtn.backgroundColor = self.ADView.dislikeButton.backgroundColor;
////        [self.ADView.dislikeButton removeFromSuperview];
//
//
//    }
    
    nativeView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    nativeView.delegate = (ATMobrainNativeCustomEvent*)self.ADView.customEvent;
    if (nativeView.hasExpressAdGot == YES) {
        if (![self isVideoContents]) {
            nativeView.mediaView.frame = CGRectZero;
            [nativeView render];
        }else {
            nativeView.mediaView.frame = self.configuration.mediaViewFrame;
            [nativeView render];
            [nativeView reSizeMediaView];
        }

    }else {
        if (nativeView.data.imageMode == ABUFeedVideoAdModeImage) {
            nativeView.videoDelegate = (ATMobrainNativeCustomEvent*)self.ADView.customEvent;
            nativeView.mediaView.frame = self.configuration.mediaViewFrame;
            [nativeView reSizeMediaView];
        }
    }
    [nativeView registerClickableViews:clickables];
    [self.ADView addSubview:(UIView *)nativeView];
    ((UIView *)nativeView).frame = CGRectMake(0, 0, self.ADView.frame.size.width, self.ADView.frame.size.height);
    ((UIView *)nativeView).backgroundColor = self.ADView.backgroundColor;
//    if (nativeView.hasExpressAdGot) {
//        [self.ADView.dislikeButton removeFromSuperview];
//    }
    if ([self.ADView respondsToSelector:@selector(dislikeButton)] && self.ADView.dislikeButton) {
        [self.ADView bringSubviewToFront:self.ADView.dislikeButton];

        [self.ADView.dislikeButton addTarget:self action:@selector(closeAct) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)closeAct {
    
    if ([self.ADView.delegate respondsToSelector:@selector(didTapCloseButtonInAdView:placementID:extra:)]) {
        ATNativeADCache *cache = (ATNativeADCache *)self.ADView.nativeAd;

        [self.ADView.delegate didTapCloseButtonInAdView:self.ADView placementID:cache.placementModel.placementID extra:[cache.customEvent delegateExtraWithNativeAD:cache]];
    }
}

-(BOOL)isVideoContents {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    id<ATABUNativeAdView> nativeAdView = cache.assets[kAdAssetsCustomObjectKey];
    return nativeAdView.data.imageMode == ABUFeedVideoAdModeImage;
}

@end
