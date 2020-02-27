//
//  ATMobPowerNativeCustomEvent.m
//  AnyThinkMobPowerNativeAdapter
//
//  Created by Martin Lau on 2018/12/24.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMobPowerNativeCustomEvent.h"
#import "Utilities.h"
#import "ATNativeADView.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "ATImageLoader.h"
#import "ATAdManagement.h"
@implementation ATMobPowerNativeCustomEvent
-(void) didLoadNativeAds:(NSArray<id<ATMPNative>>*)ads forPlacementID:(NSString*)placementID {
    [ATLogger logMessage:@"MobPowerNative::didLoadNativeAds:forPlacementID:" type:ATLogTypeExternal];
    NSMutableArray<NSMutableDictionary*>* assets = [NSMutableArray<NSMutableDictionary*> arrayWithCapacity:[ads count]];
    dispatch_group_t image_loading_group = dispatch_group_create();
    
    [ads enumerateObjectsUsingBlock:^(id<ATMPNative>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:obj.titile, kNativeADAssetsMainTitleKey, obj.body, kNativeADAssetsMainTextKey, obj.ctaText, kNativeADAssetsCTATextKey, obj.iconURL, kNativeADAssetsIconURLKey, obj.imageURL, kNativeADAssetsImageURLKey, [NSString stringWithFormat:@"%.1f", obj.star], kNativeADAssetsRatingKey, obj, kNativeADAssetsNetworkCustomObjectKey, self, kAdAssetsCustomEventKey, nil];
        [assets addObject:asset];
        
        dispatch_group_enter(image_loading_group);
        [[ATImageLoader shareLoader] loadImageWithURL:obj.iconURL completion:^(UIImage *image, NSError *error) {
            if ([image isKindOfClass:[UIImage class]]) {asset[kNativeADAssetsIconImageKey] = image;}
            dispatch_group_leave(image_loading_group);
        }];
        
        dispatch_group_enter(image_loading_group);
        [[ATImageLoader shareLoader] loadImageWithURL:obj.imageURL completion:^(UIImage *image, NSError *error) {
            if ([image isKindOfClass:[UIImage class]]) {asset[kNativeADAssetsMainImageKey] = image;}
            dispatch_group_leave(image_loading_group);
        }];
    }];
    
    dispatch_group_notify(image_loading_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(assets, nil);
    });
}

-(void) failToLoadNativeAdsForPlacementID:(NSString*)placementID error:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"MobPowerNative::failToLoadNativeAdsForPlacementID: error:%@", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error);
}

-(void) didShowNativeAd:(id<ATMPNative>)nativeAd {
    [ATLogger logMessage:@"MobPowerNative::didShowNativeAd:" type:ATLogTypeExternal];
}

-(void) didClickNativeAd:(id<ATMPNative>)nativeAd {
    [ATLogger logMessage:@"MobPowerNative::didClickNativeAd:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

-(void) startClickNativeAd:(id<ATMPNative>)nativeAd {
    [ATLogger logMessage:@"MobPowerNative::startClickNativeAd:" type:ATLogTypeExternal];
}

-(void) endClickNativeAd:(id<ATMPNative>)nativeAd {
    [ATLogger logMessage:@"MobPowerNative::endClickNativeAd:" type:ATLogTypeExternal];
}
@end
