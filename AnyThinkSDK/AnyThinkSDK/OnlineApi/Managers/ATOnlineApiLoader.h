//
//  ATOnlineApiLoader.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRequestConfiguration.h"

@class ATUnitGroupModel, ATBidInfo, ATPlacementModel, ATOnlineApiOfferModel;

@interface ATOnlineApiLoader : NSObject

+ (instancetype)sharedLoader;

- (void)recordShownAdWithOfferID:(NSString *)offerID unitID:(NSString *)uid;

/** It is recommended to set all the parameters of 'config', except for 'requestParam' */
- (void)requestOnlineApiAdsWithConfiguration:(ATRequestConfiguration *)config;

/**
 If it's not ready, then the return value will be nil.
 */
- (ATOnlineApiOfferModel *)readyOnlineApiAdWithUnitGroupModelID:(NSString *)unitGroupModelID placementID:(NSString *)placementID;

- (void)removeOfferModel:(ATOnlineApiOfferModel *)offerModel;

@end

