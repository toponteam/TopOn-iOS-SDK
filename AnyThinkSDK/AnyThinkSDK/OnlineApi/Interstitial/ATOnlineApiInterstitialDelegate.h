//
//  ATOnlineApiInterstitialDelegate.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATOnlineApiInterstitialDelegate_h
#define ATOnlineApiInterstitialDelegate_h
@class ATOnlineApiOfferModel;
@protocol ATOnlineApiInterstitialDelegate<NSObject>
- (void)didInterstitialFailToShowOffer:(ATOnlineApiOfferModel*)offer error:(NSError*)error;
- (void)didInterstitialShowOffer:(ATOnlineApiOfferModel*)offer;
- (void)didInterstitialVideoStartOffer:(ATOnlineApiOfferModel*)offer;
- (void)didInterstitialVideoEndOffer:(ATOnlineApiOfferModel*)offer;
- (void)didInterstitialClickOffer:(ATOnlineApiOfferModel*)offer;
- (void)didInterstitialCloseOffer:(ATOnlineApiOfferModel*)offer;
- (void)didIntersititalDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer;
- (void)didIntersititalFeedbackViewSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offer:(ATOnlineApiOfferModel *)offer;

- (NSString *)lifeCircleIDForOffer:(ATOnlineApiOfferModel*)offer;
- (NSString *)sceneForOffer:(ATOnlineApiOfferModel*)offer;
@end
#endif /* ATOnlineApiInterstitialDelegate_h */
