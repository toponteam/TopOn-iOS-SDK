//
//  ATMyOfferInterstitialDelegate.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#ifndef ATMyOfferInterstitialDelegate_h
#define ATMyOfferInterstitialDelegate_h
@class ATMyOfferOfferModel;
@protocol ATMyOfferInterstitialDelegate<NSObject>
-(void) myOfferIntersititalFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error;
-(void) myOfferIntersititalShowOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferInterstitialVideoStartOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferInterstitialVideoEndOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferInterstitialClickOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferInterstitialCloseOffer:(ATMyOfferOfferModel*)offer;
-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer;
-(NSString*) sceneForOffer:(ATMyOfferOfferModel*)offer;
@end
#endif /* ATMyOfferInterstitialDelegate_h */
