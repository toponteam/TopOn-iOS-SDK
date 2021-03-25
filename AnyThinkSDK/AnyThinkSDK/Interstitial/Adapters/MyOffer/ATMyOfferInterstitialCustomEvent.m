//
//  ATMyOfferInterstitialCustomEvent.m
//  AnyThinkMyOfferInterstitialAdapter
//
//  Created by Topon on 2019/10/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAgentEvent.h"

@implementation ATMyOfferInterstitialCustomEvent

-(void) myOfferIntersititalFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error{
    [ATLogger logMessage:[NSString stringWithFormat:@"MyOfferInterstitial: fullscreenVideoAdDidFailToShow"]  type:ATLogTypeExternal];

    [self trackInterstitialAdDidFailToPlayVideo:error];
}

-(void) myOfferIntersititalShowOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:[NSString stringWithFormat:@"MyOfferInterstitial: fullscreenVideoAdDidShow"]  type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
//    [Utilities reportProfit:self.interstitial time:self.sdkTime];
}

-(void) myOfferInterstitialVideoStartOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:[NSString stringWithFormat:@"MyOfferInterstitial: fullscreenVideoAdStartPlay"]  type:ATLogTypeExternal];
    [self trackInterstitialAdVideoStart];
}

-(void) myOfferInterstitialVideoEndOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:[NSString stringWithFormat:@"MyOfferInterstitial: fullscreenVideoPlayEnd"]  type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

-(void) myOfferInterstitialClickOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:@"MyOfferInterstitial::fullscreenVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

-(void) myOfferInterstitialCloseOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:@"MyOfferInterstitial::fullscreenVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)myOfferInterstitialFeedbackViewDidSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offer:(ATMyOfferOfferModel *)offer {
    
    
//    NSString *imgUrls = [offer.image componentsJoinedByString:@","];
    NSMutableDictionary *datas = [NSMutableDictionary dictionaryWithCapacity:0];
    [datas AT_setDictValue:@(offer.offerFirmID) key:kAgentEventExtraInfoNetworkFirmIDKey];
    [datas AT_setDictValue:self.interstitial.unitID key:kAgentEventExtraInfoAdSourceIDKey];
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
//    [datas AT_setDictValue:imgUrls key:kAgentEventExtraInfoOfferImageUrls];

    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyFeedbackKey placementID:self.interstitial.placementModel.placementID unitGroupModel:self.interstitial.unitGroup extraInfo:datas];
    offer.feedback = YES;
}

-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer{
    return self.interstitial.requestID;
}

-(NSString*) sceneForOffer:(ATMyOfferOfferModel*)offer {
    return self.interstitial.scene;
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"my_oid"];
}
//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"my_oid"];
//    return extra;
//}
@end
