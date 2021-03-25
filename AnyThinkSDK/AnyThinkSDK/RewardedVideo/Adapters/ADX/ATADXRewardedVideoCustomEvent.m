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
#import "ATBidInfoManager.h"
#import "ATADXLoader.h"
#import "ATAgentEvent.h"

@interface ATADXRewardedVideoCustomEvent ()
@property(nonatomic, readonly) BOOL rewarded;

@end
@implementation ATADXRewardedVideoCustomEvent

-(void) didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXRewardedVideo::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    self.offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:self.placementModel.placementID unitGroupModel:self.unitGroupModel];
    [self trackRewardedVideoAdLoaded:self adExtra:@{kAdAssetsPriceKey: _price, kAdAssetsBidIDKey:_bidId}];
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
    [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:self.placementModel.placementID unitGroupModel:self.unitGroupModel requestID:self.requestID];

//    [Utilities reportProfit:self.ad time:self.sdkTime];
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

- (void)didRewardedVideoDeepLinkOrJumpResult:(BOOL)success offer:(ATADXOfferModel *)offer {
    [ATLogger logMessage:@"ADXRewardedVideo::didRewardedVideoDeepLinkOrJumpResult:" type:ATLogTypeExternal];

    [self trackRewardedVideoAdDeeplinkOrJumpResult:success];
}

- (void)didRewardedVideoFeedbackViewSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offer:(ATADXOfferModel *)offer {
    [ATLogger logMessage:@"ADXRewardedVideo::didRewardedVideoFeedbackViewSelectItemAtIndex:" type:ATLogTypeExternal];
  
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

-(NSString*) lifeCircleIDForOffer:(ATADXOfferModel*)offer {
    return self.rewardedVideo.requestID;
}

-(NSString*) sceneForOffer:(ATADXOfferModel*)offer {
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
