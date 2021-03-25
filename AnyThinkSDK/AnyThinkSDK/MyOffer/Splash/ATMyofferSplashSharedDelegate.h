//
//  ATMyofferSplashSharedDelegate.h
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ATMyOfferSplashDelegate.h"
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferModel.h"

@interface ATMyOfferSplashSharedDelegate : NSObject<SKStoreProductViewControllerDelegate>
+(instancetype) sharedDelegate;
- (void)showSplashInKeyWindow:(UIWindow *)window containerView:(UIView *)containerView offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting  delegate:(id<ATMyOfferSplashDelegate>)delegate;
@end
