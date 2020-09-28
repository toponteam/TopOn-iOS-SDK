//
//  ATIronSourceInterstitialCustomEvent.m
//  AnyThinkIronSourceInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATIronSourceInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"


@implementation ATIronSourceInterstitialCustomEvent
-(instancetype) initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoaded:) name:kATIronSourceInterstitialNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShow:) name:kATIronSourceInterstitialNotificationShow object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadFailed:) name:kATIronSourceInterstitialNotificationLoadFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClose:) name:kATIronSourceInterstitialNotificationClose object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClick:) name:kATIronSourceInterstitialNotificationClick object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) handleLoaded:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID]) {
//        [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:self.unitID != nil ? self.unitID : @""}];
        [self trackInterstitialAdLoaded:self.networkUnitId adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceInterstitialNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceInterstitialNotificationLoadFailed object:nil];
    }
}

-(void) handleLoadFailed:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID]) {
        NSError *error = notification.userInfo[kATIronSourceInterstitialNotificationUserInfoError];
        [self trackInterstitialAdLoadFailed:error != nil ? error : [NSError errorWithDomain:@"com.anythink.IronSourceInterstitialLoading" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial", NSLocalizedFailureReasonErrorKey:@"IronSource has failed to load interstitial"}]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceInterstitialNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceInterstitialNotificationLoadFailed object:nil];
    }
}

-(void) handleShow:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackInterstitialAdShow];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceInterstitialNotificationShow object:nil];
    }
}

-(void) handleClick:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackInterstitialAdClick];
    }
}

-(void) handleClose:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackInterstitialAdClose];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceInterstitialNotificationClose object:nil];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"instance_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"instance_id"];
//    return extra;
//}
@end
