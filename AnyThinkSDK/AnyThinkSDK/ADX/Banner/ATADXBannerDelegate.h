//
//  ATADXBannerDelegate.h
//  AnyThinkSDK
//
//  Created by Topon on 10/22/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATADXBannerDelegate_h
#define ATADXBannerDelegate_h

@class ATADXOfferModel;
@protocol ATADXBannerDelegate<NSObject>
-(void) adxBannerFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error;
-(void) adxBannerShowOffer:(ATADXOfferModel*)offer;
-(void) adxBannerClickOffer:(ATADXOfferModel*)offer;
-(void) adxBannerCloseOffer:(ATADXOfferModel*)offer;
-(void) adxBannerDeepLinkOrJumpResult:(BOOL)success offer:(ATADXOfferModel *)offer;

-(NSString*) lifeCircleIDForOffer:(ATADXOfferModel*)offer;
@end

#endif /* ATADXBannerDelegate_h */
