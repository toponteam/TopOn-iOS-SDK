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
