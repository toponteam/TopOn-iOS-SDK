//
//  ATIronSourceRewardedVideoCustomEvent.m
//  AnyThinkIronSourceRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATIronSourceRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "Utilities.h"

@interface ATIronSourceRewardedVideoCustomEvent()
@end
@implementation ATIronSourceRewardedVideoCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoaded:) name:kATIronSourceRVNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShow:) name:kATIronSourceRVNotificationShow object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadFailed:) name:kATIronSourceRVNotificationLoadFailed object:nil];
    }
    return self;
}

-(void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClose:) name:kATIronSourceRVNotificationClose object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClick:) name:kATIronSourceRVNotificationClick object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReward:) name:kATIronSourceRVNotificationReward object:nil];
}
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) handleLoaded:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID]) {
        [self trackRewardedVideoAdLoaded:self.unitID != nil ? self.unitID : @"" adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationLoadFailed object:nil];
    }
}

-(void) handleLoadFailed:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID]) {
        NSError *error = notification.userInfo[kATIronSourceRVNotificationUserInfoErrorKey];
        [self trackRewardedVideoAdLoadFailed:error];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationLoadFailed object:nil];
    }
}

-(void) handleShowFailed:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        NSError *error = notification.userInfo[kATIronSourceRVNotificationUserInfoErrorKey];
        [self trackRewardedVideoAdPlayEventWithError:error];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationShow object:nil];
    }
}

-(void) handleShow:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackRewardedVideoAdShow];
        [self trackRewardedVideoAdVideoStart];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationShow object:nil];
    }
}

-(void) handleClick:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackRewardedVideoAdClick];
    }
}

-(void) handleClose:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackRewardedVideoAdVideoEnd];
        [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationClose object:nil];
    }
}

-(void) handleReward:(NSNotification*)notification {
    [self trackRewardedVideoAdRewarded];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationReward object:nil];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"instance_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"instance_id"];
//    return extra;
//}
@end
