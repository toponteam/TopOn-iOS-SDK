//
//  ATInmobiBannerCustomEvent.h
//  AnyThinkInmobiBannerAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATInmobiBannerAdapter.h"
NS_ASSUME_NONNULL_BEGIN

@interface ATInmobiBannerCustomEvent : ATBannerCustomEvent<IMBannerDelegate>

@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *bidID;

@end

NS_ASSUME_NONNULL_END
