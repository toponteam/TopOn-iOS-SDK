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

@implementation ATMyOfferInterstitialCustomEvent

-(void) myOfferIntersititalFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error{
    [ATLogger logMessage:[NSString stringWithFormat:@"MyOfferInterstitial: fullscreenVideoAdDidFailToShow"]  type:ATLogTypeExternal];

    if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) {
        [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]];
    }
}

-(void) myOfferIntersititalShowOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:[NSString stringWithFormat:@"MyOfferInterstitial: fullscreenVideoAdDidShow"]  type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

-(void) myOfferInterstitialVideoStartOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:[NSString stringWithFormat:@"MyOfferInterstitial: fullscreenVideoAdStartPlay"]  type:ATLogTypeExternal];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(void) myOfferInterstitialVideoEndOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:[NSString stringWithFormat:@"MyOfferInterstitial: fullscreenVideoPlayEnd"]  type:ATLogTypeExternal];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(void) myOfferInterstitialClickOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:@"MyOfferInterstitial::fullscreenVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(void) myOfferInterstitialCloseOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:@"MyOfferInterstitial::fullscreenVideoAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer{
    return self.interstitial.requestID;
}

-(NSString*) sceneForOffer:(ATMyOfferOfferModel*)offer {
    return self.interstitial.scene;
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"my_oid"];
    return extra;
}
@end
