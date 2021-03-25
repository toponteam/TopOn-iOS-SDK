//
//  ATMyOfferRewardedVideoCustomEvent.m
//  AnyThinkMyOfferRewardedVideoAdapter
//
//  Created by Topon on 2019/10/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
#import "ATAgentEvent.h"

@interface ATMyOfferRewardedVideoCustomEvent ()
@property(nonatomic, readonly) BOOL rewarded;

@end
@implementation ATMyOfferRewardedVideoCustomEvent

-(void) myOfferRewardedVideoFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error{
    [self trackRewardedVideoAdPlayEventWithError:error];
}

-(void) myOfferRewardedVideoShowOffer:(ATMyOfferOfferModel*)offer{

}

-(void) myOfferRewardedVideoVideoStartOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:@"MyOfferRewardedVideo::rewardVideoAdStartPlay:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
//    [Utilities reportProfit:self.ad time:self.sdkTime];
}

-(void) myOfferRewardedVideoVideoEndOffer:(ATMyOfferOfferModel*)offer{
    [self trackRewardedVideoAdVideoEnd];
}

-(void) myOfferRewardedVideoClickOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:@"MyOfferRewardedVideo::rewardVideoAdDidClicked:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

-(void) myOfferRewardedVideoCloseOffer:(ATMyOfferOfferModel*)offer{
    [ATLogger logMessage:@"MyOfferRewardedVideo::rewardVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

-(void) myOfferRewardedVideoRewardOffer:(ATMyOfferOfferModel*)offer{
    _rewarded = YES;
    [self trackRewardedVideoAdRewarded];
}

- (void)myOfferRewardedVideoFeedbackViewDidSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offer:(ATMyOfferOfferModel *)offer {
    
//    NSString *imgUrls = [offer.resourceURLs componentsJoinedByString:@","];
    NSMutableDictionary *datas = [NSMutableDictionary dictionaryWithCapacity:0];
    [datas AT_setDictValue:@(offer.offerFirmID) key:kAgentEventExtraInfoNetworkFirmIDKey];
    [datas AT_setDictValue:self.rewardedVideo.unitID key:kAgentEventExtraInfoAdSourceIDKey];
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

    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyFeedbackKey placementID:self.rewardedVideo.placementModel.placementID unitGroupModel:self.rewardedVideo.unitGroup extraInfo:datas];
    offer.feedback = YES;
}

-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer{
    return self.rewardedVideo.requestID;
}

-(NSString*) sceneForOffer:(ATMyOfferOfferModel*)offer {
    return self.rewardedVideo.scene;
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"my_oid"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"my_oid"];
//    return extra;
//}
@end
