//
//  ATMyOfferRewardedVideoSharedDelegate.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/30.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ATMyOfferVideoViewController.h"
#import "ATMyOfferRewardedVideoDelegate.h"
@interface ATMyOfferRewardedVideoSharedDelegate : NSObject<ATMyOfferVideoDelegate, SKStoreProductViewControllerDelegate>
+(instancetype) sharedDelegate;
-(void) showRewardedVideoWithOfferModel:(ATMyOfferOfferModel *)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferRewardedVideoDelegate>)delegate;
@end
