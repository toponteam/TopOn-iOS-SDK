//
//  ATADXNativeAdManager.h
//  AnyThinkSDK
//
//  Created by Topon on 10/21/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXAdManager.h"
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "ATADXNativeDelegate.h"
#import "ATADXOfferModel.h"
#import "ATADXPlacementSetting.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATADXNativeAdManager : ATADXAdManager<SKStoreProductViewControllerDelegate>

@property (nonatomic , weak) id<ATADXNativeDelegate> delegate;
@property (nonatomic , weak) UIViewController* viewController;
@property (nonatomic, weak) UIView *adView;

+(instancetype) sharedManager;
- (void)registerViewForInteraction:(UIViewController *)viewController adView:(UIView *)adView clickableViews:(NSArray<UIView *> *)clickableViews offerModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting *)setting delegate:(id<ATADXNativeDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
