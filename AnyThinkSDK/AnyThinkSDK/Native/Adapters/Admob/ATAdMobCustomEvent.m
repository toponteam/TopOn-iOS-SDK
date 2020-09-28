//
//  ATAdMobCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 26/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdMobCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATNativeADView+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATLogger.h"
#import "ATThreadSafeAccessor.h"
#import "ATAdCustomEvent.h"


@interface ATAdMobCustomEvent()
@property(nonatomic, readonly) BOOL clicked;
@property(nonatomic, readonly) NSMutableArray *offers;
@property(nonatomic, readonly) NSInteger numberOfFailedRequest;
@property(nonatomic, readonly) BOOL finished;
@end
@implementation ATAdMobCustomEvent
-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _offers = [NSMutableArray array];
    }
    return self;
}
- (void)adLoader:(id<ATGADAdLoader>)adLoader didFailToReceiveAdWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATAdMobCustomEvent::adLoader:didFailToReceiveAdWithError:%@", error] type:ATLogTypeExternal];
    dispatch_async(dispatch_get_main_queue(), ^{
        _numberOfFailedRequest++;
        if (_numberOfFailedRequest == self.requestNumber && !_finished) {
            self.requestCompletionBlock(nil, error);
            _finished = YES;
        }
    });
}

- (void)adLoaderDidFinishLoading:(id<ATGADAdLoader>)adLoader {
    [ATLogger logMessage:@"ATAdMobCustomEvent::adLoaderDidFinishLoading:" type:ATLogTypeExternal];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_finished) {
            self.requestCompletionBlock([_offers count] > 0 ? _offers : nil, [_offers count] > 0 ? nil : [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:@"Admob sdk did not return any valid response."}]);
            _finished = YES;
        }
    });
}

- (void)adLoader:(id<ATGADAdLoader>)adLoader didReceiveUnifiedNativeAd:(id<ATGADUnifiedNativeAd>)nativeAd {
    [ATLogger logMessage:@"ATAdMobCustomEvent::adLoader:didReceiveUnifiedNativeAd:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:nativeAd, kAdAssetsCustomObjectKey, self.unitID, kNativeADAssetsUnitIDKey, nil];
    if ([nativeAd.headline length] > 0) {
        assets[kNativeADAssetsMainTitleKey] = nativeAd.headline;
    }
    if ([nativeAd.body length] > 0) {
        assets[kNativeADAssetsMainTextKey] = nativeAd.body;
    }
    if ([nativeAd.callToAction length] > 0) {
        assets[kNativeADAssetsCTATextKey] = nativeAd.callToAction;
    }
    if (nativeAd.starRating != nil) {
        assets[kNativeADAssetsRatingKey] = nativeAd.starRating;
    }
    if (nativeAd.images.firstObject.image != nil) {
        assets[kNativeADAssetsMainImageKey] = nativeAd.images.firstObject.image;
    }
    if (nativeAd.icon.image != nil) {
        assets[kNativeADAssetsIconImageKey] = nativeAd.icon.image;
    }
    if ([nativeAd.advertiser length] > 0) {
        assets[kNativeADAssetsAdvertiserKey] = nativeAd.advertiser;
    }
    dispatch_async(dispatch_get_main_queue(), ^{ [_offers addObject:assets]; });
}

- (void)nativeAdWillLeaveApplication:(id<ATGADUnifiedNativeAd>)nativeAd {
    [ATLogger logMessage:@"ATAdMobCustomEvent:nativeAdWillLeaveApplication:" type:ATLogTypeExternal];
    if (!_clicked) [ATLogger logMessage:@"Admob ad will take you out of the app, but click delegate not supported" type:ATLogTypeInternal];
}

- (void)nativeAdDidRecordImpression:(id<ATGADUnifiedNativeAd>)nativeAd {
    [ATLogger logMessage:@"ATAdMobCustomEvent:nativeAdDidRecordImpression:" type:ATLogTypeExternal];
}

- (void)nativeAdDidRecordClick:(id<ATGADUnifiedNativeAd>)nativeAd {
    [ATLogger logMessage:@"ATAdMobCustomEvent::nativeAdDidRecordClick:" type:ATLogTypeExternal];
    [self trackNativeAdClick];
    _clicked = YES;
}

- (void)videoControllerDidPlayVideo:(id<ATGADVideoController>)videoController {
    [ATLogger logMessage:@"ATAdMobCustomEvent::videoControllerDidPlayVideo:" type:ATLogTypeExternal];
    [self trackNativeAdVideoStart];
}

- (void)videoControllerDidEndVideoPlayback:(id<ATGADVideoController>)videoController {
    [ATLogger logMessage:@"ATAdMobCustomEvent::videoControllerDidEndVideoPlayback:" type:ATLogTypeExternal];
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    [self trackNativeAdVideoEnd];
}

-(void) willDetachOffer:(ATNativeADCache *)offer fromAdView:(ATNativeADView *)adView {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    if (cache.customObject != nil && [cache.customObject respondsToSelector:@selector(unregisterAdView)]) [(id<ATGADUnifiedNativeAd>)cache.customObject unregisterAdView];
}

-(void) dealloc {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    if (cache.customObject != nil && [cache.customObject respondsToSelector:@selector(unregisterAdView)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<ATGADUnifiedNativeAd>)cache.customObject unregisterAdView];
        });
    }
}

-(void) didAttachMediaView {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    if ([cache.customObject respondsToSelector:@selector(registerAdView:clickableAssetViews:nonclickableAssetViews:)]) {
        id<ATGADUnifiedNativeAdView> gadView = [[NSClassFromString(@"GADUnifiedNativeAdView") alloc] initWithFrame:self.adView.bounds];
        gadView.nativeAd = cache.customObject;
        gadView.bodyView = [self.adView respondsToSelector:@selector(textLabel)] && [[self.adView clickableViews] containsObject:[self.adView textLabel]] ? [self.adView textLabel] : nil;
        gadView.headlineView = [self.adView respondsToSelector:@selector(titleLabel)] && [[self.adView clickableViews] containsObject:[self.adView titleLabel]] ? [self.adView titleLabel] : nil;
        gadView.iconView = [self.adView respondsToSelector:@selector(iconImageView)] && [[self.adView clickableViews] containsObject:[self.adView iconImageView]] ? [self.adView iconImageView] : nil;
        gadView.imageView = [self.adView respondsToSelector:@selector(mainImageView)] && [[self.adView clickableViews] containsObject:[self.adView mainImageView]] ? [self.adView mainImageView] : nil;
        gadView.callToActionView = [self.adView respondsToSelector:@selector(ctaLabel)] && [[self.adView clickableViews] containsObject:[self.adView ctaLabel]] ? [self.adView ctaLabel] : nil;
        gadView.advertiserView = [self.adView respondsToSelector:@selector(advertiserLabel)] && [[self.adView clickableViews] containsObject:[self.adView advertiserLabel]] ? [self.adView advertiserLabel] : nil;
        gadView.mediaView = [[self.adView clickableViews] containsObject:[self.adView mediaView]] ? (id<ATGADMediaView>)self.adView.mediaView : nil;
        gadView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.adView insertSubview:(UIView*)gadView atIndex:0];
        [self.adView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[gadView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(gadView)]];
        [self.adView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[gadView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(gadView)]];
        
        if ([[self.adView clickableViews] count] > 0) {
            NSMutableDictionary<NSString*, UIView*>* clickableViews = [NSMutableDictionary<NSString*, UIView*> dictionary];
            [[self.adView clickableViews] enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([self.adView respondsToSelector:@selector(titleLabel)] && obj == self.adView.titleLabel) clickableViews[ATGADUnifiedNativeHeadlineAsset] = obj;
                else if ([self.adView respondsToSelector:@selector(textLabel)] && obj == self.adView.textLabel) clickableViews[ATGADUnifiedNativeBodyAsset] = obj;
                else if ([self.adView respondsToSelector:@selector(advertiserLabel)] && obj == self.adView.ctaLabel) clickableViews[ATGADUnifiedNativeCallToActionAsset] = obj;
                else if ([self.adView respondsToSelector:@selector(advertiserLabel)] && obj == self.adView.advertiserLabel) clickableViews[ATGADUnifiedNativeAdvertiserAsset] = obj;
                else if ([self.adView respondsToSelector:@selector(ratingLabel)] && obj == self.adView.ratingLabel) clickableViews[ATGADUnifiedNativeStarRatingAsset] = obj;
                else if ([self.adView respondsToSelector:@selector(iconImageView)] && obj == self.adView.iconImageView) clickableViews[ATGADUnifiedNativeIconAsset] = obj;
                else if ([self.adView respondsToSelector:@selector(mainImageView)] && obj == self.adView.mainImageView) clickableViews[ATGADUnifiedNativeImageAsset] = obj;
                else if (obj == self.adView.mediaView) clickableViews[ATGADUnifiedNativeMediaViewAsset] = obj;
            }];
            NSMutableDictionary<NSString*, UIView*>* nonclickableViews = [NSMutableDictionary<NSString*, UIView*> dictionary];
            if ([self.adView respondsToSelector:@selector(titleLabel)] && ![clickableViews.allValues containsObject:self.adView.titleLabel]) nonclickableViews[ATGADUnifiedNativeHeadlineAsset] = self.adView.titleLabel;
            if ([self.adView respondsToSelector:@selector(textLabel)] && ![clickableViews.allValues containsObject:self.adView.textLabel])
                nonclickableViews[ATGADUnifiedNativeBodyAsset] = self.adView.textLabel;
            if ([self.adView respondsToSelector:@selector(ctaLabel)] && ![clickableViews.allValues containsObject:self.adView.ctaLabel]) nonclickableViews[ATGADUnifiedNativeCallToActionAsset] = self.adView.ctaLabel;
            if ([self.adView respondsToSelector:@selector(advertiserLabel)] && ![clickableViews.allValues containsObject:self.adView.advertiserLabel])  nonclickableViews[ATGADUnifiedNativeAdvertiserAsset] = self.adView.advertiserLabel;
            if ([self.adView respondsToSelector:@selector(ratingLabel)] && ![clickableViews.allValues containsObject:self.adView.ratingLabel])  nonclickableViews[ATGADUnifiedNativeStarRatingAsset] = self.adView.ratingLabel;
            if ([self.adView respondsToSelector:@selector(iconImageView)] && ![clickableViews.allValues containsObject:self.adView.iconImageView])
                nonclickableViews[ATGADUnifiedNativeIconAsset] = self.adView.iconImageView;
            if ([self.adView respondsToSelector:@selector(mainImageView)] && ![clickableViews.allValues containsObject:self.adView.mainImageView])
                nonclickableViews[ATGADUnifiedNativeImageAsset] = self.adView.mainImageView;
            if (![clickableViews.allValues containsObject:self.adView.mediaView])
                nonclickableViews[ATGADUnifiedNativeMediaViewAsset] = self.adView.mediaView;

            if ([clickableViews count] > 0 || [nonclickableViews count] > 0) {
                id<ATGADUnifiedNativeAd> nativeAd = (id<ATGADUnifiedNativeAd>)(((ATNativeADCache*)self.adView.nativeAd).customObject);
                [nativeAd registerAdView:self.adView clickableAssetViews:clickableViews nonclickableAssetViews:nonclickableViews];
            }
        }
    }
}

- (NSString *)networkUnitId {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    return cache.unitGroup.content[@"unit_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"unit_id"];
//    return extra;
//}
@end
