//
//  ATADXRewardedVideoManager.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ATADXOfferModel.h"
#import "ATADXPlacementSetting.h"
#import "ATOfferVideoViewController.h"
#import "ATOfferFullScreenPictureViewController.h"
#import "ATADXRewardedVideoDelegate.h"
#import "ATADXAdManager.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"

@interface ATADXAdManager(RewardedVideo)<ATOfferVideoDelegate , SKStoreProductViewControllerDelegate>

-(void) showRewardedVideoWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel setting:(ATADXPlacementSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATADXRewardedVideoDelegate>)delegate;
@end
