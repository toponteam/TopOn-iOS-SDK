//
//  ATMopubBannerCustomEvent.h
//  AnyThinkMopubBannerAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATMopubBannerAdapter.h"
@interface ATMopubBannerCustomEvent : ATBannerCustomEvent<MPAdViewDelegate>
@property(nonatomic, weak) UIViewController *rootViewController;
@end
