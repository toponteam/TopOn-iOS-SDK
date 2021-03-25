//
//  ATOnlineApiSplashAdManager.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiAdManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ATOnlineApiSplashDelegate;

@class ATOnlineApiOfferModel,ATOnlineApiPlacementSetting;
@interface ATOnlineApiSplashAdManager : ATOnlineApiAdManager

+ (instancetype)sharedManager;
- (void)showSplashInKeyWindow:(UIWindow *)window containerView:(UIView *)containerView offerModel:(ATOnlineApiOfferModel*)offerModel setting:(ATOnlineApiPlacementSetting*)setting  delegate:(id<ATOnlineApiSplashDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
