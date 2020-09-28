//
//  ATOnewayInterstitialCustomEvent.m
//  AnyThinkOnewayInterstitialAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATOnewayInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAdAdapter.h"

@interface ATOnewayInterstitialCustomEvent()
@property(nonatomic, readonly) NSString *tag;
@end
@implementation ATOnewayInterstitialCustomEvent
-(instancetype) initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReadyNotification:) name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialReadyNotification : kATOnewayInterstitialImageReadyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleErrorNotification:) name:kATOnewayInterstitialErrorNotification object:nil];
    }
    return self;
}

-(void) handleReadyNotification:(NSNotification*)notification {
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
    [self trackInterstitialAdLoaded:nil adExtra:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayInterstitialErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialReadyNotification : kATOnewayInterstitialImageReadyNotification object:nil];
}

-(void) handleErrorNotification:(NSNotification*)notification {
    [self trackInterstitialAdLoadFailed:[NSError errorWithDomain:@"com.anythink.OnewayInterstitial" code:[notification.userInfo[kATOnewayInterstitialNotificationUserInfoErrorCodeKey] integerValue] userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@", notification.userInfo[kATOnewayInterstitialNotificationUserInfoMessageKey]]}]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayInterstitialErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialReadyNotification : kATOnewayInterstitialImageReadyNotification object:nil];
}

-(void) handleShowNotification:(NSNotification*)notification {
    [self trackInterstitialAdShow];
    
    if ([self.serverInfo[@"is_video"] boolValue]) {
        [self trackInterstitialAdVideoStart];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialShowNotification : kATOnewayInterstitialImageShowNotification object:nil];
}

-(void) handleClickNotification:(NSNotification*)notification {
    [self trackInterstitialAdClick];
}

-(void) handleFinishNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATOnewayInterstitialNotificationUserInfoStateKey] integerValue] == 2) {
        if ([self.serverInfo[@"is_video"] boolValue]) {
            [self trackInterstitialAdVideoEnd];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialFinishNotification : kATOnewayInterstitialImageFinishNotification object:nil];
}

-(void) handleCloseNotification:(NSNotification*)notification {
    [self trackInterstitialAdClose];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialClickNotification : kATOnewayInterstitialImageClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialCloseNotification : kATOnewayInterstitialImageCloseNotification object:nil];
}

-(void) showWithTag:(NSString *)tag {
    _tag = tag;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialShowNotification : kATOnewayInterstitialImageShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialClickNotification : kATOnewayInterstitialImageClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishNotification:) name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialFinishNotification : kATOnewayInterstitialImageFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:[self.serverInfo[@"is_video"] boolValue] ? kATOnewayInterstitialCloseNotification : kATOnewayInterstitialImageCloseNotification object:nil];
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
