//
//  ATAppnextNativeCustomEvent.m
//  AnyThinkAppnextNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextNativeCustomEvent.h"
#import "Utilities.h"
#import "ATNativeADView.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "ATImageLoader.h"

@implementation ATAppnextNativeCustomEvent
- (void) onAdsLoaded:(NSArray<id<ATAppnextAdData>> *)ads forRequest:(id<ATAppnextNativeAdsRequest>)request {
    [ATLogger logMessage:@"AppnextNative::onAdsLoaded:forRequest:" type:ATLogTypeExternal];
    NSMutableArray<NSMutableDictionary*>* assets = [NSMutableArray<NSMutableDictionary*> arrayWithCapacity:[ads count]];
    dispatch_group_t image_loading_group = dispatch_group_create();
    
    [ads enumerateObjectsUsingBlock:^(id<ATAppnextAdData>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:obj.title, kNativeADAssetsMainTitleKey, obj.desc, kNativeADAssetsMainTextKey, obj.buttonText, kNativeADAssetsCTATextKey, obj.urlImg, kNativeADAssetsIconURLKey, obj.urlImgWide, kNativeADAssetsImageURLKey, obj.storeRating, kNativeADAssetsRatingKey, obj, kAdAssetsCustomObjectKey, self.api, kAppnextNativeAssetsAPIObjectKey, nil];
        [assets addObject:asset];
        
        dispatch_group_enter(image_loading_group);
        [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.urlImg] completion:^(UIImage *image, NSError *error) {
            if ([image isKindOfClass:[UIImage class]]) {asset[kNativeADAssetsIconImageKey] = image;}
            dispatch_group_leave(image_loading_group);
        }];
        
        dispatch_group_enter(image_loading_group);
        [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.urlImgWide] completion:^(UIImage *image, NSError *error) {
            if ([image isKindOfClass:[UIImage class]]) {asset[kNativeADAssetsMainImageKey] = image;}
            dispatch_group_leave(image_loading_group);
        }];
    }];
    
    dispatch_group_notify(image_loading_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(assets, nil);
    });
}

- (void) onError:(NSString *)error forRequest:(id<ATAppnextNativeAdsRequest>)request {
    [ATLogger logError:[NSString stringWithFormat:@"AppnextNative::onError:%@ forRequest:", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"Appnext failed to loading native ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@", error]}]);
}

- (void) storeOpened:(id<ATAppnextAdData>)adData {
    [ATLogger logMessage:@"AppnextNative::storeOpened:" type:ATLogTypeExternal];
}

- (void) onError:(NSString *)error forAdData:(id<ATAppnextAdData>)adData {
    [ATLogger logMessage:[NSString stringWithFormat:@"AppnextNative::onError%@:forAdData:", error] type:ATLogTypeExternal];
}
@end
