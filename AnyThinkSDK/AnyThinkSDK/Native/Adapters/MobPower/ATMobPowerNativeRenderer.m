//
//  ATMobPowerNativeRenderer.m
//  AnyThinkMobPowerNativeAdapter
//
//  Created by Martin Lau on 2018/12/24.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMobPowerNativeRenderer.h"
#import "NSObject+ATCustomEvent.h"
#import "ATNativeADView.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADCache.h"
#import "ATAPI+Internal.h"
#import "ATTracker.h"
#import "ATPlacementModel.h"
#import "ATMobPowerNativeAdapter.h"
#import "ATNativeADView+Internal.h"
#import "ATAdManagement.h"
#import "ATMobPowerNativeCustomEvent.h"
@interface ATMobPowerNativeRenderer()
@property(nonatomic, readonly, weak) ATMobPowerNativeCustomEvent *customEvent;
@end
@implementation ATMobPowerNativeRenderer
-(__kindof UIView*)createMediaView {
    [self bindCustomEvent];
    return [UIView new];
}

-(void) bindCustomEvent {
    ATNativeADCache *offer = (ATNativeADCache*)self.ADView.nativeAd;
    _customEvent = offer.assets[kAdAssetsCustomEventKey];
    _customEvent.unitID = offer.unitID;
    
    _customEvent.adView = self.ADView;
    self.ADView.customEvent = _customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    id<ATMPNative> nativeAD = offer.assets[kNativeADAssetsNetworkCustomObjectKey];
    nativeAD.delegate = offer.assets[kAdAssetsCustomEventKey];
    
    [nativeAD registerViewForInteraction:self.ADView withViewController:[UIApplication sharedApplication].delegate.window.rootViewController withClickableViews:[self.ADView clickableViews]];
}

-(BOOL)isVideoContents {
    return NO;
}
@end
