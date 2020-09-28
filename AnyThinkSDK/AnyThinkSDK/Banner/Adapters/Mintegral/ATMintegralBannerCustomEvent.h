//
//  ATMintegralBannerCustomEvent.h
//  AnyThinkMintegralBannerAdapter
//
//  Created by Topon on 2019/11/15.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATMintegralBannerAdapter.h"
#import "ATBannerCustomEvent.h"


@interface ATMintegralBannerCustomEvent : ATBannerCustomEvent<ATMTGBannerAdViewDelegate>
@property(nonatomic) double price;
@end


