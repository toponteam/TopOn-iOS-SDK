//
//  ATNendNativeCustomEvent.m
//  AnyThinkNendNativeAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendNativeCustomEvent.h"
#import "Utilities.h"
#import "ATNativeADView.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATImageLoader.h"
#import "ATAdManagement.h"
#import "ATPlacementModel.h"
#import "ATNativeADCache.h"
@implementation ATNendNativeCustomEvent
-(void) handleNativeAds:(NSArray*)nativeAds error:(NSError *)error {
    if ([nativeAds count] > 0) {
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        __weak typeof(self) weakSelf = self;
        [nativeAds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:self, kAdAssetsCustomEventKey, obj, kAdAssetsCustomObjectKey, nil];
            dispatch_group_t image_request_group = dispatch_group_create();
            if (weakSelf.video) {
                id<ATNADNativeVideo> nativeVideo = (id<ATNADNativeVideo>)obj;
                asset[kNativeADAssetsRatingKey] = @(nativeVideo.userRating);
                if (nativeVideo.title != nil) { asset[kNativeADAssetsMainTitleKey] = nativeVideo.title; }
                if (nativeVideo.advertiserName != nil) { asset[kNativeADAssetsAdvertiserKey] = nativeVideo.advertiserName; }
                if (nativeVideo.explanation != nil) { asset[kNativeADAssetsMainTextKey] = nativeVideo.explanation; }
                if (nativeVideo.callToAction != nil) { asset[kNativeADAssetsCTATextKey] = nativeVideo.callToAction; }
                if (nativeVideo.logoImageUrl != nil) { asset[kNativeADAssetsIconURLKey] = nativeVideo.logoImageUrl; }
                if (nativeVideo.logoImage != nil) { asset[kNativeADAssetsIconImageKey] = nativeVideo.logoImage; }
                dispatch_group_enter(image_request_group);
                [nativeVideo downloadLogoImageWithCompletionHandler:^(UIImage * _Nullable image) {
                    if (image != nil) { asset[kNativeADAssetsIconImageKey] = image; }
                    dispatch_group_leave(image_request_group);
                }];
            } else {
                id<ATNADNative> native = (id<ATNADNative>)obj;
                if (native.shortText != nil) { asset[kNativeADAssetsMainTitleKey] = native.shortText;}
                if (native.longText != nil) { asset[kNativeADAssetsMainTextKey] = native.longText; }
                if (native.actionButtonText != nil) { asset[kNativeADAssetsCTATextKey] = native.actionButtonText; }
                if (native.imageUrl != nil) { asset[kNativeADAssetsImageURLKey] = native.imageUrl; }
                if (native.logoUrl != nil) { asset[kNativeADAssetsIconURLKey] = native.logoUrl; }
                dispatch_group_enter(image_request_group);
                [native loadLogoImageWithCompletionBlock:^(UIImage *image) {
                    if (image != nil) { asset[kNativeADAssetsIconImageKey] = image; }
                    dispatch_group_leave(image_request_group);
                }];
                dispatch_group_enter(image_request_group);
                [native loadAdImageWithCompletionBlock:^(UIImage *image) {
                    if (image != nil) { asset[kNativeADAssetsMainImageKey] = image; }
                    dispatch_group_leave(image_request_group);
                }];
            }
            dispatch_group_notify(image_request_group, dispatch_get_main_queue(), ^{
                [assets addObject:asset];
                if ([assets count] == [nativeAds count]) { self.requestCompletionBlock(assets, nil);}
            });
        }];
    } else {
        self.requestCompletionBlock(nil, error);
    }
}

#pragma mark - native delegate
- (void)nadNativeDidClickAd:(id<ATNADNative>)ad {
    [ATLogger logMessage:@"NendNative::nadNativeDidClickAd:" type:ATLogTypeExternal];
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

#pragma mark - native delegate(s)
- (void)nadNativeVideoDidImpression:(id<ATNADNativeVideo> _Nonnull)ad {
    [ATLogger logMessage:@"NendNaitve::nadNativeVideoDidImpression:" type:ATLogTypeExternal];
}

- (void)nadNativeVideoDidClickAd:(id<ATNADNativeVideo> _Nonnull)ad {
    [ATLogger logMessage:@"NendNaitve::nadNativeVideoDidClickAd:" type:ATLogTypeExternal];
    [self.adView notifyNativeAdClick];
    [self trackClick];
}

- (void)nadNativeVideoDidClickInformation:(id<ATNADNativeVideo> _Nonnull)ad {
    [ATLogger logMessage:@"NendNaitve::nadNativeVideoDidClickInformation:" type:ATLogTypeExternal];
}

#pragma mark - video view delegate
- (void)nadNativeVideoViewDidStartPlay:(id<ATNADNativeVideoView>)videoView {
    [ATLogger logMessage:@"NendNaitve::nadNativeVideoViewDidStartPlay:" type:ATLogTypeExternal];
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    [[ATTracker sharedTracker] trackWithPlacementID:cache.placementModel.placementID unitGroupID:cache.unitGroup.unitGroupID requestID:cache.requestID network:cache.unitGroup.networkFirmID format:0 trackType:ATNativeADTrackTypeVideoPlayed resourceType:ATNativeADSourceTypeVideo progress:0 extra:nil];
    [self trackVideoStart];
    [self.adView notifyVideoStart];
}

- (void)nadNativeVideoViewDidStopPlay:(id<ATNADNativeVideoView>)videoView {
    [ATLogger logMessage:@"NendNaitve::nadNativeVideoViewDidStopPlay:" type:ATLogTypeExternal];
}

- (void)nadNativeVideoViewDidCompletePlay:(id<ATNADNativeVideoView>)videoView {
    [ATLogger logMessage:@"NendNaitve::nadNativeVideoViewDidCompletePlay:" type:ATLogTypeExternal];
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    [[ATTracker sharedTracker] trackWithPlacementID:cache.placementModel.placementID unitGroupID:cache.unitGroup.unitGroupID requestID:cache.requestID network:cache.unitGroup.networkFirmID format:0 trackType:ATNativeADTrackTypeVideoPlayed resourceType:ATNativeADSourceTypeVideo progress:100 extra:nil];
    [self trackVideoEnd];
    [self.adView notifyVideoEnd];
}

- (void)nadNativeVideoViewDidFailToPlay:(id<ATNADNativeVideoView>)videoView {
    [ATLogger logMessage:@"NendNaitve::nadNativeVideoViewDidFailToPlay:" type:ATLogTypeExternal];
}

- (void)nadNativeVideoViewDidOpenFullScreen:(id<ATNADNativeVideoView>)videoView {
    [ATLogger logMessage:@"NendNaitve::nadNativeVideoViewDidOpenFullScreen:" type:ATLogTypeExternal];
    [self.adView notifyVideoEnterFullScreen];
}

- (void)nadNativeVideoViewDidCloseFullScreen:(id<ATNADNativeVideoView>)videoView {
    [ATLogger logMessage:@"NendNaitve::nadNativeVideoViewDidCloseFullScreen:" type:ATLogTypeExternal];
    [self.adView notifyVideoExitFullScreen];
}
@end
