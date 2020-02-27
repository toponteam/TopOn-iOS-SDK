//
//  ATMyOfferSetting.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferSetting.h"
@implementation ATMyOfferSetting
-(instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        _format = [dictionary[@"f_t"] integerValue];
        _videoAreaInteractionEnabled = [dictionary[@"v_c"] boolValue];
        _bannerAppearanceInterval = [dictionary[@"s_b_t"] doubleValue];
        _endCardClickable = [dictionary[@"e_c_a"] integerValue];
        _mute = [dictionary[@"v_m"] boolValue];
        _closeButtonAppearanceInterval = [dictionary[@"s_c_t"] doubleValue];
        _resourceDownloadTimeout = [dictionary[@"m_t"] doubleValue] / 1000.0f;//to do: to be divided by 1000.0f
        _resourceCacheTime = [dictionary[@"o_c_t"] doubleValue] / 1000.0f;
    }
    return self;
}

+(instancetype) mockSetting {
    return [[self alloc] initWithDictionary:@{@"f_t":@1,
                                              @"v_c":@YES,
                                              @"s_b_t":@(3.0f),
                                              @"e_c_a":@(ATMyOfferEndCardClickableCTA),
                                              @"v_m":@NO,
                                              @"s_c_t":@3.0f,
                                              @"m_t":@5000.0f,
                                              @"o_c_t":@(1000.0f * 30.0f * 60.0f)
                                              }];
}
@end
