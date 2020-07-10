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
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReadyNotification:) name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialReadyNotification : kATOnewayInterstitialImageReadyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleErrorNotification:) name:kATOnewayInterstitialErrorNotification object:nil];
    }
    return self;
}

-(void) handleReadyNotification:(NSNotification*)notification {
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayInterstitialErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialReadyNotification : kATOnewayInterstitialImageReadyNotification object:nil];
}

-(void) handleErrorNotification:(NSNotification*)notification {
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.OnewayInterstitial" code:[notification.userInfo[kATOnewayInterstitialNotificationUserInfoErrorCodeKey] integerValue] userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@", notification.userInfo[kATOnewayInterstitialNotificationUserInfoMessageKey]]}]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayInterstitialErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialReadyNotification : kATOnewayInterstitialImageReadyNotification object:nil];
}

-(void) handleShowNotification:(NSNotification*)notification {
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    
    if ([self.customInfo[@"is_video"] boolValue]) {
        [self trackVideoStart];
        if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) { [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialShowNotification : kATOnewayInterstitialImageShowNotification object:nil];
}

-(void) handleClickNotification:(NSNotification*)notification {
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) { [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

-(void) handleFinishNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATOnewayInterstitialNotificationUserInfoStateKey] integerValue] == 2) {
        if ([self.customInfo[@"is_video"] boolValue]) {
            [self trackVideoEnd];
            if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) { [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialFinishNotification : kATOnewayInterstitialImageFinishNotification object:nil];
}

-(void) handleCloseNotification:(NSNotification*)notification {
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) { [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialClickNotification : kATOnewayInterstitialImageClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialCloseNotification : kATOnewayInterstitialImageCloseNotification object:nil];
}

-(void) showWithTag:(NSString *)tag {
    _tag = tag;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialShowNotification : kATOnewayInterstitialImageShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialClickNotification : kATOnewayInterstitialImageClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishNotification:) name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialFinishNotification : kATOnewayInterstitialImageFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:[self.customInfo[@"is_video"] boolValue] ? kATOnewayInterstitialCloseNotification : kATOnewayInterstitialImageCloseNotification object:nil];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = @"";
    return extra;
}
@end
