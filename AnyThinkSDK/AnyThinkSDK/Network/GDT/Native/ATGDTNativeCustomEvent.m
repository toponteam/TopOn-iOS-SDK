//
//  ATGDTNativeCustomEvent.m
//  AnyThinkGDTNativeAdapter
//
//  Created by Martin Lau on 26/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTNativeCustomEvent.h"
#import "Utilities.h"
#import "ATNativeADView.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATImageLoader.h"
#import "ATAdCustomEvent.h"
#import "ATNativeADCache.h"
#import "ATAppSettingManager.h"

@implementation ATGDTNativeCustomEvent
#pragma mark - template delegate
-(void) didAttachMediaView {
    self.adView.mediaView.frame = self.adView.bounds;
}

- (void)gdt_nativeExpressProAdSuccessToLoad:(id<ATGDTNativeExpressProAdManager>)adManager views:(NSArray<__kindof id<ATGDTNativeExpressProAdView>> *)views {
    [ATLogger logMessage:@"GDTNative::gdt_nativeExpressProAdSuccessToLoad:views:" type:ATLogTypeExternal];
    NSMutableArray<NSDictionary*> *assets = [NSMutableArray<NSDictionary*> arrayWithCapacity:[views count]];
    [views enumerateObjectsUsingBlock:^(id<ATGDTNativeExpressProAdView>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:@{kAdAssetsCustomObjectKey:obj, kGDTNativeAssetsExpressAdKey:adManager, kGDTNativeAssetsExpressAdViewKey:obj, kNativeADAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kGDTNativeAssetsCustomEventKey:self}];
    }];
    self.requestCompletionBlock(assets, nil);
}

- (void)gdt_nativeExpressProAdFailToLoad:(id<ATGDTNativeExpressProAdManager>)adManager error:(NSError *)error {
    [ATLogger logMessage:@"GDTNative::gdt_nativeExpressProAdFailToLoad:error:" type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error);
}

- (void)gdt_NativeExpressProAdViewRenderSuccess:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewRenderSuccess:" type:ATLogTypeExternal];
}

- (void)gdt_NativeExpressProAdViewRenderFail:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewRenderFail:" type:ATLogTypeExternal];
}

- (void)gdt_NativeExpressProAdViewExposure:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewExposure:" type:ATLogTypeExternal];
}

- (void)gdt_NativeExpressProAdViewClicked:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewClicked:" type:ATLogTypeExternal];
    [self trackNativeAdClick];
}

- (void)gdt_NativeExpressProAdViewClosed:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewClosed:" type:ATLogTypeExternal];
    [self trackNativeAdClosed];
}

- (void)gdt_NativeExpressProAdViewWillPresentScreen:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewWillPresentScreen:" type:ATLogTypeExternal];
}

- (void)gdt_NativeExpressProAdViewDidPresentScreen:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewDidPresentScreen:" type:ATLogTypeExternal];
}

- (void)gdt_NativeExpressProAdViewWillDissmissScreen:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewWillDissmissScreen:" type:ATLogTypeExternal];
}

- (void)gdt_NativeExpressProAdViewDidDissmissScreen:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewDidDissmissScreen:" type:ATLogTypeExternal];
}

- (void)gdt_NativeExpressProAdViewApplicationWillEnterBackground:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewApplicationWillEnterBackground:" type:ATLogTypeExternal];
}

- (void)gdt_NativeExpressProAdView:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView playerStatusChanged:(GDTMediaPlayerStatus)status {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTNative::gdt_NativeExpressProAdView:playerStatusChanged:%ld", status] type:ATLogTypeExternal];
    if (status == GDTMediaPlayerStatusStarted) {
        [self trackNativeAdVideoStart];
    } else if (status == GDTMediaPlayerStatusStoped) {
        if (self.adView != nil) {
            [self trackNativeAdVideoEnd];
        }//Use the adView's nullability to guard against the situation where the adview's being removed instead of video ending.
    }
}

- (void)gdt_NativeExpressProAdViewVideoDidFinished:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView {
    [ATLogger logMessage:@"GDTNative::gdt_NativeExpressProAdViewVideoDidFinished:" type:ATLogTypeExternal];
}

#pragma mark - GDTNativeExpress
- (void)nativeExpressAdSuccessToLoad:(id<ATGDTNativeExpressAd>)nativeExpressAd views:(NSArray<id<ATGDTNativeExpressAdView>> *)views {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdSuccessToLoad:views:" type:ATLogTypeExternal];
    NSMutableArray<NSDictionary*> *assets = [NSMutableArray<NSDictionary*> arrayWithCapacity:[views count]];
    [views enumerateObjectsUsingBlock:^(id<ATGDTNativeExpressAdView>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:@{kAdAssetsCustomObjectKey:obj, kGDTNativeAssetsExpressAdKey:nativeExpressAd, kGDTNativeAssetsExpressAdViewKey:obj, kNativeADAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kGDTNativeAssetsCustomEventKey:self}];
    }];
    self.requestCompletionBlock(assets, nil);
}

- (void)nativeExpressAdFailToLoad:(id<ATGDTNativeExpressAd>)nativeExpressAd error:(NSError *)error {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdFailToLoad:" type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error);
}

- (void)nativeExpressAdViewRenderSuccess:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewRenderSuccess:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewRenderFail:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewRenderFail:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewExposure:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewExposure:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewClicked:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewClicked:" type:ATLogTypeExternal];
    [self trackNativeAdClick];
}

- (void)nativeExpressAdViewClosed:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewClosed:" type:ATLogTypeExternal];
    [self trackNativeAdClosed];
}

- (void)nativeExpressAdViewWillPresentScreen:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewWillPresentScreen:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewDidPresentScreen:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewDidPresentScreen:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewWillDissmissScreen:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewWillDissmissScreen:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewDidDissmissScreen:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewDidDissmissScreen:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewApplicationWillEnterBackground:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewApplicationWillEnterBackground:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdView:(id<ATGDTNativeExpressAdView>)nativeExpressAdView playerStatusChanged:(GDTMediaPlayerStatus)status {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTNative::nativeExpressAdView:playerStatusChanged:%ld", status] type:ATLogTypeExternal];
    if (status == GDTMediaPlayerStatusStarted) {
        [self trackNativeAdVideoStart];
    } else if (status == GDTMediaPlayerStatusStoped) {
        if (self.adView != nil) {
            [self trackNativeAdVideoEnd];
        }//Use the adView's nullability to guard against the situation where the adview's being removed instead of video ending.
    }
}

- (void)nativeExpressAdViewWillPresentVideoVC:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewWillPresentVideoVC:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewDidPresentVideoVC:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewDidPresentVideoVC:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewWillDismissVideoVC:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewWillDismissVideoVC:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewDidDismissVideoVC:(id<ATGDTNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"GDTNative::nativeExpressAdViewDidDismissVideoVC:" type:ATLogTypeExternal];
}

#pragma mark - self rendering
- (void)nativeAdSuccessToLoad:(NSArray<id<ATGDTNativeAdData>> *)nativeAdDataArray {
    [ATLogger logMessage:@"GDTNative::nativeAdSuccessToLoad:" type:ATLogTypeExternal];
    dispatch_group_t image_download_group = dispatch_group_create();
    NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
    [nativeAdDataArray enumerateObjectsUsingBlock:^(id<ATGDTNativeAdData>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(image_download_group);
        dispatch_group_t asset_group = dispatch_group_create();
        NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:self, kGDTNativeAssetsCustomEventKey, [self.unitID length] > 0 ? self.unitID : @"", kNativeADAssetsUnitIDKey, obj, kGDTNativeAssetsNativeAdDataKey, nil];
        if (self.gdtNativeAd != nil) {asset[kAdAssetsCustomObjectKey] = self.gdtNativeAd;}
        if ([obj.properties containsObjectForKey:kGDTNativeAssetsTitleKey]) {asset[kNativeADAssetsMainTitleKey] = obj.properties[kGDTNativeAssetsTitleKey];}
        if ([obj.properties containsObjectForKey:kGDTNativeAssetsDescKey]) {asset[kNativeADAssetsMainTextKey] = obj.properties[kGDTNativeAssetsDescKey];}
        if ([obj.properties containsObjectForKey:kGDTNativeAssetsAppRating]) {asset[kNativeADAssetsRatingKey] = obj.properties[kGDTNativeAssetsAppRating];}
        if ([obj.properties containsObjectForKey:kGDTNativeAssetsIconUrl]) {
            if ([obj.properties[kGDTNativeAssetsIconUrl] length] > 0) {
                asset[kNativeADAssetsIconURLKey] = obj.properties[kGDTNativeAssetsIconUrl];
                dispatch_group_enter(asset_group);
                [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:asset[kNativeADAssetsIconURLKey]] completion:^(UIImage *image, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([image isKindOfClass:[UIImage class]]) {asset[kNativeADAssetsIconImageKey] = image;}
                        dispatch_group_leave(asset_group);
                    });
                }];
            }
        }
        
        if ([obj.properties containsObjectForKey:kGDTNativeAssetsImageUrl]) {
            if ([obj.properties[kGDTNativeAssetsImageUrl] length] > 0) {
                asset[kNativeADAssetsImageURLKey] = obj.properties[kGDTNativeAssetsImageUrl];
                dispatch_group_enter(asset_group);
                [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:asset[kNativeADAssetsImageURLKey]] completion:^(UIImage *image, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([image isKindOfClass:[UIImage class]]) {asset[kNativeADAssetsMainImageKey] = image;}
                        dispatch_group_leave(asset_group);
                    });
                }];
            }
        }
        dispatch_group_notify(asset_group, dispatch_get_main_queue(), ^{
            [assets addObject:asset];
            dispatch_group_leave(image_download_group);
        });
    }];
    dispatch_group_notify(image_download_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(assets, nil);
    });
}

- (void)nativeAdFailToLoad:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTNative::nativeAdFailToLoad:%@", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error);
}

- (void)nativeAdWillPresentScreen {
    [ATLogger logMessage:@"GDTNative::nativeAdWillPresentScreen" type:ATLogTypeExternal];
}

- (void)nativeAdApplicationWillEnterBackground {
    [ATLogger logMessage:@"GDTNative::nativeAdApplicationWillEnterBackground" type:ATLogTypeExternal];
}

- (void)nativeAdClosed {
    [ATLogger logMessage:@"GDTNative::nativeAdApplicationWillEnterBackground" type:ATLogTypeExternal];
    [self trackNativeAdClosed];
}

#pragma mark - unified native ad delegate(s)
- (void)gdt_unifiedNativeAdLoaded:(NSArray<id<ATGDTUnifiedNativeAdDataObject>> *)unifiedNativeAdDataObjects error:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTNative::gdt_unifiedNativeAdLoaded:error:%@", error] type:ATLogTypeExternal];
    if (error != nil) {
        self.requestCompletionBlock(nil, error);
    } else {
        dispatch_group_t image_download_group = dispatch_group_create();
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        [unifiedNativeAdDataObjects enumerateObjectsUsingBlock:^(id<ATGDTUnifiedNativeAdDataObject>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.videoConfig = self.videoConfig;
            dispatch_group_enter(image_download_group);
            NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:obj, kAdAssetsCustomObjectKey, self, kGDTNativeAssetsCustomEventKey, nil];
            if (obj.title != nil) { asset[kNativeADAssetsMainTitleKey] = obj.title; }
            if (obj.desc != nil) { asset[kNativeADAssetsMainTextKey] = obj.desc; }
            asset[kNativeADAssetsRatingKey] = @(obj.appRating);
            
            dispatch_group_t asset_group = dispatch_group_create();
            if ([obj.imageUrl length] > 0) {
                asset[kNativeADAssetsImageURLKey] = obj.imageUrl;
                dispatch_group_enter(asset_group);
                [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.imageUrl] completion:^(UIImage *image, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsMainImageKey] = image; }
                        dispatch_group_leave(asset_group);
                    });
                }];
            }
            if ([obj.iconUrl length] > 0) {
                asset[kNativeADAssetsIconURLKey] = obj.iconUrl;
                dispatch_group_enter(asset_group);
                [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.iconUrl] completion:^(UIImage *image, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsIconImageKey] = image; }
                        dispatch_group_leave(asset_group);
                    });
                }];
            }
            
            dispatch_group_notify(asset_group, dispatch_get_main_queue(), ^{
                [assets addObject:asset];
                dispatch_group_leave(image_download_group);
            });
        }];
        dispatch_group_notify(image_download_group, dispatch_get_main_queue(), ^{ self.requestCompletionBlock(assets, nil); });
    }
}

- (void)gdt_unifiedNativeAdViewWillExpose:(id<ATGDTUnifiedNativeAdView>)unifiedNativeAdView {
    [ATLogger logMessage:@"GDTNative::gdt_unifiedNativeAdViewWillExpose:" type:ATLogTypeExternal];
//    [self trackNativeAdImpression];
}

- (void)gdt_unifiedNativeAdViewDidClick:(id<ATGDTUnifiedNativeAdView>)unifiedNativeAdView {
    [ATLogger logMessage:@"GDTNative::gdt_unifiedNativeAdViewDidClick:" type:ATLogTypeExternal];
    [self trackNativeAdClick];
}

- (void)gdt_unifiedNativeAdDetailViewClosed:(id<ATGDTUnifiedNativeAdView>)unifiedNativeAdView {
    [ATLogger logMessage:@"GDTNative::gdt_unifiedNativeAdDetailViewClosed:" type:ATLogTypeExternal];
}

- (void)gdt_unifiedNativeAdViewApplicationWillEnterBackground:(id<ATGDTUnifiedNativeAdView>)unifiedNativeAdView {
    [ATLogger logMessage:@"GDTNative::gdt_unifiedNativeAdViewApplicationWillEnterBackground:" type:ATLogTypeExternal];
}

- (void)gdt_unifiedNativeAdDetailViewWillPresentScreen:(id<ATGDTUnifiedNativeAdView>)unifiedNativeAdView {
    [ATLogger logMessage:@"GDTNative::gdt_unifiedNativeAdDetailViewWillPresentScreen:" type:ATLogTypeExternal];
}

- (void)gdt_unifiedNativeAdView:(id<ATGDTUnifiedNativeAdView>)unifiedNativeAdView playerStatusChanged:(NSUInteger)status userInfo:(NSDictionary *)userInfo {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTNative::gdt_unifiedNativeAdView:playerStatusChanged:%ld userInfo:%@", status, userInfo] type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    return cache.unitGroup.content[@"unit_id"];
}

/// This is an override method, for more detailsplease refer to ATNativeADCustomEvent.h
- (BOOL)sendImpressionTrackingIfNeed {
    return YES;
}
//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"unit_id"];
//    return extra;
//}
@end
