//
//  ATTTNativeCustomEvent.m
//  AnyThinkTTNativeAdapter
//
//  Created by Martin Lau on 2018/12/29.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTNativeCustomEvent.h"
#import "Utilities.h"
#import "ATNativeADView.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATImageLoader.h"
#import "ATAdManagement.h"
#import "ATAdCustomEvent.h"

NSString *const kATTTNativeExpressAdManager = @"native_express_tt_admanager";

@implementation ATTTNativeCustomEvent
- (void)nativeAdsManagerSuccessToLoad:(id<ATBUNativeAdsManager>)adsManager nativeAds:(NSArray<id<ATBUNativeAd>> *_Nullable)nativeAdDataArray {
    [ATLogger logMessage:@"TTNative::nativeAdsManagerSuccessToLoad:nativeAds:" type:ATLogTypeExternal];
    dispatch_group_t image_download_group = dispatch_group_create();
    NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
    [nativeAdDataArray enumerateObjectsUsingBlock:^(id<ATBUNativeAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        asset[kNativeADAssetsRatingKey] = @(obj.data.score);
        asset[kAdAssetsCustomEventKey] = self;
        asset[kAdAssetsCustomObjectKey] = obj;
        if ([obj.data.AdTitle length] > 0) { asset[kNativeADAssetsMainTitleKey] = obj.data.AdTitle; }
        if ([obj.data.AdDescription length] > 0) { asset[kNativeADAssetsMainTextKey] = obj.data.AdDescription; }
        if ([obj.data.buttonText length] > 0) { asset[kNativeADAssetsCTATextKey] = obj.data.buttonText; }
        if ([obj.data.source length] > 0) { asset[kNativeADAssetsAdvertiserKey] = obj.data.source; }
        
        if ([obj.data.imageAry count] > 0) {
            asset[kNativeADAssetsImageURLKey] = obj.data.imageAry[0].imageURL;
            dispatch_group_enter(image_download_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.data.imageAry[0].imageURL] completion:^(UIImage *image, NSError *error) {
                if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsMainImageKey] = image; }
                dispatch_group_leave(image_download_group);
            }];
        }
        
        dispatch_group_enter(image_download_group);
        [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.data.icon.imageURL] completion:^(UIImage *image, NSError *error) {
            if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsIconImageKey] = image; }
            dispatch_group_leave(image_download_group);
        }];
        [assets addObject:asset];
    }];
    dispatch_group_notify(image_download_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(assets, nil);
    });
}

- (void)nativeAdsManager:(id<ATBUNativeAdsManager>)adsManager didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNative::nativeAdsManager:didFailWithError:%@", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error);
}

- (void)nativeAdDidLoad:(id<ATBUNativeAd>)nativeAd {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNative::nativeAdDidLoad:"] type:ATLogTypeExternal];
    if (nativeAd != nil) {
        dispatch_group_t image_download_group = dispatch_group_create();
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        asset[kNativeADAssetsRatingKey] = @(nativeAd.data.score);
        asset[kAdAssetsCustomEventKey] = self;
        asset[kAdAssetsCustomObjectKey] = nativeAd;
        if ([nativeAd.data.AdTitle length] > 0) { asset[kNativeADAssetsMainTitleKey] = nativeAd.data.AdTitle; }
        if ([nativeAd.data.AdDescription length] > 0) { asset[kNativeADAssetsMainTextKey] = nativeAd.data.AdDescription; }
        if ([nativeAd.data.buttonText length] > 0) { asset[kNativeADAssetsCTATextKey] = nativeAd.data.buttonText; }
        if ([nativeAd.data.source length] > 0) { asset[kNativeADAssetsAdvertiserKey] = nativeAd.data.source; }
        
        if ([nativeAd.data.imageAry count] > 0) {
            asset[kNativeADAssetsImageURLKey] = nativeAd.data.imageAry[0].imageURL;
            dispatch_group_enter(image_download_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:nativeAd.data.imageAry[0].imageURL] completion:^(UIImage *image, NSError *error) {
                if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsMainImageKey] = image; }
                dispatch_group_leave(image_download_group);
            }];
        }
        dispatch_group_enter(image_download_group);
        [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:nativeAd.data.icon.imageURL] completion:^(UIImage *image, NSError *error) {
            if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsIconImageKey] = image; }
            dispatch_group_leave(image_download_group);
        }];
        dispatch_group_notify(image_download_group, dispatch_get_main_queue(), ^{
            self.requestCompletionBlock(@[asset], nil);
        });
    }
}

- (void)nativeAd:(id<ATBUNativeAd>)nativeAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNative::nativeAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.TTNativeLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:@"TT has failed to load native ad"}]);
}

- (void)nativeAdDidBecomeVisible:(id<ATBUNativeAd>)nativeAd {
    [ATLogger logMessage:@"TTNative::nativeAdDidBecomeVisible:" type:ATLogTypeExternal];
}

- (void)nativeAdDidClick:(id<ATBUNativeAd>)nativeAd withView:(UIView *_Nullable)view {
    [ATLogger logMessage:@"TTNative::nativeAdDidClick:withView:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

- (void)nativeAd:(id<ATBUNativeAd>)nativeAd dislikeWithReason:(NSArray*)filterWords {
    [ATLogger logMessage:@"TTNative::nativeAd:dislikeWithReason:" type:ATLogTypeExternal];
    [self.adView notifyCloseButtonTapped];
}

-(ATNativeADSourceType) sourceType {
    return self.isVideo ? ATNativeADSourceTypeVideo : ATNativeADSourceTypeImage;
}

#pragma mark - video delegate
- (void)videoAdView:(id<ATBUVideoAdView>)videoAdView didLoadFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNative::videoAdView:didLoadFailWithError:%@", error] type:ATLogTypeExternal];
}

- (void)videoAdView:(id<ATBUVideoAdView>)videoAdView stateDidChanged:(NSInteger)playerState {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNative::videoAdView:stateDidChanged:%ld", playerState] type:ATLogTypeExternal];
}

- (void)playerDidPlayFinish:(id<ATBUVideoAdView>)videoAdView {
    [ATLogger logMessage:@"TTNative::playerDidPlayFinish:" type:ATLogTypeExternal];
    [self trackVideoEnd];
    [self.adView notifyVideoEnd];
}

#pragma mark - nativeExpress
- (void)nativeExpressAdSuccessToLoad:(id<ATBUNativeExpressAdManager>)nativeExpressAd views:(NSArray<__kindof id<ATBUNativeExpressAdView>> *)views { 
    [ATLogger logMessage:@"TTNativeExpress::nativeExpressAdSuccessToLoad:views:" type:ATLogTypeExternal];
    if (views.count) {
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        [views enumerateObjectsUsingBlock:^(id<ATBUNativeExpressAdView>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *asset = [NSMutableDictionary dictionary];
            id<ATBUNativeExpressAdView> expressView = obj;
            asset[kAdAssetsCustomEventKey] = self;
            asset[kAdAssetsCustomObjectKey] = obj;
            asset[kATTTNativeExpressAdManager] = nativeExpressAd;
            expressView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            [assets addObject:asset];
        }];
        self.requestCompletionBlock(assets, nil);
    }
}

- (void)nativeExpressAdFailToLoad:(id<ATBUNativeExpressAdManager>)nativeExpressAd error:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNativeExpress::nativeExpressAdFailToLoad:error:%@", error] type:ATLogTypeExternal];
    if (!_isFailed) {
        self.requestCompletionBlock(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.TTNativeLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:@"TT has failed to load native ad"}]);
        _isFailed = true;
    }
}

- (void)nativeExpressAdViewRenderSuccess:(id<ATBUNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"TTNativeExpress::nativeExpressAdViewRenderSuccess:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewRenderFail:(id<ATBUNativeExpressAdView>)nativeExpressAdView error:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNativeExpress::nativeExpressAdViewRenderFail:error:%@", error] type:ATLogTypeExternal];
    if (!_isFailed) {
        self.requestCompletionBlock(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.TTNativeLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:@"TT has failed to load native ad"}]);
        _isFailed = true;
    }
}

- (void)nativeExpressAdViewWillShow:(id<ATBUNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"TTNativeExpress::nativeExpressAdViewWillShow:" type:ATLogTypeExternal];
}

- (void)nativeExpressAdViewDidClick:(id<ATBUNativeExpressAdView>)nativeExpressAdView {
    [ATLogger logMessage:@"TTNativeExpress::nativeExpressAdViewDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

- (void)nativeExpressAdViewPlayerDidPlayFinish:(id<ATBUNativeExpressAdView>)nativeExpressAdView error:(NSError *)error {
    [ATLogger logMessage:@"TTNative::playerDidPlayFinish:" type:ATLogTypeExternal];
    [self trackVideoEnd];
    [self.adView notifyVideoEnd];
}

- (void)nativeExpressAdView:(id<ATBUNativeExpressAdView>)nativeExpressAdView dislikeWithReason:(NSArray<id<ATBUDislikeWords>> *)filterWords {
    [ATLogger logMessage:@"TTNativeExpress::nativeExpressAdView:dislikeWithReason:" type:ATLogTypeExternal];
    [self.adView notifyCloseButtonTapped];

}

- (void)nativeExpressAdViewWillPresentScreen:(id<ATBUNativeExpressAdView>)nativeExpressAdView {
    
}

-(void) dealloc {
    NSLog(@"TT Native customEvent dealloc");
}
@end
