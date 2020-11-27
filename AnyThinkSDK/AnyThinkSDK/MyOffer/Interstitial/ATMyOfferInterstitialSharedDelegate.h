//
//  ATMyOfferInterstitialSharedDelegate.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/30.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ATOfferVideoViewController.h"
#import "ATOfferFullScreenPictureViewController.h"
#import "ATMyOfferInterstitialDelegate.h"
#import "ATMyOfferOfferModel.h"
#import "ATMyOfferSetting.h"
@interface ATMyOfferInterstitialSharedDelegate : NSObject<ATOfferVideoDelegate,ATOfferFullScreenPictureDelegate , SKStoreProductViewControllerDelegate>
+(instancetype) sharedDelegate;
-(void) showInterstitialWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferInterstitialDelegate>)delegate;
@end
