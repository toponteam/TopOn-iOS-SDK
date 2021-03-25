//
//  ATOnlineApiNativeAdManager.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiAdManager.h"
#import <UIKit/UIKit.h>
#import "ATOnlineApiNativeDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class ATOnlineApiOfferModel, ATOnlineApiPlacementSetting;
@interface ATOnlineApiNativeAdManager : ATOnlineApiAdManager

@property (nonatomic, weak) id<ATOnlineApiNativeDelegate> delegate;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIView *adView;

+ (instancetype)sharedManager;

- (void)registerViewCtrlForInteraction:(UIViewController *)viewController adView:(UIView *)adView clickableViews:(NSArray<UIView *> *)clickableViews offerModel:(ATOnlineApiOfferModel *)offerModel setting:(ATOnlineApiPlacementSetting  *)setting delegate:(id<ATOnlineApiNativeDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
