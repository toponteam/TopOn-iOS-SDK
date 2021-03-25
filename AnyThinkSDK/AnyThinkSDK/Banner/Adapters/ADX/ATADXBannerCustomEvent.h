//
//  ATADXBannerCustomEvent.h
//  AnyThinkSDK
//
//  Created by Topon on 10/22/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkBanner/AnyThinkBanner.h>
#import "ATADXBannerAdapter.h"
#import "ATADXBannerDelegate.h"
#import "ATADXAdLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATADXBannerCustomEvent : ATBannerCustomEvent<ATADXBannerDelegate,ATADXAdLoadingDelegate>
@property (nonatomic, readwrite) ATUnitGroupModel *unitGroupModel;
@property (nonatomic, strong) ATADXOfferModel *offerModel;
@property (nonatomic) ATADXPlacementSetting *setting;
@property (nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *bidId;
@property (nonatomic, copy) NSString *requestID;

@end

NS_ASSUME_NONNULL_END
