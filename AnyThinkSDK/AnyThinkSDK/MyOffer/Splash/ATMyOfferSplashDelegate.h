//
//  ATMyofferSplashDelegate.h
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATMyofferSplashDelegate_h
#define ATMyofferSplashDelegate_h
@class ATMyOfferOfferModel;
@protocol ATMyOfferSplashDelegate<NSObject>
-(void) myOfferSplashFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error;
-(void) myOfferSplashShowOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferSplashClickOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferSplashCloseOffer:(ATMyOfferOfferModel*)offer;
-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer;
@end

#endif /* ATMyofferSplashDelegate_h */
