//
//  ATOnlineApiInterstitialAdManager.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiAdManager.h"
#import "ATOnlineApiInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class ATOnlineApiPlacementSetting;
@interface ATOnlineApiInterstitialAdManager : ATOnlineApiAdManager

+ (instancetype)sharedManager;

- (void)showInterstitialWithUnitGroupModelID:(NSString *)uid setting:(ATOnlineApiPlacementSetting *)setting viewController:(UIViewController *)viewController delegate:(id<ATOnlineApiInterstitialDelegate >)delegate;

@end

NS_ASSUME_NONNULL_END
