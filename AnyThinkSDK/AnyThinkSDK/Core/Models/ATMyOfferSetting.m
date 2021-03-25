//
//  ATMyOfferSetting.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferSetting.h"
@implementation ATMyOfferSetting
-(instancetype) initWithDictionary:(NSDictionary *)dictionary placementID:(NSString*)placementID {
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        self.placementID = placementID;
        self.format = [dictionary[@"f_t"] integerValue];
        self.videoClickable = [dictionary[@"v_c"] integerValue] + 1;//add one to be the same with adx
        self.bannerAppearanceInterval = [dictionary[@"s_b_t"] doubleValue];
        self.endCardClickable = [dictionary[@"e_c_a"] integerValue] + 1;//add one to be the same with adx
        self.unMute = [dictionary[@"v_m"] boolValue];
        self.closeButtonAppearanceInterval = [dictionary[@"s_c_t"] doubleValue];
        self.resourceDownloadTimeout = [dictionary[@"m_t"] doubleValue] / 1000.0f;//to do: to be divided by 1000.0f
        self.resourceCacheTime = [dictionary[@"o_c_t"] doubleValue] / 1000.0f;
        self.bannerSize = dictionary[@"size"];
        self.splashCountDownTime = [dictionary[@"ctdown_time"] integerValue];
        self.skipable = ![dictionary[@"sk_able"] boolValue];
        self.splashOrientation = [dictionary[@"orient"] integerValue];
        self.storekitTime = [dictionary[@"skit_time"] integerValue] + 1;//add one to be the same with adx
        self.showBannerCloseBtn = ![dictionary[@"cl_btn"] boolValue];
        
        self.deeplinkClickMoment  = ATDeepLinkModeNone;

        // v 5.7.9
        self.closeBtnDelayMaxTime = [dictionary[@"ec_l_t"] integerValue]/1000;
        self.closeBtnDelayMinTime = [dictionary[@"ec_s_t"] integerValue]/1000;
        self.closeBtnDelayRate = [dictionary[@"ec_r"] integerValue]/100;
    }
    return self;
}

+(instancetype) mockSetting {
    return [[self alloc] initWithDictionary:@{@"f_t":@1,
                                              @"v_c":@YES,
                                              @"s_b_t":@(3.0f),
                                              @"e_c_a":@(ATEndCardClickableCTA),
                                              @"v_m":@NO,
                                              @"s_c_t":@3.0f,
                                              @"m_t":@5000.0f,
                                              @"o_c_t":@(1000.0f * 30.0f * 60.0f)
                                              }];
}
@end
