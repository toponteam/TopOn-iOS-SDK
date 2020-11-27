//
//  ATADXInterstitialManager.h
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
#import "ATADXInterstitialDelegate.h"
#import "ATADXAdManager.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"


@interface ATADXInterstitialAdManager:ATADXAdManager<ATOfferVideoDelegate,ATOfferFullScreenPictureDelegate , SKStoreProductViewControllerDelegate>
+(instancetype) sharedManager;

-(void) showInterstitialWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel setting:(ATADXPlacementSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATADXInterstitialDelegate>)delegate;
@end
