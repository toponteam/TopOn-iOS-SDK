//
//  ATMyofferBannerSharedDelegate.h
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATMyOfferVideoViewController.h"
#import "ATMyOfferBannerDelegate.h"
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferModel.h"
#import "ATMyOfferBannerView.h"

@interface ATMyOfferBannerSharedDelegate : NSObject
+(instancetype) sharedDelegate;
-(ATMyOfferBannerView*)retrieveBannerViewWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting  extra:(NSDictionary *)extra delegate:(id<ATMyOfferBannerDelegate>) delegate;
@end
