//
//  ATADXRewardedVideoCustomEvent.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
#import "ATADXOfferModel.h"

@interface ATADXRewardedVideoCustomEvent ()
@property(nonatomic, readonly) BOOL rewarded;

@end
@implementation ATADXRewardedVideoCustomEvent

-(void) didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXRewardedVideo::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:self adExtra:@{kAdAssetsPriceKey: _price}];
}

-(void) didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXRewardedVideo::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID unitID:(NSString *)unitID error:(NSError*)error {
      [ATLogger logError:[NSString stringWithFormat:@"ADXRewardedVideo:didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error];
}

-(void) didRewardedVideoFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error {
    [self trackRewardedVideoAdPlayEventWithError:error];
}

-(void) didRewardedVideoShowOffer:(ATADXOfferModel*)offer {
    
}

-(void) didRewardedVideoVideoStartOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXRewardedVideo::atADXRewardedVideoVideoStartOffer:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

-(void) didRewardedVideoVideoEndOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXRewardedVideo::atADXRewardedVideoVideoEndOffer:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
}

-(void) didRewardedVideoClickOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXRewardedVideo::atADXRewardedVideoClickOffer:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

-(void) didRewardedVideoCloseOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXRewardedVideo::atADXRewardedVideoCloseOffer:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

-(void) didRewardedVideoRewardOffer:(ATADXOfferModel*)offer {
    _rewarded = YES;
    [self trackRewardedVideoAdRewarded];
}

-(NSString*) lifeCircleIDForOffer:(ATADXOfferModel*)offer {
    return self.rewardedVideo.requestID;
}

-(NSString*) sceneForOffer:(ATADXOfferModel*)offer {
    return self.rewardedVideo.scene;
}

- (NSString *)networkUnitId {
    return self.unitGroupModel.unitID;
}

@end
