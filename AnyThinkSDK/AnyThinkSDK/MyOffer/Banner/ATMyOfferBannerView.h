//
//  ATMyOfferBannerView.h
//  AnyThinkMyOffer
//
//  Created by stephen on 8/3/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<StoreKit/StoreKit.h>
#import "ATMyOfferBannerDelegate.h"
#import "ATMyOfferSetting.h"

@class ATMyOfferBannerView;


@interface ATMyOfferBannerView:UIView<SKStoreProductViewControllerDelegate>
@property(nonatomic, weak) id<ATMyOfferBannerDelegate> delegate;
-(instancetype) initWithFrame:(CGRect)frame offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting delegate:(id<ATMyOfferBannerDelegate>)delegate viewController:(UIViewController *)viewController;
-(void) initMyOfferBannerView;
@end
