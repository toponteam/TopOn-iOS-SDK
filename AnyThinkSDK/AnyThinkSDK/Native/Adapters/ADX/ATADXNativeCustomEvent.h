//
//  ATADXNativeCustomEvent.h
//  AnyThinkSDK
//
//  Created by Topon on 10/20/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import "ATADXAdLoadingDelegate.h"
#import "ATADXNativeDelegate.h"
#import "ATStoreProductViewController.h"
#import "ATADXPlacementSetting.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATADXNativeCustomEvent : ATNativeADCustomEvent<ATADXNativeDelegate,ATADXAdLoadingDelegate,SKStoreProductViewControllerDelegate>
@property (nonatomic, readwrite) ATUnitGroupModel *unitGroupModel;
@property (nonatomic, readwrite) ATADXOfferModel *offerModel;
@property (nonatomic) ATADXPlacementSetting *setting;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *bidId;
@property (nonatomic, copy) NSString *requestID;
@end

NS_ASSUME_NONNULL_END
