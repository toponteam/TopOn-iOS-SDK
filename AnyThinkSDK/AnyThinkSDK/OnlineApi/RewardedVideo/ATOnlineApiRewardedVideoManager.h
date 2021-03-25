//
//  ATOnlineApiRewardedVideoManager.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiAdManager.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ATOnlineApiRewardedVideoDelegate;
@class ATUnitGroupModel,ATOnlineApiPlacementSetting;

@interface ATOnlineApiRewardedVideoManager : ATOnlineApiAdManager

+ (instancetype)sharedManager;

- (void)showRewardedVideoWithUnitGroupModelID:(NSString *)uid setting:(ATOnlineApiPlacementSetting *)setting viewController:(UIViewController *)viewController delegate:(id<ATOnlineApiRewardedVideoDelegate >)delegate;

@end

NS_ASSUME_NONNULL_END
