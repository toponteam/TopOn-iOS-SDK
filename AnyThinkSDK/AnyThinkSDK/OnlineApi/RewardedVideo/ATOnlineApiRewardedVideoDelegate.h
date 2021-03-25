//
//  ATOnlineApiRewardedVideoDelegate.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATOnlineApiRewardedVideoDelegate_h
#define ATOnlineApiRewardedVideoDelegate_h

@class ATOnlineApiOfferModel;
@protocol ATOnlineApiRewardedVideoDelegate<NSObject>
- (void)didRewardedVideoFailToShowOffer:(ATOnlineApiOfferModel *)offer error:(NSError *)error;
- (void)didRewardedVideoShowOffer:(ATOnlineApiOfferModel *)offer;
- (void)didRewardedVideoVideoStartOffer:(ATOnlineApiOfferModel *)offer;
- (void)didRewardedVideoVideoEndOffer:(ATOnlineApiOfferModel *)offer;
- (void)didRewardedVideoClickOffer:(ATOnlineApiOfferModel *)offer;
- (void)didRewardedVideoCloseOffer:(ATOnlineApiOfferModel *)offer;
- (void)didRewardedVideoRewardOffer:(ATOnlineApiOfferModel *)offer;
- (void)didRewardedVideoDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer;
- (void)didRewardedVideoFeedbackViewSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offer:(ATOnlineApiOfferModel *)offer;

- (NSString *)lifeCircleIDForOffer:(ATOnlineApiOfferModel *)offer;
- (NSString *)sceneForOffer:(ATOnlineApiOfferModel *)offer;
@end

#endif /* ATOnlineApiRewardedVideoDelegate_h */
