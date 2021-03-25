//
//  ATOnlineApiSplashDelegate.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATOnlineApiSplashDelegate_h
#define ATOnlineApiSplashDelegate_h

@class ATOnlineApiOfferModel;
@protocol ATOnlineApiSplashDelegate<NSObject>
- (void)onlineApiSplashFailToShowOffer:(ATOnlineApiOfferModel *)offer error:(NSError*)error;
- (void)onlineApiSplashShowOffer:(ATOnlineApiOfferModel *)offer;
- (void)onlineApiSplashClickOffer:(ATOnlineApiOfferModel *)offer;
- (void)onlineApiSplashCloseOffer:(ATOnlineApiOfferModel *)offer;
- (void)onlineApiSplashDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer;
- (NSString*)lifeCircleIDForOffer:(ATOnlineApiOfferModel *)offer;

@end
#endif /* ATOnlineApiSplashDelegate_h */
