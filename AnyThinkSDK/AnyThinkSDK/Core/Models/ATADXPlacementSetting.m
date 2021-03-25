//
//  ATADXSetting.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXPlacementSetting.h"
@implementation ATADXPlacementSetting

-(instancetype) initWithPlacementDictionary:(NSDictionary *)placementDictionary infoDictionary:(NSDictionary *)infoDictionary  placementID:(NSString*)placementID {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary addEntriesFromDictionary:placementDictionary];
    [dictionary addEntriesFromDictionary:infoDictionary];
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        self.placementID = placementID;
        self.format = [dictionary[@"f_t"] integerValue];
        self.resourceDownloadTimeout = [dictionary[@"m_t"] doubleValue] / 1000.0f;//to do: to be divided by 1000.0f
        self.videoClickable = [dictionary[@"v_c"] integerValue];
        self.bannerAppearanceInterval = [dictionary[@"s_b_t"] doubleValue];
        self.endCardClickable = [dictionary[@"e_c_a"] integerValue];
        self.clickMode = [dictionary[@"cm"] integerValue];
        self.loadType = [dictionary[@"ld_t"] integerValue];
        self.impressionUAType = [dictionary[@"ipua"] integerValue];
        self.clickUAType = [dictionary[@"clua"] integerValue];
        self.storekitTime = [dictionary[@"s_t"] integerValue];
        self.closeButtonAppearanceInterval = [infoDictionary[@"s_c_t"] doubleValue];
        self.unMute = [infoDictionary[@"v_m"] boolValue];
        
        self.bannerSize = infoDictionary[@"size"];
        self.splashCountDownTime = [infoDictionary[@"countdown"] integerValue];
        self.skipable = [infoDictionary[@"allows_skip"] boolValue];
        self.splashOrientation = [infoDictionary[@"orientation"] integerValue];
        self.showBannerCloseBtn = ![infoDictionary[@"close_button"] boolValue];
        
        self.lastOfferidsNum = [dictionary[@"l_o_num"] integerValue];
        self.deeplinkClickMoment = [dictionary[@"dp_cm"] integerValue];
        // v 5.7.9
        self.closeBtnDelayMaxTime = [dictionary[@"ec_l_t"] integerValue]/1000;
        self.closeBtnDelayMinTime = [dictionary[@"ec_s_t"] integerValue]/1000;
        self.closeBtnDelayRate = [dictionary[@"ec_r"] integerValue]/100;
    }
    return self;
}



+(instancetype) mockSetting {
    return [[self alloc] initWithDictionary:@{@"f_t":@1,
                                              @"m_t":@5000.0f,
                                              @"v_c":@YES,
                                              @"s_b_t":@(3.0f),
                                              @"e_c_a":@(ATEndCardClickableCTA),
                                              @"cm":@(ATClickModeSync),
                                              @"l_t":@(ATLoadTypeBrowser),
                                              @"ipua":@(ATUserAgentWebView),
                                              @"clua":@(ATUserAgentWebView),
                                              @"s_t":@(ATLoadStorekitTimePreload)
                                              }];
}
@end
