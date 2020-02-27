//
//  ATYeahmobiNativeCustomEvent.m
//  AnyThinkYeahmobiNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATYeahmobiNativeCustomEvent.h"
#import "ATYeahmobiNativeAdapter.h"
#import "Utilities.h"
#import "ATNativeADView.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "ATImageLoader.h"
@implementation ATYeahmobiNativeCustomEvent
-(void) loadSuccessed:(NSArray<id<ATCTNativeAdModel>>*)ads {
    [ATLogger logMessage:@"YeahmobiNative::loadSuccessed:" type:ATLogTypeExternal];
    NSMutableArray<NSMutableDictionary*>* assets = [NSMutableArray<NSMutableDictionary*> arrayWithCapacity:[ads count]];
    dispatch_group_t image_loading_group = dispatch_group_create();
    
    [ads enumerateObjectsUsingBlock:^(id<ATCTNativeAdModel>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:obj.title, kNativeADAssetsMainTitleKey, obj.desc, kNativeADAssetsMainTextKey, obj.button, kNativeADAssetsCTATextKey, obj.icon, kNativeADAssetsIconURLKey, obj.image, kNativeADAssetsImageURLKey, [NSString stringWithFormat:@"%.1f", obj.star], kNativeADAssetsRatingKey, obj, kAdAssetsCustomObjectKey, self, kYearmobiNativeAssetsCustomEventKey, nil];
        [assets addObject:asset];
        
        if (obj.icon != nil) {
            dispatch_group_enter(image_loading_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.icon] completion:^(UIImage *image, NSError *error) {
                if ([image isKindOfClass:[UIImage class]]) {asset[kNativeADAssetsIconImageKey] = image;}
                dispatch_group_leave(image_loading_group);
            }];
        }
        
        if (obj.image != nil) {
            dispatch_group_enter(image_loading_group);
            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:obj.image] completion:^(UIImage *image, NSError *error) {
                if ([image isKindOfClass:[UIImage class]]) {asset[kNativeADAssetsMainImageKey] = image;}
                dispatch_group_leave(image_loading_group);
            }];
        }
    }];
    
    dispatch_group_notify(image_loading_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(assets, nil);
    });
}

-(void) loadFailed:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiNative::loadFailed:%@", error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error);
}

-(void)CTNativeAdDidIntoLandingPage:(NSObject *)nativeModel {
    [ATLogger logMessage:@"YeahmobiNaitve::CTNativeAdDidIntoLandingPage:" type:ATLogTypeExternal];
}

-(void)CTNativeAdWillLeaveApplication:(NSObject *)nativeModel {
    [ATLogger logMessage:@"YeahmobiNaitve::CTNativeAdWillLeaveApplication:" type:ATLogTypeExternal];
}

-(void)CTNativeAdJumpfail:(NSObject *)nativeModel {
    [ATLogger logMessage:@"YeahmobiNaitve::CTNativeAdJumpfail:" type:ATLogTypeExternal];
}
@end
