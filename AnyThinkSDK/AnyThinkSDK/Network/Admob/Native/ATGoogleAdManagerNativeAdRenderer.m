//
//  ATGoogleAdManagerNativeAdRender.m
//  AnyThinkSDK
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerNativeADRenderer.h"
#import "NSObject+ATCustomEvent.h"
#import "ATGoogleAdManagerNativeCustomEvent.h"
#import "ATNativeADView.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATAPI+Internal.h"
#import "ATTracker.h"
#import "ATPlacementModel.h"
#import "ATGoogleAdManagerNativeAdapter.h"
#import "ATNativeADView+Internal.h"

@interface ATGoogleAdManagerNativeAdRenderer()
@property(nonatomic, readonly) ATGoogleAdManagerNativeCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADUnifiedNativeAd> nativeAd;
@end
@implementation ATGoogleAdManagerNativeAdRenderer
-(__kindof UIView*)createMediaView {
    [self bindCustomEvent];
    return [NSClassFromString(@"GADMediaView") new];
}

-(void) bindCustomEvent {
    ATNativeADCache *offer = (ATNativeADCache*)self.ADView.nativeAd;
    _customEvent = [ATGoogleAdManagerNativeCustomEvent new];
    _customEvent.unitID = offer.unitID;
    
    _customEvent.adView = self.ADView;
    self.ADView.customEvent = _customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    id<ATGADUnifiedNativeAd> nativeAD = offer.assets[kAdAssetsCustomObjectKey];
    _nativeAd = nativeAD;
    
    _nativeAd.videoController.delegate = _customEvent;
    
    nativeAD.delegate = _customEvent;
    
    self.ADView.mainImageView.image = nil;
}

-(BOOL)isVideoContents {
    return _nativeAd.videoController.hasVideoContent;
}
@end
