//
//  ATBaiduNativeCustomEvent.m
//  AnyThinkBaiduNativeAdapter
//
//  Created by Martin Lau on 2019/7/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATBaiduNativeCustomEvent.h"
#import "Utilities.h"
#import "ATAdManagement.h"
#import "ATAPI+Internal.h"
#import "ATImageLoader.h"
#import "ATNativeADCache.h"

@implementation ATBaiduNativeCustomEvent
- (void)nativeAdObjectsSuccessLoad:(NSArray<id<ATBaiduMobAdNativeAdObject>> *)nativeAds {
    [ATLogger logMessage:@"BaiduNative::nativeAdObjectsSuccessLoad::" type:ATLogTypeExternal];
    NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
    dispatch_group_t image_download_group = dispatch_group_create();
    [nativeAds enumerateObjectsUsingBlock:^(id<ATBaiduMobAdNativeAdObject>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(image_download_group);
        dispatch_group_t asset_group = dispatch_group_create();
        NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:self, kAdAssetsCustomEventKey, obj, kAdAssetsCustomObjectKey, nil];
        if ([obj.title length] > 0) { asset[kNativeADAssetsMainTitleKey] = obj.title; }
        if ([obj.text length] > 0) { asset[kNativeADAssetsMainTextKey] = obj.text; }
        
        if ([obj.iconImageURLString length] > 0) {
            asset[kNativeADAssetsIconURLKey] = obj.iconImageURLString;
            dispatch_group_enter(asset_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.iconImageURLString] completion:^(UIImage *image, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([image isKindOfClass:[UIImage class]]) {
                        asset[kNativeADAssetsIconImageKey] = image;
                    }
                    dispatch_group_leave(asset_group);
                });
            }];
        }
        if ([obj.mainImageURLString length] > 0) {
            asset[kNativeADAssetsImageURLKey] = obj.mainImageURLString;
            dispatch_group_enter(asset_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.mainImageURLString] completion:^(UIImage *image, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([image isKindOfClass:[UIImage class]]) {
                        asset[kNativeADAssetsMainImageKey] = image;
                    }
                    dispatch_group_leave(asset_group);
                });
            }];
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

- (void)nativeAdsFailLoad:(NSInteger) reason {
    NSString *errorDesc = [NSString stringWithFormat:@"BaiduNative::nativeAdsFailLoad:%@(%ld)", @{@0:@"BaiduMobFailReason_NOAD", @1:@"BaiduMobFailReason_EXCEPTION", @2:@"BaiduMobFailReason_FRAME"}[@(reason)], reason];
    [ATLogger logMessage:errorDesc type:ATLogTypeExternal];
    [self trackNativeAdLoadFailed:[NSError errorWithDomain:@"com.anythink.BaiduNativeLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:errorDesc}]];
}

- (void)nativeAdClicked:(UIView *)nativeAdView {
    [ATLogger logMessage:@"BaiduNative::nativeAdClicked:" type:ATLogTypeExternal];
    [self trackNativeAdClick];
}

- (void)didDismissLandingPage:(UIView *)nativeAdView {
    [ATLogger logMessage:@"BaiduNative::didDismissLandingPage:" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    return cache.unitGroup.content[@"placement_id"];
}

/// This is an override method, for more detailsplease refer to ATNativeADCustomEvent.h
- (BOOL)sendImpressionTrackingIfNeed {
    
    ATNativeADCache *offer = (ATNativeADCache*)self.adView.nativeAd;
    id<ATBaiduMobAdNativeAdObject> nativeAdObject = offer.assets[kAdAssetsCustomObjectKey];
    [nativeAdObject trackImpression:self.adView];
    return YES;
}
//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"placement_id"];
//    return extra;
//}
@end
