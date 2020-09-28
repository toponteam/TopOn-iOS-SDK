//
//  ATMyofferNativeDelegate.h
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATMyofferNativeDelegate_h
#define ATMyofferNativeDelegate_h
@class ATMyOfferOfferModel;
@protocol ATMyOfferNativeDelegate<NSObject>
-(void) myOfferNativeFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error;
-(void) myOfferNativeShowOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferNativeClickOffer:(ATMyOfferOfferModel*)offer;
-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer;
@end

#endif /* ATMyofferNativeDelegate_h */
