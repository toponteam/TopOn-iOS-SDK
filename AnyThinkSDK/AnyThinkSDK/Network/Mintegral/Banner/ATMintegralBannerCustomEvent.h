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
@property(nonatomic) NSString *price;
@property(nonatomic, copy) NSString *bidId;
@end


