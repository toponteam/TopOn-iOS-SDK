//
//  ATOfferModel.m
//  AnyThinkSDK
//
//  Created by stephen on 21/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//


#import "ATOfferModel.h"
#import "Utilities.h"

NSString *const kATOfferBannerSize320_50 = @"320x50";
NSString *const kATOfferBannerSize320_90 = @"320x90";
NSString *const kATOfferBannerSize300_250 = @"300x250";
NSString *const kATOfferBannerSize728_90 = @"728x90";

@implementation ATVideoPlayingTKItem

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.triggerTime = [dict[@"play_sec"] integerValue];
        self.urls = dict[@"list"];
    }
    return self;
}

@end

@implementation ATOfferModel
-(instancetype) initWithDictionary:(NSDictionary *)dictionary{
    self = [super initWithDictionary:dictionary];
   
    return self;
}

@end
