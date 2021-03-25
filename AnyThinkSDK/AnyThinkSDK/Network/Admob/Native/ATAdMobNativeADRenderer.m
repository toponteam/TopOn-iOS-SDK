//
//  ATAdMobNativeADRenderer.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 26/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdMobNativeADRenderer.h"
#import "NSObject+ATCustomEvent.h"
#import "ATAdMobCustomEvent.h"
#import "ATNativeADView.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATAPI+Internal.h"
#import "ATTracker.h"
#import "ATPlacementModel.h"
#import "ATAdmobNativeAdapter.h"
#import "ATNativeADView+Internal.h"

@interface ATAdMobNativeADRenderer()
@property(nonatomic, readonly) ATAdMobCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADUnifiedNativeAd> nativeAd;
@end
@implementation ATAdMobNativeADRenderer
-(__kindof UIView*)createMediaView {
    [self bindCustomEvent];
    return [NSClassFromString(@"GADMediaView") new];
}

-(void) bindCustomEvent {
    ATNativeADCache *offer = (ATNativeADCache*)self.ADView.nativeAd;
    _customEvent = [ATAdMobCustomEvent new];
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
