//
//  ATMyofferBannerDelegate.h
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATMyofferBannerDelegate_h
#define ATMyofferBannerDelegate_h

@class ATMyOfferOfferModel;
@protocol ATMyOfferBannerDelegate<NSObject>
-(void) myOfferBannerFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error;
-(void) myOfferBannerShowOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferBannerClickOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferBannerCloseOffer:(ATMyOfferOfferModel*)offer;
-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer;
@end

#endif /* ATMyofferBannerDelegate_h */
