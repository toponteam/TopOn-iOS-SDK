//
//  ATADXNativeDelegate.h
//  AnyThinkSDK
//
//  Created by Topon on 10/20/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATADXNativeDelegate_h
#define ATADXNativeDelegate_h

@class ATADXOfferModel;
@protocol ATADXNativeDelegate<NSObject>
-(void) adxNativeFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error;
-(void) adxNativeShowOffer:(ATADXOfferModel*)offer;
-(void) adxNativeClickOffer:(ATADXOfferModel*)offer;
-(void) adxNativeDeepLinkOrJumpResult:(BOOL)success offer:(ATADXOfferModel *)offer;

-(NSString*) lifeCircleIDForOffer:(ATADXOfferModel*)offer;
@end

#endif /* ATADXNativeDelegate_h */
