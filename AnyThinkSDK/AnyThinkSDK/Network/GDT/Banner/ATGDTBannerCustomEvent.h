//
//  ATGDTBannerCustomEvent.h
//  AnyThinkGDTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATGDTBannerAdapter.h"
@interface ATGDTBannerCustomEvent : ATBannerCustomEvent<ATGDTMobBannerViewDelegate, GDTUnifiedBannerViewDelegate>
@property(nonatomic, weak) id<ATGDTMobBannerView> gdtBannerView;
@end
