//
//  ATFacebookCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATTracker.h"
#import "ATNativeADCache.h"
#import "ATUnitGroupModel.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "ATPlacementModel.h"
#import "ATLogger.h"
#import "ATAdManagement.h"
NSString *const kATFBNativeADAssetsADChoiceImageKey = @"ad_choice";
NSInteger const kATFBNativeAdViewIconMediaViewFlag = 20190416;
@implementation ATFacebookCustomEvent
- (void)nativeAdDidLoad:(id<ATFBNativeAd>)nativeAd {
    [ATLogger logMessage:@"FacebookNative::nativeAdDidLoad:" type:ATLogTypeExternal];
    dispatch_group_t image_loading_group = dispatch_group_create();
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:nativeAd, kAdAssetsCustomObjectKey, self.unitID, kNativeADAssetsUnitIDKey, self, kAdAssetsCustomEventKey, nil];
    assets[kNativeADAssetsMainTitleKey] = @"";
    assets[kNativeADAssetsMainTextKey] = @"";
    assets[kNativeADAssetsCTATextKey] = @"";

    dispatch_group_enter(image_loading_group);
    [nativeAd.adChoicesIcon loadImageAsyncWithBlock:^(UIImage * _Nullable image) {
        if (image != nil) assets[kATFBNativeADAssetsADChoiceImageKey] = image;
        dispatch_group_leave(image_loading_group);
    }];
    
    dispatch_group_notify(image_loading_group, dispatch_get_main_queue(), ^{ [self handleAssets:assets]; });
}

- (void)nativeAdDidDownloadMedia:(id<ATFBNativeAd>)nativeAd { [ATLogger logMessage:@"FacebookNative::nativeAdDidDownloadMedia:" type:ATLogTypeExternal]; }

- (void)nativeAd:(id<ATFBNativeAd>)nativeAd didFailWithError:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"FacebookNative::nativeAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)nativeAdWillLogImpression:(id<ATFBNativeAd>)nativeAd { [ATLogger logMessage:@"FacebookNative::nativeAdWillLogImpression:" type:ATLogTypeExternal]; }

- (void)nativeAdDidClick:(id<ATFBNativeAd>)nativeAd {
    [ATLogger logMessage:@"FacebookNative::nativeAdDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

- (void)nativeAdDidFinishHandlingClick:(id<ATFBNativeAd>)nativeAd { [ATLogger logMessage:@"FacebookNative::nativeAdDidFinishHandlingClick:" type:ATLogTypeExternal]; }

- (void)mediaViewVideoDidPlay:(id<ATFBMediaView>)mediaView {
    [ATLogger logMessage:@"FacebookNative::mediaViewVideoDidPlay:" type:ATLogTypeExternal];
    [self trackVideoStart];
    [self.adView notifyVideoStart];
}

- (void)mediaViewVideoDidComplete:(id<ATFBMediaView>)mediaView {
    [ATLogger logMessage:@"FacebookNative::mediaViewVideoDidComplete:" type:ATLogTypeExternal];
    [self trackVideoEnd];
    [self.adView notifyVideoEnd];
}

-(void) didAttachMediaView {
    if ([[self.adView clickableViews] count] > 0) {
        id<ATFBNativeAd> nativeAd = (id<ATFBNativeAd>)(((ATNativeADCache*)self.adView.nativeAd).customObject);
        if ([nativeAd isKindOfClass:NSClassFromString(@"FBNativeAd")]) { [nativeAd registerViewForInteraction:self.adView mediaView:(id<ATFBMediaView>)self.adView.mediaView iconView:(id<ATFBMediaView>)[self.adView.iconImageView viewWithTag:kATFBNativeAdViewIconMediaViewFlag] viewController:nil clickableViews:[self.adView clickableViews]]; }
    }
}

-(ATNativeADSourceType) sourceType {
    id<ATFBNativeAd> nativeAd = (id<ATFBNativeAd>)(((ATNativeADCache*)self.adView.nativeAd).customObject);
    return nativeAd.adFormatType == ATFBAdFormatTypeVideo ? ATNativeADSourceTypeVideo : ATNativeADSourceTypeImage;
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"unit_id"];
    return extra;
}

#pragma mark - native banner
- (void)nativeBannerAdDidLoad:(id<ATFBNativeBannerAd>)nativeBannerAd {
    [ATLogger logMessage:@"FacebookNativeBanner::nativeBannerAdDidLoad:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:nativeBannerAd, kAdAssetsCustomObjectKey, self.unitID, kNativeADAssetsUnitIDKey, self, kAdAssetsCustomEventKey, nil];
    assets[kNativeADAssetsMainTitleKey] = @"";
    assets[kNativeADAssetsMainTextKey] = @"";
    assets[kNativeADAssetsCTATextKey] = @"";
    [self handleAssets:assets];
}

- (void)nativeBannerAdDidDownloadMedia:(id<ATFBNativeBannerAd>)nativeBannerAd { [ATLogger logMessage:@"FacebookNativeBanner::nativeBannerAdDidDownloadMedia:" type:ATLogTypeExternal]; }

- (void)nativeBannerAdWillLogImpression:(id<ATFBNativeBannerAd>)nativeBannerAd { [ATLogger logMessage:@"FacebookNativeBanner::nativeBannerAdWillLogImpression:" type:ATLogTypeExternal]; }

- (void)nativeBannerAd:(id<ATFBNativeBannerAd>)nativeBannerAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"FacebookNativeBanner::nativeBannerAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)nativeBannerAdDidClick:(id<ATFBNativeBannerAd>)nativeBannerAd {
    [ATLogger logMessage:@"FacebookNativeBanner::nativeBannerAdDidFinishHandlingClick:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

- (void)nativeBannerAdDidFinishHandlingClick:(id<ATFBNativeBannerAd>)nativeBannerAd { [ATLogger logMessage:@"FacebookNativeBanner::nativeBannerAdDidFinishHandlingClick:" type:ATLogTypeExternal]; }
@end
