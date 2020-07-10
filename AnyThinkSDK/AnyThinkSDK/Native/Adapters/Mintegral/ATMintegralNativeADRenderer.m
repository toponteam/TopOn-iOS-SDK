//
//  ATMintegralNativeADRenderer.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 20/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralNativeADRenderer.h"
#import "ATNativeADView.h"
#import "ATNativeADView+Internal.h"
#import "ATNativeADConfiguration.h"
#import "ATMintegralNativeAdapter.h"
#import "ATMintegralNativeCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATAPI+Internal.h"
#import "ATLogger.h"
#import "ATNativeADOfferManager.h"
@protocol ATNativeADView<NSObject>
@property(nonatomic, readonly) ATNativeADCache *nativeAd;
@end

@interface ATMintegralNativeADRenderer()
@property(nonatomic, weak) ATNativeADView *ADView_impl;
@property(nonatomic, readonly) ATNativeADCache *nativeAdCache;
@end
@implementation ATMintegralNativeADRenderer
-(ATNativeADCache*)nativeAdCache { return ((ATNativeADCache*)((id<ATNativeADView>)self.ADView).nativeAd); }

-(__kindof UIView*)createMediaView {
    if ([self.nativeAdCache.unitGroup.content[@"unit_type"] integerValue] == 0) {
        UIView *mediaView = [[NSClassFromString(@"MTGMediaView") alloc] init];
        if (mediaView == nil) [ATLogger logError:@"Can't find MTGMediaView." type:ATLogTypeExternal];
        return mediaView;
    } else {
        return [UIView new];
    }
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    if ([self.nativeAdCache.unitGroup.content[@"unit_type"] integerValue] == 0) {
        [self.ADView mainImageView].image = nil;//Image will be drawn on the media view.
        NSDictionary *assets = offer.assets;
        if ([assets.allKeys containsObject:kAdAssetsCustomObjectKey]) {
            id<ATMTGMediaView> mediaView = (id<ATMTGMediaView>)self.ADView.mediaView;
            [mediaView setMediaSourceWithCampaign:assets[kAdAssetsCustomObjectKey] unitId:offer.unitID];
            ATMintegralNativeCustomEvent *customEvent = (ATMintegralNativeCustomEvent*)offer.assets[kATMintegralNativeAssetCustomEvent];
            customEvent.adView = self.ADView;
            customEvent.unitID = offer.unitID;
            self.ADView.customEvent = customEvent;
            mediaView.delegate = customEvent;
            
            if ([[self.ADView clickableViews] count] > 0) {
                id<ATMTGBidNativeAdManager> manager = assets[kMTGAssetsNativeAdManagerKey];
                [manager registerViewForInteraction:(UIView*)self.ADView withClickableViews:[self.ADView clickableViews] withCampaign:assets[kAdAssetsCustomObjectKey]];
            }
        }
    } else {
        ATMintegralNativeCustomEvent *customEvent = (ATMintegralNativeCustomEvent*)offer.assets[kAdAssetsCustomEventKey];
        customEvent.adView = self.ADView;
        customEvent.unitID = offer.unitID;
        self.ADView.customEvent = customEvent;
        UIView *advanceAdView = [((id<ATMTGNativeAdvancedAd>)offer.customObject) fetchAdView];
        advanceAdView.frame = self.ADView.bounds;
        [self.ADView addSubview:advanceAdView];
        
        [[ATNativeADOfferManager sharedManager] removeCahceForPlacementID:offer.placementModel.placementID unitGroupModel:offer.unitGroup];
    }
}

-(BOOL)isVideoContents { return ([self.nativeAdCache.unitGroup.content[@"unit_type"] integerValue] == 1) ? NO : ((id<ATMTGMediaView>)self.ADView.mediaView).isVideoContent; }
@end
