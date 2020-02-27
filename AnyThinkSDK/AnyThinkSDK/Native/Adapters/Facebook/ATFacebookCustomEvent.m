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
NSString *const kATFBNativeADAssetsADChoiceImageKey = @"ad_choice";
NSInteger const kATFBNativeAdViewIconMediaViewFlag = 20190416;
@implementation ATFacebookCustomEvent
- (void)nativeAdDidLoad:(id<ATFBNativeAd>)nativeAd {
    dispatch_group_t image_loading_group = dispatch_group_create();
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:nativeAd, kAdAssetsCustomObjectKey, self.unitID, kNativeADAssetsUnitIDKey, nil];
    assets[kNativeADAssetsMainTitleKey] = @"";
    assets[kNativeADAssetsMainTextKey] = @"";
    assets[kNativeADAssetsCTATextKey] = @"";

    dispatch_group_enter(image_loading_group);
    [nativeAd.adChoicesIcon loadImageAsyncWithBlock:^(UIImage * _Nullable image) {
        if (image != nil) assets[kATFBNativeADAssetsADChoiceImageKey] = image;
        dispatch_group_leave(image_loading_group);
    }];
    
    dispatch_group_notify(image_loading_group, dispatch_get_main_queue(), ^{
        [self handleAssets:assets];
    });
}

- (void)nativeAdDidDownloadMedia:(id<ATFBNativeAd>)nativeAd {
    [ATLogger logMessage:@"FacebookNative::nativeAdDidDownloadMedia:" type:ATLogTypeExternal];
}

- (void)nativeAd:(id<ATFBNativeAd>)nativeAd didFailWithError:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"Facebook has failed to load offer, error: %@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)nativeAdWillLogImpression:(id<ATFBNativeAd>)nativeAd {
    //Impression tracked in ad view
}

- (void)nativeAdDidClick:(id<ATFBNativeAd>)nativeAd {
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

- (void)nativeAdDidFinishHandlingClick:(id<ATFBNativeAd>)nativeAd {
    //
}

- (void)mediaViewVideoDidPlay:(id<ATFBMediaView>)mediaView {
    [self trackVideoStart];
    [self.adView notifyVideoStart];
}

/**
 Sent when a video ad in an FBMediaView reaches the end of playback.
 
 - Parameter mediaView: An FBMediaView object sending the message.
 */
- (void)mediaViewVideoDidComplete:(id<ATFBMediaView>)mediaView {
    [self trackVideoEnd];
    [self.adView notifyVideoEnd];
}

-(void) didAttachMediaView {
    if ([[self.adView clickableViews] count] > 0) {
        id<ATFBNativeAd> nativeAd = (id<ATFBNativeAd>)(((ATNativeADCache*)self.adView.nativeAd).customObject);
        if ([nativeAd isKindOfClass:NSClassFromString(@"FBNativeAd")]) {
            [nativeAd registerViewForInteraction:self.adView mediaView:(id<ATFBMediaView>)self.adView.mediaView iconView:(id<ATFBMediaView>)[self.adView.iconImageView viewWithTag:kATFBNativeAdViewIconMediaViewFlag] viewController:nil clickableViews:[self.adView clickableViews]];
        }
    }
}

-(ATNativeADSourceType) sourceType {
    id<ATFBNativeAd> nativeAd = (id<ATFBNativeAd>)(((ATNativeADCache*)self.adView.nativeAd).customObject);
    return nativeAd.adFormatType == ATFBAdFormatTypeVideo ? ATNativeADSourceTypeVideo : ATNativeADSourceTypeImage;
}
@end
