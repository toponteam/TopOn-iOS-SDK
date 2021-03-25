//
//  ATADXSplashDelegate.h
//  AnyThinkSDK
//
//  Created by Topon on 10/21/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATADXSplashDelegate_h
#define ATADXSplashDelegate_h

@class ATADXOfferModel;
@protocol ATADXSplashDelegate<NSObject>
-(void) adxSplashFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error;
-(void) adxSplashShowOffer:(ATADXOfferModel*)offer;
-(void) adxSplashClickOffer:(ATADXOfferModel*)offer;
-(void) adxSplashCloseOffer:(ATADXOfferModel*)offer;
-(void) adxSplashDeepLinkOrJumpResult:(BOOL)success offer:(ATADXOfferModel *)offer;

-(NSString*) lifeCircleIDForOffer:(ATADXOfferModel*)offer;
@end

#endif /* ATADXSplashDelegate_h */
