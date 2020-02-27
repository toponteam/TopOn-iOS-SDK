//
//  ATMintegralNativeCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralNativeCustomEvent.h"
#import "ATNativeADView.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "ATLogger.h"

NSString *const kMTGAssetsNativeAdManagerKey = @"ad_manager";
@implementation ATMintegralNativeCustomEvent
- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds {
    [ATLogger logMessage:@"MTGNative::nativeAdsLoaded:" type:ATLogTypeExternal];
    NSMutableArray<NSDictionary*>* offers = [NSMutableArray<NSDictionary*> array];
    dispatch_group_t ads_loading_group = dispatch_group_create();
    [nativeAds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(ads_loading_group);
        __weak id<ATMTGCampaign> campaign = obj;
        NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:campaign, kAdAssetsCustomObjectKey, self.unitID, kNativeADAssetsUnitIDKey, self, kATMintegralNativeAssetCustomEvent, nil];
        assets[kMTGAssetsNativeAdManagerKey] = _nativeAdManager;
        if ([campaign.appName length] > 0) {
            assets[kNativeADAssetsMainTitleKey] = campaign.appName;
        }
        if ([campaign.appDesc length] > 0) {
            assets[kNativeADAssetsMainTextKey] = campaign.appDesc;
        }
        if ([campaign.adCall length] > 0) {
            assets[kNativeADAssetsCTATextKey] = campaign.adCall;
        }
        
        dispatch_group_t image_load_group = dispatch_group_create();
        
        if ([campaign.imageUrl length] > 0) {
            assets[kNativeADAssetsImageURLKey] = campaign.imageUrl;
            dispatch_group_enter(image_load_group);
            [campaign loadImageUrlAsyncWithBlock:^(UIImage *image) {
                if (image != nil) {
                    assets[kNativeADAssetsMainImageKey] = image;
                }
                dispatch_group_leave(image_load_group);
            }];
        }
        
        if ([campaign.iconUrl length] > 0) {
            assets[kNativeADAssetsIconURLKey] = campaign.iconUrl;
            dispatch_group_enter(image_load_group);
            [campaign loadIconUrlAsyncWithBlock:^(UIImage *image) {
                if (image != nil) {
                    assets[kNativeADAssetsIconImageKey] = image;
                }
                dispatch_group_leave(image_load_group);
            }];
        }
        dispatch_group_notify(image_load_group, dispatch_get_main_queue(), ^{
            [offers addObject:assets];
            dispatch_group_leave(ads_loading_group);
        });
    }];
    dispatch_group_notify(ads_loading_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(offers, nil);
    });
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"MTGNative::nativeAdsFailedToLoadWithError:%@", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.MTGNativeLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:@"MTGSDK has failed to load native ad"}]);
}

- (void)nativeAdImpressionWithType:(ATMTGAdSourceType)type mediaView:(id<ATMTGMediaView>)mediaView {
    //Impression will be tracked within the base ad view
    [ATLogger logMessage:@"MTGNative::nativeAdImpressionWithType:mediaView:" type:ATLogTypeExternal];
}

- (void)nativeAdDidClick:(nonnull id<ATMTGCampaign>)nativeAd nativeManager:(id<ATMTGMediaView>)nativeManager {
    [ATLogger logMessage:@"MTGNative::nativeAdDidClick:nativeManager:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

#pragma mark - header bidding
- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds bidNativeManager:(nonnull id<ATMTGBidNativeAdManager>)bidNativeManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MTGNative(Header Bidding)::nativeAdsLoaded: bidNativeManager:"] type:ATLogTypeExternal];
    NSMutableArray<NSDictionary*>* offers = [NSMutableArray<NSDictionary*> array];
    dispatch_group_t ads_loading_group = dispatch_group_create();
    [nativeAds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(ads_loading_group);
        __weak id<ATMTGCampaign> campaign = obj;
        NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:campaign, kAdAssetsCustomObjectKey, self.unitID, kNativeADAssetsUnitIDKey, self, kATMintegralNativeAssetCustomEvent, nil];
        assets[kMTGAssetsNativeAdManagerKey] = _bidNativeAdManager;
        if ([campaign.appName length] > 0) {
            assets[kNativeADAssetsMainTitleKey] = campaign.appName;
        }
        if ([campaign.appDesc length] > 0) {
            assets[kNativeADAssetsMainTextKey] = campaign.appDesc;
        }
        if ([campaign.adCall length] > 0) {
            assets[kNativeADAssetsCTATextKey] = campaign.adCall;
        }
        
        dispatch_group_t image_load_group = dispatch_group_create();
        
        if ([campaign.imageUrl length] > 0) {
            assets[kNativeADAssetsImageURLKey] = campaign.imageUrl;
            dispatch_group_enter(image_load_group);
            [campaign loadImageUrlAsyncWithBlock:^(UIImage *image) {
                if (image != nil) {
                    assets[kNativeADAssetsMainImageKey] = image;
                }
                dispatch_group_leave(image_load_group);
            }];
        }
        
        if ([campaign.iconUrl length] > 0) {
            assets[kNativeADAssetsIconURLKey] = campaign.iconUrl;
            dispatch_group_enter(image_load_group);
            [campaign loadIconUrlAsyncWithBlock:^(UIImage *image) {
                if (image != nil) {
                    assets[kNativeADAssetsIconImageKey] = image;
                }
                dispatch_group_leave(image_load_group);
            }];
        }
        dispatch_group_notify(image_load_group, dispatch_get_main_queue(), ^{
            [offers addObject:assets];
            dispatch_group_leave(ads_loading_group);
        });
    }];
    dispatch_group_notify(ads_loading_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(offers, nil);
    });
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error bidNativeManager:(nonnull id<ATMTGBidNativeAdManager>)bidNativeManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MTGNative(Header Bidding)::nativeAdsFailedToLoadWithError:%@ bidNativeManager:", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.MTGNativeLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:@"MTGSDK has failed to load native ad"}]);
}

- (void)nativeAdDidClick:(nonnull id<ATMTGCampaign>)nativeAd bidNativeManager:(nonnull id<ATMTGBidNativeAdManager>)bidNativeManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MTGNative(Header Bidding)::nativeAdDidClick: bidNativeManager:"] type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

- (void)nativeAdClickUrlWillStartToJump:(nonnull NSURL *)clickUrl bidNativeManager:(nonnull id<ATMTGBidNativeAdManager>)bidNativeManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MTGNative(Header Bidding)::nativeAdClickUrlWillStartToJump:%@ bidNativeManager:", clickUrl] type:ATLogTypeExternal];
}

- (void)nativeAdClickUrlDidJumpToUrl:(nonnull NSURL *)jumpUrl bidNativeManager:(nonnull id<ATMTGBidNativeAdManager>)bidNativeManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MTGNative(Header Bidding)::nativeAdClickUrlDidJumpToUrl:%@ bidNativeManager:", jumpUrl] type:ATLogTypeExternal];
}

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl error:(nullable NSError *)error bidNativeManager:(nonnull id<ATMTGBidNativeAdManager>)bidNativeManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MTGNative(Header Bidding)::nativeAdClickUrlDidEndJump: error:%@ bidNativeManager:", error] type:ATLogTypeExternal];
}

- (void)nativeAdImpressionWithType:(NSInteger)type bidNativeManager:(nonnull id<ATMTGBidNativeAdManager>)bidNativeManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MTGNative(Header Bidding)::nativeAdImpressionWithType:%ld bidNativeManager:", type] type:ATLogTypeExternal];
}
@end
