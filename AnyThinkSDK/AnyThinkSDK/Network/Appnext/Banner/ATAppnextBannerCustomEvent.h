//
//  ATAppnextBannerCustomEvent.h
//  AnyThinkAppnextBannerAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATAppnextBannerAdapter.h"
NS_ASSUME_NONNULL_BEGIN

@interface ATAppnextBannerCustomEvent : ATBannerCustomEvent<AppnextBannerDelegate>
@property(nonatomic, weak) id<ATAppnextBannerView> anBannerView;
@end

NS_ASSUME_NONNULL_END
