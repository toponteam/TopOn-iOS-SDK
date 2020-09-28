//
//  ATMyOfferOfferModel.m
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferOfferModel.h"
#import "ATMyOfferSetting.h"
#import "ATMyOfferCapsManager.h"
#import "Utilities.h"

@implementation ATMyOfferOfferModel
-(instancetype) initWithDictionary:(NSDictionary *)dictionary placeholders:(NSDictionary*)placeholders format:(NSInteger)format setting:(ATMyOfferSetting*)setting{
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        NSMutableArray<NSString*> *resourceURLs = [NSMutableArray<NSString*> array];
        _offerID = dictionary[@"o_id"];
        
        _resourceID = dictionary[@"c_id"];
        _title = dictionary[@"t"];
        _text = dictionary[@"d"];
        
        _iconURL = dictionary[@"ic_u"];
        if (_iconURL != nil) { [resourceURLs addObject:_iconURL]; }
        
        //        _mainImageURL = dictionary[@"im_u"];
        //        if (_mainImageURL != nil) { [resourceURLs addObject:_mainImageURL]; }
        
        _fullScreenImageURL = dictionary[@"f_i_u"];
        if (_fullScreenImageURL != nil) { [resourceURLs addObject:_fullScreenImageURL]; }
        
        _imageOrientation = [dictionary[@"f_i_o"] integerValue];
        
        _logoURL = dictionary[@"a_c_u"];
        if ([_logoURL isKindOfClass:[NSString class]] && [_logoURL length] > 0) { [resourceURLs addObject:_logoURL]; }
        
        _CTA = dictionary[@"c_t"];
        
        _videoURL = dictionary[@"v_u"];
        if (_videoURL != nil) { [resourceURLs addObject:_videoURL]; }
        
        _interstitalType = [dictionary[@"unit_type"] integerValue];
        _videoOrientation = [dictionary[@"v_o"] integerValue];
        _storeURL = dictionary[@"p_u"];
        _jumpType = [dictionary[@"l_t"] integerValue];
        //        _deepLink = dictionary[@"dl"];
        _performsAsynchronousRedirection = [dictionary[@"c_m"] boolValue];
        
        _videoStartTKURL = dictionary[@"t_u"];//@"{sh}://{do}/video_start?p={p}&p2={p2}";//to do
        _video25TKURL = dictionary[@"t_u_25"];//@"{sh}://{do}/video_25?p={p}&p2={p2}";//to do
        _video50TKURL = dictionary[@"t_u_50"];//@"{sh}://{do}/video_50?p={p}&p2={p2}";//to do
        _video75TKURL = dictionary[@"t_u_75"];//@"{sh}://{do}/video_75?p={p}&p2={p2}";//to do
        _videoEndTKURL = dictionary[@"t_u_100"];//@"{sh}://{do}/video_end?p={p}&p2={p2}";//to do
        _endCardShowTKURL = dictionary[@"s_e_c_t_u"];//@"{sh}://{do}/end_card_show?p={p}&p2={p2}";//to do
        _endCardCloseTKURL = dictionary[@"c_t_u"];//@"{sh}://{do}/end_card_close?p={p}&p2={p2}";//to do
        
        _clickURL = dictionary[@"c_u"];//@"https://imp_test_url?req_id={req_id}";//to do
        _impURL = dictionary[@"ip_u"];//@"https://click_test_url?req_id={req_id}";//to do
        
        _impTKURL = dictionary[@"ip_n_u"];//@"{sh}://{do}/imp_tk?p={p}&p2={p2}";//to do
        _clickTKURL = dictionary[@"c_n_u"];//@"{sh}://{do}/click_tk?p={p}&p2={p2}";//to do
        
        _dailyCap = [dictionary[@"o_a_d_c"] integerValue];
        _pacing = [dictionary[@"o_a_p"] doubleValue] / 1000.0f;
        
        _placeholders = placeholders;
        
        
        //v5.6.6
        _bannerImageUrl = dictionary[@"ext_h_pic"];
        if(_bannerImageUrl != nil && _bannerImageUrl.length>0 && [setting.bannerSize isEqualToString:kATMyOfferBannerSize320_50]){
            [resourceURLs addObject:_bannerImageUrl];
        }
        _bannerBigImageUrl = dictionary[@"ext_big_h_pic"];
        if(_bannerBigImageUrl != nil && _bannerBigImageUrl.length>0 && [setting.bannerSize isEqualToString:kATMyOfferBannerSize320_90]){
            [resourceURLs addObject:_bannerBigImageUrl];
        }
        _rectangleImageUrl = dictionary[@"ext_rect_h_pic"];
        if(_rectangleImageUrl != nil && _rectangleImageUrl.length>0 && [setting.bannerSize isEqualToString:kATMyOfferBannerSize300_250]){
            [resourceURLs addObject:_rectangleImageUrl];
        }
        _homeImageUrl = dictionary[@"ext_home_h_pic"];
        if(_homeImageUrl != nil && _homeImageUrl.length>0 && [setting.bannerSize isEqualToString:kATMyOfferBannerSize728_90]){
            [resourceURLs addObject:_homeImageUrl];
        }
        _pkgName = dictionary[@"p_g"];
        if(_pkgName == nil || _pkgName.length == 0){
            _pkgName = nil;
        }
//        _pkgName = @"529479190";
        _resourceURLs = resourceURLs;
        
        _localResourceID = [NSString stringWithFormat:@"%@%@", _resourceID, setting.placementID].md5;
        
    }
    return self;
}

+(instancetype) mockOfferModel {
    return [[self alloc] initWithDictionary:@{@"o_id":@"mock_offer_id",
                                              @"c_id":@"mock_resource_id",
                                              @"t":@"部落冲突 (Clash of Clans)",
                                              @"d":@"加入全球数百万玩家的行列，建立村庄、组建部落，参加史诗般的部落对战！",
                                              @"ic_u":@"http://cdn-adn.rayjump.com/cdn-adn/dmp/18/06/12/05/31/5b1eea2b1d666.png",
                                              @"f_i_u":@"http://cdn-adn.rayjump.com/cdn-adn/v2/dmp/19/06/19/00/35/5d0912c3926f3.jpg",
                                              @"c_t":@"INSTALL NOW",
                                              @"v_u":@"http://cdn-adn.rayjump.com/cdn-adn/19/06/22/01/06/5d0d0e78d77b3.mp4",
                                              @"p_u":@"https://itunes.apple.com/cn/app/id529479190"
    }];
}
@end
