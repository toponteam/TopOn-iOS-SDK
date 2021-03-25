//
//  ATOnlineApiRewardedVideoCustomEvent.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "NSString+KAKit.h"
#import "ATLogger.h"
#import "ATOnlineApiLoader.h"
#import "ATOnlineApiOfferModel.h"
#import "Utilities.h"
#import "ATAgentEvent.h"

@interface ATOnlineApiRewardedVideoCustomEvent ()<ATOnlineApiLoadingDelegate>
@property(nonatomic, readonly) BOOL rewarded;

@end

@implementation ATOnlineApiRewardedVideoCustomEvent

// MARK:- ATOnlineApiLoadingDelegate
- (void)didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiRewardedVideoCustomEvent::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    self.offerModel = [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:self.unitGroupModel.unitID placementID:self.placementModel.placementID];
    [self trackRewardedVideoAdLoaded:self adExtra:nil];
}

- (void)didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiRewardedVideoCustomEvent::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock) {
        self.customEventMetaDataDidLoadedBlock();
    }
}

- (void)didFailToLoadADWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID error:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiRewardedVideoCustomEvent::didFailToLoadADWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    
    [self trackRewardedVideoAdLoadFailed:error];
}

// MARK:- ATOnlineApiRewardedVideoDelegate
- (void)didRewardedVideoClickOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideoCustomEvent::didRewardedVideoClickOffer:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)didRewardedVideoCloseOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideoCustomEvent::didRewardedVideoCloseOffer:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

- (void)didRewardedVideoFailToShowOffer:(ATOnlineApiOfferModel *)offer error:(NSError *)error {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideoCustomEvent::didRewardedVideoFailToShowOffer:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

- (void)didRewardedVideoRewardOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideoCustomEvent::didRewardedVideoRewardOffer:" type:ATLogTypeExternal];
    _rewarded = YES;
    [self trackRewardedVideoAdRewarded];
}

- (void)didRewardedVideoDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideoCustomEvent::didRewardedVideoDeepLinkOrJumpResult:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdDeeplinkOrJumpResult:success];
}
- (void)didRewardedVideoShowOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideoCustomEvent::didRewardedVideoShowOffer:" type:ATLogTypeExternal];
    [[ATOnlineApiLoader sharedLoader] recordShownAdWithOfferID:offer.offerID unitID:offer.unitID];
//    [Utilities reportProfit:self.ad time:self.sdkTime];
    [[ATOnlineApiLoader sharedLoader] removeOfferModel:offer];
}

- (void)didRewardedVideoVideoEndOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideoCustomEvent::didRewardedVideoVideoEndOffer:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
}

- (void)didRewardedVideoVideoStartOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideoCustomEvent::didRewardedVideoVideoStartOffer:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)didRewardedVideoFeedbackViewSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideoCustomEvent::didRewardedVideoFeedbackViewSelectItemAtIndex:" type:ATLogTypeExternal];
    
    NSString *imgUrls = [offer.imageList componentsJoinedByString:@","];
    NSMutableDictionary *datas = [NSMutableDictionary dictionaryWithCapacity:0];
    [datas AT_setDictValue:@(offer.offerFirmID) key:kAgentEventExtraInfoNetworkFirmIDKey];
    [datas AT_setDictValue:offer.unitID key:kAgentEventExtraInfoAdSourceIDKey];
    [datas AT_setDictValue:@(offer.offerModelType) key:kAgentEventExtraInfoAdTypeKey];
    [datas AT_setDictValue:@(index) key:kAgentEventExtraInfoFeedbackType];
    [datas AT_setDictValue:msg key:kAgentEventExtraInfoFeedbackAdvice];
    [datas AT_setDictValue:offer.offerID key:kAgentEventExtraInfoMyOfferOfferIDKey];
    [datas AT_setDictValue:offer.pkgName key:kAgentEventExtraInfoBundleInfo];
    [datas AT_setDictValue:offer.title key:kAgentEventExtraInfoOfferTitle];
    [datas AT_setDictValue:offer.text key:kAgentEventExtraInfoOfferContent];
    [datas AT_setDictValue:offer.iconURL key:kAgentEventExtraInfoOfferIconUrl];
    [datas AT_setDictValue:offer.fullScreenImageURL key:kAgentEventExtraInfoOfferFullImageUrl];
    [datas AT_setDictValue:offer.videoURL key:kAgentEventExtraInfoOfferVideoUrl];
    [datas AT_setDictValue:imgUrls key:kAgentEventExtraInfoOfferImageUrls];

    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyFeedbackKey placementID:self.rewardedVideo.placementModel.placementID unitGroupModel:self.rewardedVideo.unitGroup extraInfo:datas];
    offer.feedback = YES;
}

- (NSString *)lifeCircleIDForOffer:(ATOnlineApiOfferModel *)offer {
    return self.rewardedVideo.requestID;
}

- (NSString *)sceneForOffer:(ATOnlineApiOfferModel *)offer {
    return self.rewardedVideo.scene;
}

- (NSString *)networkUnitId {
    return self.unitGroupModel.unitID;
}

- (NSDictionary *)networkCustomInfo {
    if (self.offerModel != nil) {
        BOOL isDeepLink = NO;
        if ([Utilities isEmpty:self.offerModel.deeplinkUrl] == NO || [Utilities isEmpty:self.offerModel.jumpUrl] == NO) {
            isDeepLink = YES;
        }
        NSDictionary *extInfo = @{kATADDelegateExtraOfferIDKey:self.offerModel.offerID != nil ? self.offerModel.offerID : @"", kATADDelegateExtraCreativeIDKey:self.offerModel.resourceID != nil ? self.offerModel.resourceID : @"", kATADDelegateExtraIsDeeplinkKey:@(isDeepLink)};
        return extInfo;
    }else {
        return nil;
    }
}

@end
