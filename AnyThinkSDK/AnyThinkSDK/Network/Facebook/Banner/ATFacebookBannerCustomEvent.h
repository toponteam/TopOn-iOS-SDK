//
//  ATFacebookBannerCustomEvent.h
//  AnyThinkFacebookBannerAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATFacebookBannerAdapter.h"
@interface ATFacebookBannerCustomEvent : ATBannerCustomEvent<FBAdViewDelegate>
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *bidId;
@end
