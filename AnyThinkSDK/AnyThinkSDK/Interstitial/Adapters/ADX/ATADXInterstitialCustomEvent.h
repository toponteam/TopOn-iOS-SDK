//
//  ATADXInterstitialCustomEvent.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATInterstitialCustomEvent.h"
#import "ATADXInterstitialAdapter.h"
#import "ATADXAdLoadingDelegate.h"
#import "ATADXInterstitialDelegate.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"


@interface ATADXInterstitialCustomEvent : ATInterstitialCustomEvent <ATADXInterstitialDelegate, ATADXAdLoadingDelegate>
@property(nonatomic, readwrite) ATPlacementModel *placementModel;
@property(nonatomic, readwrite) ATUnitGroupModel *unitGroupModel;
@property(nonatomic, readwrite) ATADXOfferModel *offerModel;
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *bidId;
@property(nonatomic, copy) NSString *requestID;
@end
