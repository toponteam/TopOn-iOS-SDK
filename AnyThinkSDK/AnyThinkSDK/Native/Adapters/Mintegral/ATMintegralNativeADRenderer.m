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

@interface ATMintegralNativeADRenderer()
@property(nonatomic, weak) ATNativeADView *ADView_impl;
@end
@implementation ATMintegralNativeADRenderer
-(__kindof UIView*)createMediaView {
    UIView *mediaView = [[NSClassFromString(@"MTGMediaView") alloc] init];
    if (mediaView == nil) [ATLogger logError:@"Can't find MTGMediaView." type:ATLogTypeExternal];
    return mediaView;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
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
}

-(BOOL)isVideoContents {
    return ((id<ATMTGMediaView>)self.ADView.mediaView).isVideoContent;
}
@end
