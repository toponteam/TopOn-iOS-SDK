//
//  ATMyTargetBannerCustomEvent.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkBanner/AnyThinkBanner.h>
#import "ATMyTargetAdViewApis.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATMyTargetBannerCustomEvent : ATBannerCustomEvent<MTRGAdViewDelegate>

@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *bidID;

@end

NS_ASSUME_NONNULL_END
