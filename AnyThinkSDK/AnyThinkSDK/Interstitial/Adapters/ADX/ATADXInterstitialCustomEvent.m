//
//  ATADXInterstitialCustomEvent.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATADXOfferModel.h"
#import "ATBidInfoManager.h"
#import "ATADXLoader.h"
#import "ATAgentEvent.h"

@implementation ATADXInterstitialCustomEvent

-(void) didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXInterstitial::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    self.offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:self.placementModel.placementID unitGroupModel:self.unitGroupModel];
    [self trackInterstitialAdLoaded:self adExtra:@{kAdAssetsPriceKey:_price, kAdAssetsBidIDKey:_bidId}];
}

-(void) didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXInterstitial::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID unitID:(NSString *)unitID error:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXInterstitial:didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

-(void) didInterstitialFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXInterstitial:didInterstitialFailToShowOffer::error:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:error];
}

-(void) didInterstitialShowOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXInterstitial:didInterstitialShowOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
//    [Utilities reportProfit:self.ad time:self.sdkTime];
    [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:self.placementModel.placementID unitGroupModel:self.unitGroupModel requestID:self.requestID];
}

-(void) didInterstitialVideoStartOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXInterstitial:didInterstitialVideoStartOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoStart];
}

-(void) didInterstitialVideoEndOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXInterstitial:didInterstitialVideoEndOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

-(void) didInterstitialClickOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXInterstitial:didInterstitialClickOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

-(void) didInterstitialCloseOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXInterstitial:didInterstitialCloseOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)didIntersititalDeepLinkOrJumpResult:(BOOL)success offer:(ATADXOfferModel *)offer {
    [ATLogger logMessage:@"ADXInterstitial:didIntersititalDeepLinkOrJumpResult:" type:ATLogTypeExternal];
    [self trackInterstitialAdDeeplinkOrJumpResult:success];
}

- (void)didIntersititalFeedbackViewSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offer:(ATADXOfferModel *)offer {
    
    [ATLogger logMessage:@"ADXInterstitial:didIntersititalFeedbackViewSelectItemAtIndex:" type:ATLogTypeExternal];

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

-(NSString*) lifeCircleIDForOffer:(ATADXOfferModel*)offer {
    return self.interstitial.requestID;
}

-(NSString*) sceneForOffer:(ATADXOfferModel*)offer {
    return self.interstitial.scene;
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
