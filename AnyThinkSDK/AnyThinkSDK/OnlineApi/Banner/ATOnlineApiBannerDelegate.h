//
//  ATOnlineApiBannerDelegate.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>

#ifndef ATOnlineApiBannerDelegate_h
#define ATOnlineApiBannerDelegate_h


@class ATOnlineApiOfferModel;
@protocol ATOnlineApiBannerDelegate<NSObject>
- (void)onlineApiBannerFailToShowOffer:(ATOnlineApiOfferModel *)offer error:(NSError*)error;
- (void)onlineApiBannerShowOffer:(ATOnlineApiOfferModel *)offer;
- (void)onlineApiBannerClickOffer:(ATOnlineApiOfferModel *)offer;
- (void)onlineApiBannerCloseOffer:(ATOnlineApiOfferModel *)offer;
- (void)onlineApiBannerDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer;
- (NSString*)lifeCircleIDForOffer:(ATOnlineApiOfferModel *)offer;
@end


#endif /* ATOnlineApiBannerDelegate_h */
