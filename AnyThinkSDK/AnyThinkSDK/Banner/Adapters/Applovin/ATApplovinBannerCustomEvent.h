//
//  ATApplovinBannerCustomEvent.h
//  AnyThinkApplovinBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATApplovinBannerAdapter.h"
@interface ATApplovinBannerCustomEvent : ATBannerCustomEvent<ATALAdLoadDelegate, ATALAdDisplayDelegate, ATALAdViewEventDelegate>
-(instancetype) initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo sdkKey:(NSString*)sdkKey alSize:(CGSize)alSize;
@property(nonatomic, weak) id<ATALAdView> alAdView;
@end
