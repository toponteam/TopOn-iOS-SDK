//
//  ATMyOfferInterstitialSharedDelegate.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/30.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATMyOfferVideoViewController.h"
#import "ATMyOfferInterstitialDelegate.h"
@interface ATMyOfferInterstitialSharedDelegate : NSObject<ATMyOfferVideoDelegate>
+(instancetype) sharedDelegate;
-(void) showInterstitialWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferInterstitialDelegate>)delegate;
@end
