//
//  ATMobrainNativeCustomEvent.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainNativeCustomEvent.h"
#import "Utilities.h"
#import "ATAPI+Internal.h"
#import "ATImageLoader.h"
#import "ATAdManager.h"

@interface ATMobrainNativeCustomEvent ()
@property(nonatomic, weak) id<ATABUNativeAdView> nativeAd;
@property(nonatomic, strong) id<ATABUNativeAdsManager> adsManager;

@end
@implementation ATMobrainNativeCustomEvent

#pragma mark - ABUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(id<ATABUNativeAdsManager> _Nonnull)adsManager nativeAds:(NSArray<id<ATABUNativeAdView>> *_Nullable)nativeAdViewArray {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdsManagerSuccessToLoad:nativeAds" type:ATLogTypeExternal];
    self.adsManager = adsManager;
    
    dispatch_group_t image_download_group = dispatch_group_create();
    NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
    self.nativeAd = nativeAdViewArray.firstObject;
    [nativeAdViewArray enumerateObjectsUsingBlock:^(id<ATABUNativeAdView>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        asset[kAdAssetsCustomEventKey] = self;
        asset[kAdAssetsCustomObjectKey] = obj;
        if ([obj.data.AdTitle length] > 0) { asset[kNativeADAssetsMainTitleKey] = obj.data.AdTitle; }
        if ([obj.data.AdDescription length] > 0) { asset[kNativeADAssetsMainTextKey] = obj.data.AdDescription; }
        if ([obj.data.buttonText length] > 0) { asset[kNativeADAssetsCTATextKey] = obj.data.buttonText; }
        if ([obj.data.source length] > 0) {
            asset[kNativeADAssetsAdvertiserKey] = obj.data.source;
            asset[kNativeADAssetsRatingKey] = @(obj.data.score);
        }
        
        if ([obj.data.imageAry count] > 0) {
            if (![Utilities isEmpty:obj.data.imageAry[0].imageURL]) {
                asset[kNativeADAssetsImageURLKey] = obj.data.imageAry[0].imageURL;
                dispatch_group_enter(image_download_group);
                [[ATImageLoader shareLoader] loadImageWithURL:obj.data.imageAry[0].imageURL completion:^(UIImage *image, NSError *error) {
                    if ([image isKindOfClass:[UIImage class]]) {
                        asset[kNativeADAssetsMainImageKey] = image;
                        
                    }
                    dispatch_group_leave(image_download_group);
                }];
            }
        }
        if (![Utilities isEmpty:obj.data.icon.imageURL]) {
            dispatch_group_enter(image_download_group);
            [[ATImageLoader shareLoader] loadImageWithURL:obj.data.icon.imageURL completion:^(UIImage *image, NSError *error) {
                if ([image isKindOfClass:[UIImage class]]) {
//                    asset[kNativeADAssetsIconImageKey] = image;
                    [asset AT_setDictValue:image key:kNativeADAssetsIconImageKey];
                }
                dispatch_group_leave(image_download_group);
            }];
        }
        [assets addObject:asset];
    }];
    dispatch_group_notify(image_download_group, dispatch_get_main_queue(), ^{
//        [assets AT_setObject:adsManager forKey:@"adsManager"];
        self.requestCompletionBlock(assets, nil);
    });
}

- (void)nativeAdsManager:(id<ATABUNativeAdsManager> _Nonnull)adsManager didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdsManager:didFailWithError:" type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error);
}

# pragma mark - ABUNativeAdViewDelegate
- (void)nativeAdExpressViewRenderSuccess:(id<ATABUNativeAdView> _Nonnull)nativeExpressAdView {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdExpressViewRenderSuccess" type:ATLogTypeExternal];
}

- (void)nativeAdExpressViewRenderFail:(id<ATABUNativeAdView> _Nonnull)nativeExpressAdView error:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdExpressViewRenderFail:error" type:ATLogTypeExternal];
}

- (void)nativeAdDidBecomeVisible:(id<ATABUNativeAdView> _Nonnull)nativeAdView {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdDidBecomeVisible" type:ATLogTypeExternal];
    [self trackNativeAdImpression];
}

- (void)nativeAdExpressView:(id<ATABUNativeAdView> _Nonnull)nativeAdView stateDidChanged:(ATABUPlayerPlayState)playerState {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdExpressView:stateDidChanged" type:ATLogTypeExternal];
}

- (void)nativeAdDidClick:(id<ATABUNativeAdView> _Nonnull)nativeAdView withView:(UIView *_Nullable)view {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdDidClick:withView" type:ATLogTypeExternal];
    [self trackNativeAdClick];
}

- (void)nativeAdViewWillPresentFullScreenModal:(id<ATABUNativeAdView> _Nonnull)nativeAdView {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdViewWillPresentFullScreenModal" type:ATLogTypeExternal];
}

- (void)nativeAdExpressViewDidClosed:(id<ATABUNativeAdView> _Nullable)nativeAdView closeReason:(NSArray<id<ATABUDislikeWords>> *_Nullable)filterWords {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdExpressViewDidClosed:closeReason" type:ATLogTypeExternal];
    [self trackNativeAdClosed];
}

# pragma mark - ABUNativeAdVideoDelegate
- (void)nativeAdVideo:(id<ATABUNativeAdView> _Nullable)nativeAdView stateDidChanged:(ATABUPlayerPlayState)playerState {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdVideo:stateDidChanged" type:ATLogTypeExternal];
}

- (void)nativeAdVideoDidClick:(id<ATABUNativeAdView> _Nullable)nativeAdView {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdVideoDidClick" type:ATLogTypeExternal];
    [self trackNativeAdClick];
}

- (void)nativeAdVideoDidPlayFinish:(id<ATABUNativeAdView> _Nullable)nativeAdView {
    [ATLogger logMessage:@"ATMobrainNative:nativeAdVideoDidPlayFinish" type:ATLogTypeExternal];
    [self trackNativeAdVideoEnd];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra AT_setDictValue:@([self.nativeAd getAdNetworkPlaformId]) key:@"network_id"];
    [extra AT_setDictValue:[self.nativeAd getAdNetworkRitId] key:@"network_unit_id"];
    [extra AT_setDictValue:[self.nativeAd getPreEcpm] key:@"network_ecpm"];
    return extra;
}

@end
