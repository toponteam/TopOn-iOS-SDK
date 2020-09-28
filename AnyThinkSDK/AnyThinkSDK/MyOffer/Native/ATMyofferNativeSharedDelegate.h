//  ATMyofferNativeSharedDelegate.h
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "ATMyOfferNativeDelegate.h"
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferModel.h"


@interface ATMyOfferNativeSharedDelegate : NSObject<SKStoreProductViewControllerDelegate>

@property (nonatomic , weak) id<ATMyOfferNativeDelegate> delegate;
@property (nonatomic , weak) UIViewController* viewController;
+(instancetype) sharedDelegate;
- (void)registerViewForInteraction:(UIViewController *)viewController clickableViews:(NSArray<UIView *> *)clickableViews offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting *)setting delegate:(id<ATMyOfferNativeDelegate>)delegate;

@end
