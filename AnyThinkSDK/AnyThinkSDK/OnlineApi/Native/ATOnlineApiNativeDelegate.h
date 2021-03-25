//
//  ATOnlineApiNativeDelegate.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATOnlineApiNativeDelegate_h
#define ATOnlineApiNativeDelegate_h

@class ATOnlineApiOfferModel;
@protocol ATOnlineApiNativeDelegate<NSObject>
- (void)onlineApiNativeFailToShowOffer:(ATOnlineApiOfferModel *)offer error:(NSError *)error;
- (void)onlineApiNativeShowOffer:(ATOnlineApiOfferModel *)offer;
- (void)onlineApiNativeClickOffer:(ATOnlineApiOfferModel *)offer;
- (void)onlineApiNativeDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer;

- (NSString *)lifeCircleIDForOffer:(ATOnlineApiOfferModel *)offer;
@end
#endif /* ATOnlineApiNativeDelegate_h */
