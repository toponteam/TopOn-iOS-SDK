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

    [self trackInterstitialAdDidFailToPlayVideo:error];
}

-(void) myOfferIntersititalShowOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:[NSString stringWithFormat:@"MyOfferInterstitial: fullscreenVideoAdDidShow"]  type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
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
