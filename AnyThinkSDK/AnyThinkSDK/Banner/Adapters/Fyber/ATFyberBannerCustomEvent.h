//
//  ATFyberBannerCustomEvent.h
//  AnyThinkFyberBannerAdapter
//
//  Created by Martin Lau on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATFyberBannerAdapter.h"

@interface ATFyberBannerCustomEvent : ATBannerCustomEvent<IAUnitDelegate, IAMRAIDContentDelegate>
@property(nonatomic) id<ATIAAdSpot> spot;
@property(nonatomic) id<ATIAViewUnitController> viewUnitController;
@property(nonatomic) id<ATIAMRAIDContentController> MRAIDContentController;
@end
