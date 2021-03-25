//
//  ATKSSplashCustomEvent.m
//  AnyThinkKuaiShouAdapter
//
//  Created by Topon on 11/20/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKSSplashCustomEvent.h"
#import "Utilities.h"

@implementation ATKSSplashCustomEvent

#pragma mark - KSAdSplashInteractDelegate
- (void)ksad_splashAdDismiss:(BOOL)converted {
    [ATLogger logMessage:[NSString stringWithFormat:@"KSSplash::ksad_splashAdDismiss:%d",converted] type:ATLogTypeExternal];
    [_window.rootViewController dismissViewControllerAnimated:!converted completion:nil];
    [self trackSplashAdClosed];
}

- (void)ksad_splashAdVideoDidSkipped:(NSTimeInterval)playDuration {
    [ATLogger logMessage:[NSString stringWithFormat:@"KSSplash::ksad_splashAdVideoDidSkipped:%f",playDuration] type:ATLogTypeExternal];
}

- (void)ksad_splashAdClicked {
    [ATLogger logMessage:@"KSSplash::ksad_splashAdClicked:" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

- (void)ksad_splashAdDidShow {
    [ATLogger logMessage:@"KSSplash::ksad_splashAdDidShow:" type:ATLogTypeExternal];
    [self trackSplashAdShow];
}

- (void)ksad_splashAdVideoDidStartPlay {
    [ATLogger logMessage:@"KSSplash::ksad_splashAdVideoDidStartPlay:" type:ATLogTypeExternal];
}

- (void)ksad_splashAdVideoFailedToPlay:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"KSSplash::ksad_splashAdVideoFailedToPlay:%@",error] type:ATLogTypeExternal];
}

- (UIViewController *)ksad_splashAdConversionRootVC {
    return _window.rootViewController;
}

@end
