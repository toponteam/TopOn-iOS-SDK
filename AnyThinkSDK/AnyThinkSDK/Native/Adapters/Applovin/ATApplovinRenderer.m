//
//  ATApplovinRenderer.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinRenderer.h"
#import "ATNativeADView.h"
#import "ATVideoView.h"
#import "ATApplovinCustomEvent.h"
#import "NSObject+ATCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "ATNativeADCache.h"
#import "ATAPI+Internal.h"
#import "ATPlacementModel.h"
#import "ATApplovinNativeAdapter.h"

@implementation ATApplovinRenderer
-(__kindof UIView*)createMediaView {
    ATVideoView *videoView = [[ATVideoView alloc] initWithFrame:self.ADView.bounds URL:nil];
    videoView.autoPlay = ((ATNativeADCache*)self.ADView.nativeAd).placementModel.wifiAutoSwitch;
    return videoView;
}

-(void) bindCustomEvent {
    ATApplovinCustomEvent *customEvent = [ATApplovinCustomEvent new];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
    ((ATVideoView*)self.ADView.mediaView).delegate = customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    [self bindCustomEvent];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.ADView.customEvent action:@selector(didClickAdView)];
    [self.ADView addGestureRecognizer:recognizer];
    id<ATALNativeAd> nativeAd = offer.assets[kAdAssetsCustomObjectKey];
    ((ATVideoView*)self.ADView.mediaView).URL = nativeAd.videoURL;
    self.ADView.mediaView.hidden = !self.ADView.isVideoContents;
}
@end
