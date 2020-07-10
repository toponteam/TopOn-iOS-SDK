//
//  ATKSNativeCustomEvent.m
//  AnyThinkKSNaitveAdapter
//
//  Created by Topon on 2020/2/5.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKSNativeCustomEvent.h"
#import "Utilities.h"
#import "ATNativeADView.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATImageLoader.h"
#import "ATAdManagement.h"
#import "ATAdCustomEvent.h"
#import "ATNativeADCache.h"

NSString *const kATKSNativeExpressAdManager = @"native_KS_admanager";

@implementation ATKSNativeCustomEvent
#pragma mark - native ad delegate
- (void)nativeAdDidLoad:(id<ATKSNativeAd>)nativeAd {
    [ATLogger logMessage:@"KSNative::nativeAdDidLoad:" type:ATLogTypeExternal];
}

- (void)nativeAd:(id<ATKSNativeAd>)nativeAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"KSNative::nativeAd:didFailWithError:%@",error] type:ATLogTypeExternal];
}

- (void)nativeAdDidBecomeVisible:(id<ATKSNativeAd>)nativeAd {
    [ATLogger logMessage:@"KSNative::nativeAdDidBecomeVisible:" type:ATLogTypeExternal];
}

- (void)nativeAdDidClick:(id<ATKSNativeAd>)nativeAd withView:(UIView *_Nullable)view {
    [ATLogger logMessage:@"KSNative::nativeAdDidClick:withView:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

- (void)nativeAdDidShowOtherController:(id<ATKSNativeAd>)nativeAd interactionType:(ATKSAdInteractionType)interactionType {
    [ATLogger logMessage:@"KSNative::nativeAdDidShowOtherController:interactionType:" type:ATLogTypeExternal];
}

- (void)nativeAdDidCloseOtherController:(id<ATKSNativeAd>)nativeAd interactionType:(ATKSAdInteractionType)interactionType {
    [ATLogger logMessage:@"KSNative::nativeAdDidCloseOtherController:interactionType:" type:ATLogTypeExternal];
}

#pragma mark - native ad manager delegate
- (void)nativeAdsManagerSuccessToLoad:(id<ATKSNativeAdsManager>)adsManager nativeAds:(NSArray<id<ATKSNativeAd>> *_Nullable) nativeAdDataArray {
    [ATLogger logMessage:@"KSNative::nativeAdsManagerSuccessToLoad:nativeAds:" type:ATLogTypeExternal];
    dispatch_group_t image_download_group = dispatch_group_create();
    NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
    [nativeAdDataArray enumerateObjectsUsingBlock:^(id<ATKSNativeAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        asset[kAdAssetsCustomEventKey] = self;
        asset[kKSAdVideoSoundEnableFlag] = @(self.videoSoundEnable);
        asset[kKSNativeAdIsVideoFlag] = @(self.isVideo);
        asset[kAdAssetsCustomObjectKey] = obj;
        if ([obj.data.actionDescription length] > 0) { asset[kNativeADAssetsCTATextKey] = obj.data.actionDescription; }
        if ([obj.data.adDescription length] > 0) { asset[kNativeADAssetsMainTextKey] = obj.data.adDescription; }
        if ([obj.data.imageArray count] > 0) {
            asset[kNativeADAssetsImageURLKey] = obj.data.imageArray[0].imageURL;
            dispatch_group_enter(image_download_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.data.imageArray[0].imageURL] completion:^(UIImage *image, NSError *error) {
                asset[kNativeADAssetsMainImageKey] = image;
                dispatch_group_leave(image_download_group);
            }];
        }
        dispatch_group_enter(image_download_group);
        [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.data.appIconImage.imageURL] completion:^(UIImage *image, NSError *error) {
            if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsIconImageKey] = image; }
            dispatch_group_leave(image_download_group);
        }];
        [assets addObject:asset];
        
    }];
    dispatch_group_notify(image_download_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(assets, nil);
    });
//    self.requestCompletionBlock(assets, nil);
}

- (void)nativeAdsManager:(id<ATKSNativeAdsManager>)adsManager didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"KSNativeAd::nativeAdsManager:didFailWithError:%@", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.KSNativeLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:@"KS has failed to load native ad"}]);
}


#pragma mark - feed delegates
- (void)feedAdViewWillShow:(id<ATKSFeedAd>)feedAd {
    [ATLogger logMessage:@"KSFeed::feedAdViewWillShow:" type:ATLogTypeExternal];

}

- (void)feedAdDidClick:(id<ATKSFeedAd>)feedAd {
    [ATLogger logMessage:@"KSFeed::feedAdDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

- (void)feedAdDislike:(id<ATKSFeedAd>)feedAd {
    [ATLogger logMessage:@"KSFeed::feedAdDislike:" type:ATLogTypeExternal];
    [self.adView notifyCloseButtonTapped];

}

- (void)feedAdDidShowOtherController:(id<ATKSFeedAd>)nativeAd interactionType:(ATKSAdInteractionType)interactionType {
    [ATLogger logMessage:@"KSFeed::feedAdDidShowOtherController:interactionType:" type:ATLogTypeExternal];

}

- (void)feedAdDidCloseOtherController:(id<ATKSFeedAd>)nativeAd interactionType:(ATKSAdInteractionType)interactionType {
    [ATLogger logMessage:@"KSFeed::feedAdDidCloseOtherController:interactionType:" type:ATLogTypeExternal];

}

//ATKSFeedAdsManagerDelegate

- (void)feedAdsManagerSuccessToLoad:(id<ATKSFeedAdsManager>)adsManager nativeAds:(NSArray<id<ATKSFeedAd>> *_Nullable)feedAdDataArray {
    [ATLogger logMessage:@"KSFeed::feedAdsManagerSuccessToLoad:nativeAds:" type:ATLogTypeExternal];
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        [feedAdDataArray enumerateObjectsUsingBlock:^(id<ATKSFeedAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *asset = [NSMutableDictionary dictionary];
            asset[kAdAssetsCustomEventKey] = self;
            asset[kKSAdVideoSoundEnableFlag] = @(self.videoSoundEnable);
            asset[kAdAssetsCustomObjectKey] = obj;
            asset[kATKSNativeExpressAdManager] = adsManager;

            [assets addObject:asset];
        }];
        self.requestCompletionBlock(assets, nil);
}

- (void)feedAdsManager:(id<ATKSFeedAdsManager>)adsManager didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"KSFeed::feedAdsManager:didFailWithError:%@", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.KSFeedLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:@"KS has failed to load native ad"}]);
}
//draw
- (void)drawAdViewWillShow:(id<ATKSDrawAd>)drawAd {
    [ATLogger logMessage:@"KSDraw::drawAdViewWillShow:" type:ATLogTypeExternal];

}

- (void)drawAdDidClick:(id<ATKSDrawAd>)drawAd {
    [ATLogger logMessage:@"KSDraw::drawAdDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

- (void)drawAdDidShowOtherController:(id<ATKSDrawAd>)drawAd interactionType:(ATKSAdInteractionType)interactionType {
    [ATLogger logMessage:@"KSDraw::drawAdDidShowOtherController:interactionType:" type:ATLogTypeExternal];

}

- (void)drawAdDidCloseOtherController:(id<ATKSDrawAd>)drawAd interactionType:(ATKSAdInteractionType)interactionType {
    [ATLogger logMessage:@"KSDraw::drawAdDidCloseOtherController:interactionType:" type:ATLogTypeExternal];

}

- (void)drawAdsManagerSuccessToLoad:(id<ATKSDrawAdsManager>)adsManager drawAds:(NSArray<id<ATKSDrawAd>> *_Nullable)drawAdDataArray {
    [ATLogger logMessage:@"KSDraw::drawAdsManagerSuccessToLoad:drawAds:" type:ATLogTypeExternal];
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        [drawAdDataArray enumerateObjectsUsingBlock:^(id<ATKSDrawAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *asset = [NSMutableDictionary dictionary];
            asset[kAdAssetsCustomEventKey] = self;
            asset[kAdAssetsCustomObjectKey] = obj;
            asset[kATKSNativeExpressAdManager] = adsManager;

            [assets addObject:asset];
        }];
        self.requestCompletionBlock(assets, nil);
}

- (void)drawAdsManager:(id<ATKSDrawAdsManager>)adsManager didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"KSDraw::drawAdsManager:didFailWithError:%@", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.KSDrawLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:@"KS has failed to load native ad"}]);
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"position_id"];

    return extra;
}
@end
