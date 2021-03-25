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
        self.offerID = dictionary[@"o_id"];
        
        self.resourceID = dictionary[@"c_id"];
        self.title = dictionary[@"t"];
        self.text = dictionary[@"d"];
        
        self.iconURL = dictionary[@"ic_u"];
        if (self.iconURL != nil) { [resourceURLs addObject:self.iconURL]; }
        
        //        _mainImageURL = dictionary[@"im_u"];
        //        if (_mainImageURL != nil) { [resourceURLs addObject:_mainImageURL]; }
        
        self.fullScreenImageURL = dictionary[@"f_i_u"];
        if (self.fullScreenImageURL != nil) { [resourceURLs addObject:self.fullScreenImageURL]; }
        
        self.imageOrientation = [dictionary[@"f_i_o"] integerValue];
        
        self.logoURL = dictionary[@"a_c_u"];
        if ([self.logoURL isKindOfClass:[NSString class]] && [self.logoURL length] > 0) { [resourceURLs addObject:self.logoURL]; }
                
        self.videoURL = dictionary[@"v_u"];
        if (self.videoURL != nil) { [resourceURLs addObject:self.videoURL]; }
        
        self.interstitialType = [dictionary[@"unit_type"] integerValue];
        self.videoOrientation = [dictionary[@"v_o"] integerValue];
        self.storeURL = dictionary[@"p_u"];
        self.linkType = [dictionary[@"l_t"] integerValue];
        self.deeplinkUrl = dictionary[@"dl"];
        self.performsAsynchronousRedirection = [dictionary[@"c_m"] integerValue] + 1;//add one to be the same with adx
        
        self.videoStartTKURL = dictionary[@"t_u"];//@"{sh}://{do}/video_start?p={p}&p2={p2}";//to do
        self.video25TKURL = dictionary[@"t_u_25"];//@"{sh}://{do}/video_25?p={p}&p2={p2}";//to do
        self.video50TKURL = dictionary[@"t_u_50"];//@"{sh}://{do}/video_50?p={p}&p2={p2}";//to do
        self.video75TKURL = dictionary[@"t_u_75"];//@"{sh}://{do}/video_75?p={p}&p2={p2}";//to do
        self.videoEndTKURL = dictionary[@"t_u_100"];//@"{sh}://{do}/video_end?p={p}&p2={p2}";//to do
        self.endCardShowTKURL = dictionary[@"s_e_c_t_u"];//@"{sh}://{do}/end_card_show?p={p}&p2={p2}";//to do
        self.endCardCloseTKURL = dictionary[@"c_t_u"];//@"{sh}://{do}/end_card_close?p={p}&p2={p2}";//to do
        
        self.clickURL = dictionary[@"c_u"];//@"https://imp_test_url?req_id={req_id}";//to do
        self.impURL = dictionary[@"ip_u"];//@"https://click_test_url?req_id={req_id}";//to do
        
        self.impTKURL = dictionary[@"ip_n_u"];//@"{sh}://{do}/imp_tk?p={p}&p2={p2}";//to do
        self.clickTKURL = dictionary[@"c_n_u"];//@"{sh}://{do}/click_tk?p={p}&p2={p2}";//to do
        
        self.dailyCap = [dictionary[@"o_a_d_c"] integerValue];
        self.pacing = [dictionary[@"o_a_p"] doubleValue] / 1000.0f;
        
        self.placeholders = placeholders;
        
        
        //v5.6.6
        self.bannerImageUrl = dictionary[@"ext_h_pic"];
        if(self.bannerImageUrl != nil && self.bannerImageUrl.length>0 && [setting.bannerSize isEqualToString:kATOfferBannerSize320_50]){
            [resourceURLs addObject:self.bannerImageUrl];
        }
        self.bannerBigImageUrl = dictionary[@"ext_big_h_pic"];
        if(self.bannerBigImageUrl != nil && self.bannerBigImageUrl.length>0 && [setting.bannerSize isEqualToString:kATOfferBannerSize320_90]){
            [resourceURLs addObject:self.bannerBigImageUrl];
        }
        self.rectangleImageUrl = dictionary[@"ext_rect_h_pic"];
        if(self.rectangleImageUrl != nil && self.rectangleImageUrl.length>0 && [setting.bannerSize isEqualToString:kATOfferBannerSize300_250]){
            [resourceURLs addObject:self.rectangleImageUrl];
        }
        self.homeImageUrl = dictionary[@"ext_home_h_pic"];
        if(self.homeImageUrl != nil && self.homeImageUrl.length>0 && [setting.bannerSize isEqualToString:kATOfferBannerSize728_90]){
            [resourceURLs addObject:self.homeImageUrl];
        }
        self.pkgName = dictionary[@"p_g"];
        if(self.pkgName == nil || self.pkgName.length == 0){
            self.pkgName = nil;
        }
//        _pkgName = @"529479190";
        self.resourceURLs = resourceURLs;
        
        self.localResourceID = [NSString stringWithFormat:@"%@%@", self.resourceID, setting.placementID].md5;
        
        self.offerModelType = ATOfferModelMyOffer;
        
        [self checkCrtType];
        self.CTA = dictionary[@"c_t"];
        if (self.crtType == ATOfferCrtTypeOneImage && [Utilities isEmpty:self.CTA]) {
            self.CTA = [Utilities localizationForLearnMore];
        }
        
        if (self.crtType == ATOfferCrtTypeOneImageWithText) {
            self.interActableArea = setting.endCardClickable == ATEndCardClickableFullscreen ? ATOfferInterActableAreaAll : ATOfferInterActableAreaVisibleItems;
            return self;
        }
        
        if (self.crtType == ATOfferCrtTypeOneImage) {
            // rv iv splash
            if (format == 1 || format == 3 || format == 4) {
                self.interActableArea = setting.endCardClickable == ATEndCardClickableFullscreen ? ATOfferInterActableAreaAll : ATOfferInterActableAreaCTA;
            }
        }
    }
    return self;
}

- (void)checkCrtType {

    self.crtType = ATOfferCrtTypeOneImageWithText;
    if(([Utilities isEmpty:self.bannerImageUrl] == NO) ||
       ([Utilities isEmpty:self.bannerBigImageUrl] == NO) ||
       ([Utilities isEmpty:self.rectangleImageUrl] == NO) ||
       ([Utilities isEmpty:self.homeImageUrl] == NO)) {
        self.crtType = ATOfferCrtTypeOneImage;
    }
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
