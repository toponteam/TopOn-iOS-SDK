//
//  ATTTBannerCustomEvent.h
//  AnyThinkTTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATTTBannerAdapter.h"

@interface ATTTBannerCustomEvent : ATBannerCustomEvent<BUNativeExpressBannerViewDelegate>
@property (nonatomic) BOOL isFailed;
@end
