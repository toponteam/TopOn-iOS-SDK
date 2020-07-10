//
//  ATApplovinCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinCustomEvent.h"
#import "ATImageLoader.h"
#import "ATAPI+Internal.h"
#import "ATNativeADView.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATNativeADView+Internal.h"
#import "ATPlacementModel.h"
#import "ATTracker.h"
#import "ATLogger.h"
#import "ATApplovinNativeAdapter.h"


@implementation ATApplovinCustomEvent
- (void)nativeAdService:(id<ATALNativeAdService>)service didLoadAds:(NSArray * /* of ALNativeAd */) ads {
    if ([ads count] > 0) {
        id<ATALNativeAd> nativeAD = ads[0];
        NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:nativeAD, kAdAssetsCustomObjectKey, self.unitID, kNativeADAssetsUnitIDKey, nil];
        if ([nativeAD.title length] > 0) {
            assets[kNativeADAssetsMainTitleKey] = nativeAD.title;
        }
        if ([nativeAD.descriptionText length]) {
            assets[kNativeADAssetsMainTextKey] = nativeAD.descriptionText;
        }
        if ([nativeAD.ctaText length] > 0) {
            assets[kNativeADAssetsCTATextKey] = nativeAD.ctaText;
        }
        if (nativeAD.starRating != nil) {
            assets[kNativeADAssetsRatingKey] = nativeAD.starRating;
        }
        assets[kNativeADAssetsContainsVideoFlag] = @(nativeAD.videoURL != nil);
        
        dispatch_group_t img_load_group = dispatch_group_create();
        
        dispatch_group_enter(img_load_group);
        [[ATImageLoader shareLoader] loadImageWithURL:nativeAD.imageURL completion:^(UIImage *image, NSError *error) {
            if (image != nil) {
                assets[kNativeADAssetsMainImageKey] = image;
            }
            dispatch_group_leave(img_load_group);
        }];
        
        dispatch_group_enter(img_load_group);
        [[ATImageLoader shareLoader] loadImageWithURL:nativeAD.iconURL completion:^(UIImage *image, NSError *error) {
            if (image != nil) {
                assets[kNativeADAssetsIconImageKey] = image;
            }
            dispatch_group_leave(img_load_group);
        }];
        
        dispatch_group_notify(img_load_group, dispatch_get_main_queue(), ^{
            [self handleAssets:assets];
        });
    }
}

- (void)nativeAdService:(id<ATALNativeAdService>)service didFailToLoadAdsWithError:(NSInteger)code {
    [ATLogger logError:[NSString stringWithFormat:@"Applovin has failed to load offer, error code: %ld", code] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AD Loading has failed", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Third-party network sdk failed with code:%ld", code]}]);
}

-(void) trackShow:(BOOL)refresh {
    [super trackShow:refresh];
    id<ATALNativeAd> nativeAd = (id<ATALNativeAd>)((ATNativeADCache*)(self.adView.nativeAd)).customObject;
    [nativeAd trackImpression];
}

-(void) didClickAdView {
    id<ATALNativeAd> nativeAd = (id<ATALNativeAd>)((ATNativeADCache*)(self.adView.nativeAd)).customObject;
    if ([nativeAd respondsToSelector:@selector(launchClickTarget)]) [nativeAd launchClickTarget];
    
    [self trackClick];
    [self.adView notifyNativeAdClick];
}

-(void) videoDidFinishPlayingInVideoView:(ATVideoView *)videoView {
//    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    [[ATTracker sharedTracker] trackWithPlacementID:cache.placementModel.placementID unitGroupID:cache.unitGroup.unitGroupID requestID:cache.requestID network:cache.unitGroup.networkFirmID format:0 trackType:ATNativeADTrackTypeVideoPlayed resourceType:ATNativeADSourceTypeVideo progress:100 extra:nil];
    [self trackVideoEnd];
    [self.adView notifyVideoEnd];
    id<ATALNativeAd> nativeAd = (id<ATALNativeAd>)((ATNativeADCache*)(self.adView.nativeAd)).customObject;
    [self trackURL:[nativeAd videoEndTrackingURL:100 firstPlay:YES]];
}

-(void) videoDidPlayInVideoView:(ATVideoView *)videoView {
//    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    [[ATTracker sharedTracker] trackWithPlacementID:cache.placementModel.placementID unitGroupID:cache.unitGroup.unitGroupID requestID:cache.requestID network:cache.unitGroup.networkFirmID format:0 trackType:ATNativeADTrackTypeVideoPlayed resourceType:ATNativeADSourceTypeVideo progress:0 extra:nil];
    [self trackVideoStart];
    [self.adView notifyVideoStart];
    id<ATALNativeAd> nativeAd = (id<ATALNativeAd>)((ATNativeADCache*)(self.adView.nativeAd)).customObject;
    [self trackURL:[nativeAd videoStartTrackingURL]];
}

-(void) trackURL:(NSURL*)URL {
    [[[NSURLSession sharedSession] dataTaskWithURL:URL] resume];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = @"";
    return extra;
}
@end
