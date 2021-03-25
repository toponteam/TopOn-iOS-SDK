//
//  ATMyOfferNativeCustomEvent.h
//  AnyThinkMyOffer
//
//  Created by Topon on 8/11/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import "ATMyOfferNativeDelegate.h"
#import "ATStoreProductViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATMyOfferNativeCustomEvent : ATNativeADCustomEvent<ATMyOfferNativeDelegate,SKStoreProductViewControllerDelegate>
@property (nonatomic, strong)ATMyOfferOfferModel *offerModel;
@property (nonatomic) ATMyOfferSetting *setting;
@end

NS_ASSUME_NONNULL_END
