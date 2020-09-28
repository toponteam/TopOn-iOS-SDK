//
//  ATOnewayRewardedVideoCustomEvent.m
//  AnyThinkOnewayRewardedVideoAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATOnewayRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import <objc/runtime.h>
#import "ATRewardedVideoManager.h"
#import "ATAdAdapter.h"

@implementation ATOnewayRewardedVideoCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReadyNotification:) name:kATOnewayRVReadyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleErrorNotification:) name:kATOnewayRVErrorNotification object:nil];
    }
    return self;
}

-(void) handleErrorNotification:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVReadyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVErrorNotification object:nil];
}

-(void) handleReadyNotification:(NSNotification*)notification {
    [self trackRewardedVideoAdLoaded:self adExtra:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVReadyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVErrorNotification object:nil];
}

-(void) handleShowNotification:(NSNotification*)notification {
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVShowNotification object:nil];
}

-(void) handleClickNotification:(NSNotification*)notification {
    [self trackRewardedVideoAdClick];
}

-(void) handleCloseNotification:(NSNotification*)notification {
    NSNumber *state = notification.userInfo[kATOnewayRVNotificationUserInfoStateKey];
    self.rewardGranted = [state integerValue] == 2;
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
    if (self.rewardGranted) {
        [self trackRewardedVideoAdRewarded];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVCloseNotification object:nil];
}

-(void) handleFinishNotification:(NSNotification*)notification {
    NSNumber *state = notification.userInfo[kATOnewayRVNotificationUserInfoStateKey];
    if ([state integerValue] == 2) {
        [self trackRewardedVideoAdVideoEnd];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVFinishNotification object:nil];
}

-(void) showWithTag:(NSString*)tag {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kATOnewayRVShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kATOnewayRVClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kATOnewayRVCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishNotification:) name:kATOnewayRVFinishNotification object:nil];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = @"";
//    return extra;
//}
@end
