//
//  ATADXSplashCustomEvent.h
//  AnyThinkSDK
//
//  Created by Topon on 10/21/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>
#import "ATADXSplashAdapter.h"
#import "ATADXSplashDelegate.h"
#import "ATADXAdLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATADXSplashCustomEvent : ATSplashCustomEvent<ATADXSplashDelegate,ATADXAdLoadingDelegate>
@property(nonatomic) UIView *containerView;
@property(nonatomic, readwrite) ATADXOfferModel *offerModel;
@property(nonatomic, readwrite) ATUnitGroupModel *unitGroupModel;
@property (nonatomic) ATADXPlacementSetting *setting;
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *bidId;
@property(nonatomic, copy) NSString *requestID;
@end

NS_ASSUME_NONNULL_END
