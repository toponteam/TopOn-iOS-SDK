//
//  ATOnlineApiInterstitialCustomEvent.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiInterstitialCustomEvent.h"
#import "ATLogger.h"
#import "ATInterstitialManager.h"
#import "NSString+KAKit.h"
#import "ATOnlineApiOfferModel.h"
#import "ATOnlineApiLoader.h"
#import "Utilities.h"
#import "ATAgentEvent.h"

@implementation ATOnlineApiInterstitialCustomEvent

- (void)didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiInterstitialCustomEvent::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    self.offerModel = [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:self.unitGroupModel.unitID placementID:placementID];
    [self trackInterstitialAdLoaded:self adExtra:nil];
}

- (void)didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiInterstitialCustomEvent::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID unitID:(NSString *)unitID error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"ATOnlineApiInterstitialCustomEvent:didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

-(void) didInterstitialFailToShowOffer:(ATOnlineApiOfferModel*)offer error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"ATOnlineApiInterstitialCustomEvent:didInterstitialFailToShowOffer::error:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:error];
}

-(void) didInterstitialShowOffer:(ATOnlineApiOfferModel*)offer {
    [ATLogger logError:@"ATOnlineApiInterstitialCustomEvent:didInterstitialShowOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
    [[ATOnlineApiLoader sharedLoader] recordShownAdWithOfferID:offer.offerID unitID:offer.unitID];
//    [Utilities reportProfit:self.ad time:self.sdkTime];
    [[ATOnlineApiLoader sharedLoader] removeOfferModel:offer];

}

-(void) didInterstitialVideoStartOffer:(ATOnlineApiOfferModel*)offer {
    [ATLogger logError:@"ATOnlineApiInterstitialCustomEvent:didInterstitialVideoStartOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoStart];
}

-(void) didInterstitialVideoEndOffer:(ATOnlineApiOfferModel*)offer {
    [ATLogger logError:@"ATOnlineApiInterstitialCustomEvent:didInterstitialVideoEndOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

-(void) didInterstitialClickOffer:(ATOnlineApiOfferModel*)offer {
    [ATLogger logError:@"ATOnlineApiInterstitialCustomEvent:didInterstitialClickOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

-(void) didInterstitialCloseOffer:(ATOnlineApiOfferModel*)offer {
    [ATLogger logError:@"ATOnlineApiInterstitialCustomEvent:didInterstitialCloseOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)didIntersititalDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logError:@"ATOnlineApiInterstitialCustomEvent:didIntersititalDeepLinkOrJumpResult:" type:ATLogTypeExternal];

    [self trackInterstitialAdDeeplinkOrJumpResult:success];
}

- (void)didIntersititalFeedbackViewSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logError:@"ATOnlineApiInterstitialCustomEvent:didIntersititalFeedbackViewSelectItemAtIndex:" type:ATLogTypeExternal];
    
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

    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyFeedbackKey placementID:self.interstitial.placementModel.placementID unitGroupModel:self.interstitial.placementModel.placementID extraInfo:datas];
    offer.feedback = YES;
}

-(NSString*) lifeCircleIDForOffer:(ATOnlineApiOfferModel*)offer {
    return self.interstitial.requestID;
}

-(NSString*) sceneForOffer:(ATOnlineApiOfferModel*)offer {
    return self.interstitial.scene ? self.interstitial.scene : @"";
}

- (NSString *)networkUnitId {
    return _unitGroupModel.unitID;
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
