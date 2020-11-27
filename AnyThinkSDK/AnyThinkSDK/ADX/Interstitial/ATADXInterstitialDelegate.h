//
//  ATADXInterstitialDelegate.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATADXInterstitialDelegate_h
#define ATADXInterstitialDelegate_h
@class ATADXOfferModel;
@protocol ATADXInterstitialDelegate<NSObject>
-(void) didInterstitialFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error;
-(void) didInterstitialShowOffer:(ATADXOfferModel*)offer;
-(void) didInterstitialVideoStartOffer:(ATADXOfferModel*)offer;
-(void) didInterstitialVideoEndOffer:(ATADXOfferModel*)offer;
-(void) didInterstitialClickOffer:(ATADXOfferModel*)offer;
-(void) didInterstitialCloseOffer:(ATADXOfferModel*)offer;
-(NSString*) lifeCircleIDForOffer:(ATADXOfferModel*)offer;
-(NSString*) sceneForOffer:(ATADXOfferModel*)offer;
@end

#endif /* ATADXInterstitialDelegate_h */
