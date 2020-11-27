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

@implementation ATADXInterstitialCustomEvent

-(void) didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXInterstitial::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:self adExtra:@{kAdAssetsPriceKey:_price}];
}

-(void) didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXInterstitial::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID unitID:(NSString *)unitID error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"ADXInterstitial:didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

-(void) didInterstitialFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"ADXInterstitial:didInterstitialFailToShowOffer::error:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:error];
}

-(void) didInterstitialShowOffer:(ATADXOfferModel*)offer {
    [ATLogger logError:@"ADXInterstitial:didInterstitialShowOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

-(void) didInterstitialVideoStartOffer:(ATADXOfferModel*)offer {
    [ATLogger logError:@"ADXInterstitial:didInterstitialVideoStartOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoStart];
}

-(void) didInterstitialVideoEndOffer:(ATADXOfferModel*)offer {
    [ATLogger logError:@"ADXInterstitial:didInterstitialVideoEndOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

-(void) didInterstitialClickOffer:(ATADXOfferModel*)offer {
    [ATLogger logError:@"ADXInterstitial:didInterstitialClickOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

-(void) didInterstitialCloseOffer:(ATADXOfferModel*)offer {
    [ATLogger logError:@"ADXInterstitial:didInterstitialCloseOffer:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
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

@end
