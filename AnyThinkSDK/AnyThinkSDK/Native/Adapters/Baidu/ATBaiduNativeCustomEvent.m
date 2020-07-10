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
    dispatch_group_t assets_group = dispatch_group_create();
    [nativeAds enumerateObjectsUsingBlock:^(id<ATBaiduMobAdNativeAdObject>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(assets_group);
        NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:self, kAdAssetsCustomEventKey, obj, kAdAssetsCustomObjectKey, nil];
        if ([obj.title length] > 0) { asset[kNativeADAssetsMainTitleKey] = obj.title; }
        if ([obj.text length] > 0) { asset[kNativeADAssetsMainTextKey] = obj.text; }
        
        dispatch_group_t img_group = dispatch_group_create();
        if ([obj.iconImageURLString length] > 0) {
            asset[kNativeADAssetsIconURLKey] = obj.iconImageURLString;
            dispatch_group_enter(img_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.iconImageURLString] completion:^(UIImage *image, NSError *error) {
                if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsIconImageKey] = image; }
                dispatch_group_leave(img_group);
            }];
        }
        if ([obj.mainImageURLString length] > 0) {
            asset[kNativeADAssetsImageURLKey] = obj.mainImageURLString;
            dispatch_group_enter(img_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.mainImageURLString] completion:^(UIImage *image, NSError *error) {
                if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsMainImageKey] = image; }
                dispatch_group_leave(img_group);
            }];
        }
        dispatch_group_notify(img_group, dispatch_get_main_queue(), ^{
            [assets addObject:asset];
            dispatch_group_leave(assets_group);
        });
    }];
    dispatch_group_notify(assets_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(assets, nil);
    });
}

- (void)nativeAdsFailLoad:(NSInteger) reason {
    NSString *errorDesc = [NSString stringWithFormat:@"BaiduNative::nativeAdsFailLoad:%@(%ld)", @{@0:@"BaiduMobFailReason_NOAD", @1:@"BaiduMobFailReason_EXCEPTION", @2:@"BaiduMobFailReason_FRAME"}[@(reason)], reason];
    [ATLogger logMessage:errorDesc type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.BaiduNativeLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:errorDesc}]];
}

- (void)nativeAdClicked:(UIView *)nativeAdView {
    [ATLogger logMessage:@"BaiduNative::nativeAdClicked:" type:ATLogTypeExternal];
    [self.adView notifyNativeAdClick];
    [self trackClick];
}

- (void)didDismissLandingPage:(UIView *)nativeAdView {
    [ATLogger logMessage:@"BaiduNative::didDismissLandingPage:" type:ATLogTypeExternal];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"placement_id"];
    return extra;
}
@end
