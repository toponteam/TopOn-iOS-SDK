//
//  ATFlurryCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFlurryCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATImageLoader.h"
#import "ATAgentEvent.h"
#import "ATNativeADView.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCustomEvent.h"
#import "ATTracker.h"
#import "ATNativeADView+Internal.h"
#import "ATNativeADCache.h"

@implementation ATFlurryCustomEvent
- (void) adNativeDidFetchAd:(id<ATFlurryAdNative>)nativeAd {
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:nativeAd, kAdAssetsCustomObjectKey, self.unitID, kNativeADAssetsUnitIDKey, nil];
    NSDictionary *retrivingKeys = @{
                                    @"source":kNativeADAssetsAdvertiserKey,
                                    @"headline":kNativeADAssetsMainTitleKey,
                                    @"summary":kNativeADAssetsMainTextKey,
                                    @"secImage":kNativeADAssetsIconImageKey,
                                    @"secHqImage":kNativeADAssetsMainImageKey,
                                    @"callToAction":kNativeADAssetsCTATextKey,
                                    @"secBrandingLogo":kNativeADAssetsSponsoredImageKey
                                    };
    [nativeAd.assetList enumerateObjectsUsingBlock:^(id<ATFlurryAdNativeAsset>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([retrivingKeys containsObjectForKey:obj.name]) assets[retrivingKeys[obj.name]] = obj.value;
    }];
    
    dispatch_group_t img_loading_group = dispatch_group_create();
    
    if ([assets containsObjectForKey:kNativeADAssetsMainImageKey]) {
        if ([assets[kNativeADAssetsMainImageKey] length] > 0) {
            dispatch_group_enter(img_loading_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:assets[kNativeADAssetsMainImageKey]] completion:^(UIImage *image, NSError *error) {
                if (image != nil) assets[kNativeADAssetsMainImageKey] = image;
                else [assets removeObjectForKey:kNativeADAssetsMainImageKey];
                dispatch_group_leave(img_loading_group);
            }];
        }
    }
    
    if ([assets containsObjectForKey:kNativeADAssetsIconImageKey]) {
        if ([assets[kNativeADAssetsIconImageKey] length] > 0) {
            dispatch_group_enter(img_loading_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:assets[kNativeADAssetsIconImageKey]] completion:^(UIImage *image, NSError *error) {
                if (image != nil) assets[kNativeADAssetsIconImageKey] = image;
                else [assets removeObjectForKey:kNativeADAssetsIconImageKey];
                dispatch_group_leave(img_loading_group);
            }];
        }
    }
    
    if ([assets containsObjectForKey:kNativeADAssetsSponsoredImageKey]) {
        if ([assets[kNativeADAssetsSponsoredImageKey] length] > 0) {
            dispatch_group_enter(img_loading_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:assets[kNativeADAssetsSponsoredImageKey]] completion:^(UIImage *image, NSError *error) {
                if (image != nil) assets[kNativeADAssetsSponsoredImageKey] = image;
                else [assets removeObjectForKey:kNativeADAssetsSponsoredImageKey];
                dispatch_group_leave(img_loading_group);
            }];
        }
    }
    
    dispatch_group_notify(img_loading_group, dispatch_get_main_queue(), ^{
        [self trackNativeAdLoaded:assets];
    });
}

- (void) adNative:(id<ATFlurryAdNative>)nativeAd adError:(ATFlurryAdError)adError errorDescription:(NSError*) errorDescription {
    [ATLogger logError:[NSString stringWithFormat:@"Flurry has failed to load offer with code:%u, error: %@", adError, errorDescription] type:ATLogTypeExternal];
    [self trackNativeAdLoadFailed:errorDescription];
}

- (void) adNativeDidLogImpression:(id<ATFlurryAdNative>) nativeAd {
    //Impression is tracked in the ad view.
}

- (void) adNativeDidReceiveClick:(id<ATFlurryAdNative>) nativeAd {
    [self trackNativeAdClick];
}

- (NSString *)networkUnitId {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    return cache.unitGroup.content[@"ad_space"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"ad_space"];
//    return extra;
//}

@end
