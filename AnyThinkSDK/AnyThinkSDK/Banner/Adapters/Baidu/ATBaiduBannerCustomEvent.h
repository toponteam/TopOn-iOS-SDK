//
//  ATBaiduBannerCustomEvent.h
//  AnyThinkBaiduBannerAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATBaiduBannerAdapter.h"
@interface ATBaiduBannerCustomEvent : ATBannerCustomEvent<BaiduMobAdViewDelegate>
-(instancetype) initWithUnitID:(NSString*)unitID serverInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo bannerView:(id)bannerView;
@end
