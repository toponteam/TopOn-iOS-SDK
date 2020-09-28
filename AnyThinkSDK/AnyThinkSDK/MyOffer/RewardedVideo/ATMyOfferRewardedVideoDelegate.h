//
//  ATMyOfferRewardedVideoDelegate.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#ifndef ATMyOfferRewardedVideoDelegate_h
#define ATMyOfferRewardedVideoDelegate_h
@class ATMyOfferOfferModel;
@protocol ATMyOfferRewardedVideoDelegate<NSObject>
-(void) myOfferRewardedVideoFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error;
-(void) myOfferRewardedVideoShowOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoVideoStartOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoVideoEndOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoClickOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoCloseOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoRewardOffer:(ATMyOfferOfferModel*)offer;
-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer;
-(NSString*) sceneForOffer:(ATMyOfferOfferModel*)offer;
@end
#endif /* ATMyOfferRewardedVideoDelegate_h */
