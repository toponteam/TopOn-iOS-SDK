//
//  ATADXSplashAdManager.h
//  AnyThinkSDK
//
//  Created by Topon on 10/21/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXAdManager.h"
#import <StoreKit/StoreKit.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ATADXSplashDelegate.h"
#import "ATADXOfferModel.h"
#import "ATADXPlacementSetting.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATADXSplashAdManager : ATADXAdManager<SKStoreProductViewControllerDelegate>
+(instancetype) sharedManager;
- (void)showSplashInKeyWindow:(UIWindow *)window containerView:(UIView *)containerView offerModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting*)setting  delegate:(id<ATADXSplashDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
