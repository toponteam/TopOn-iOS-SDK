//
//  ATKidozBannerCustomEvent.h
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkBanner/AnyThinkBanner.h>
#import "ATKidozBannerAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATKidozBannerCustomEvent : ATBannerCustomEvent
@property(nonatomic, weak) UIView *kidozBannerView;
@end

NS_ASSUME_NONNULL_END
