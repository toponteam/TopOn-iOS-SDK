//
//  ATOnlineApiOfferModel.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiOfferModel.h"
#import "Utilities.h"
#import "NSObject+KAKit.h"
#import "ATPlacementSettingManager.h"

@implementation ATOnlineApiOfferModel

-(instancetype) initWithDictionary:(NSDictionary *)dictionary content:(NSDictionary *)content{
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        NSMutableArray<NSString*> *resourceURLs = [NSMutableArray<NSString*> array];
        
        _rtbId = dictionary[@"id"];
        self.placementID = dictionary[@"at_placement_id"];
        self.unitID = dictionary[@"at_unit_id"];
        self.format = [dictionary[@"at_format"] integerValue];
        self.requestID = dictionary[@"at_request_id"];
        self.networkFirmID = [dictionary[@"at_networkFirmID"] integerValue];

        NSArray* offersDictArr = dictionary[@"offers"];
        NSDictionary *offersDict = offersDictArr.firstObject;
        if(offersDict != nil && [offersDict count] > 0){
            self.offerID = offersDict[@"oid"];
            self.offerFirmID = [offersDict[@"offer_firm_id"]integerValue];
            self.expireDate = [NSDate dateWithTimeIntervalSince1970:[offersDict[@"expire"] doubleValue]];
            self.resourceID = offersDict[@"c_id"];
            self.crtType = [offersDict[@"crt_type"] integerValue];
            self.pkgName = offersDict[@"pkg"];
            self.title = offersDict[@"title"];
            self.text = offersDict[@"desc"];
            self.rating = [offersDict[@"rating"] integerValue];
            self.downloadNum = [offersDict[@"dl_num"] integerValue];
            self.commentNum = [offersDict[@"cm_num"] integerValue];
            self.iconURL = offersDict[@"icon_u"];
            if ([self.iconURL isKindOfClass:[NSString class]] && [self.iconURL length] > 0) { [resourceURLs addObject:self.iconURL]; }
            
            self.fullScreenImageURL = offersDict[@"full_u"];
            if (self.fullScreenImageURL.isString && [self.fullScreenImageURL length] > 0) { [resourceURLs addObject:self.fullScreenImageURL]; }
            self.imageList = offersDict[@"img_list"];
//            if (self.imageList.isString && self.imageList.isEmpty == NO) {
//                [resourceURLs addObject:self.imageList];
//            }
            
            self.interstitialType = [offersDict[@"unit_type"] integerValue];
            self.logoURL = offersDict[@"tp_logo_u"];
            self.logoTitle = offersDict[@"ad_logo_title"];
            if ([self.logoURL isKindOfClass:[NSString class]] && [self.logoURL length] > 0) { [resourceURLs addObject:self.logoURL]; }
            self.CTA = offersDict[@"cta"];
            if (self.crtType == ATOfferCrtTypeOneImage && [Utilities isEmpty:self.CTA]) {
                self.CTA = [Utilities localizationForLearnMore];
            }
            self.videoURL = offersDict[@"video_u"];
            if ([self.videoURL isKindOfClass:[NSString class]] && [self.videoURL length] > 0) { [resourceURLs addObject:self.videoURL]; }
            self.videoLength = [offersDict[@"video_l"] integerValue];
            self.videoResolution = offersDict[@"video_r"];
            self.videoSize = offersDict[@"video_s"];
            self.endcardUrl = offersDict[@"ec_u"];
            self.storeURL = offersDict[@"store_u"];
            self.linkType = [offersDict[@"link_type"] integerValue];
            self.clickURL = offersDict[@"click_u"];//
            self.deeplinkUrl = offersDict[@"deeplink"];
            self.jumpUrl = offersDict[@"jump_url"];
            self.ext = offersDict[@"ext"];
//            self.price = offersDict[@"price"];
//            self.bannerXhtml = offersDict[@"banner_xhtml"];

            NSDictionary* trackingDict = offersDict[@"tk"];
            if(trackingDict != nil){
                self.trackingMapDict = trackingDict[@"ks"];
//                self.nTKurl = trackingDict[@"nurl"];
//                self.at_nTKurl = trackingDict[@"tp_nurl"];
                self.impTKUrl = trackingDict[@"imp"];
                self.at_impTKUrl = trackingDict[@"tp_imp"];
                self.clickTKUrl = trackingDict[@"click"];
                self.at_clickTKUrl = trackingDict[@"tp_click"];
                self.videoStartTKUrl = trackingDict[@"vstart"];
                self.at_videoStartTKUrl = trackingDict[@"tp_vstart"];
                self.video25TKUrl = trackingDict[@"v25"];
                self.at_video25TKUrl = trackingDict[@"tp_v25"];
                self.video50TKUrl = trackingDict[@"v50"];
                self.at_video50TKUrl = trackingDict[@"tp_v50"];
                self.video75TKUrl = trackingDict[@"v75"];
                self.at_video75TKUrl = trackingDict[@"tp_v75"];
                self.video100TKUrl = trackingDict[@"v100"];
                self.at_video100TKUrl = trackingDict[@"tp_v100"];
                self.videoPausedTKUrl = trackingDict[@"vpaused"];
                self.at_videoPausedTKUrl = trackingDict[@"tp_vpaused"];
                self.videoResumedTKUrl = trackingDict[@"vresumed"];
                self.at_videoResumedTKUrl = trackingDict[@"tp_vresumed"];
                
                self.videoClickTKUrl = trackingDict[@"vclick"];
                self.at_videoClickTKUrl = trackingDict[@"tp_vclick"];
                self.videoMuteTKUrl = trackingDict[@"vmute"];
                self.at_videoMuteTKUrl = trackingDict[@"tp_vmute"];
                self.videoUnMuteTKUrl = trackingDict[@"vunmute"];
                self.at_videoUnMuteTKUrl = trackingDict[@"tp_vunmute"];
                self.videoSkipTKUrl = trackingDict[@"vskip"];
                self.at_videoSkipTKUrl = trackingDict[@"tp_vskip"];
                self.videoFailedTKUrl = trackingDict[@"vfail"];

                self.endcardShowTKUrl = trackingDict[@"ec_show"];
                self.at_endcardShowTKUrl = trackingDict[@"tp_ec_show"];
                self.endcardCloseUrl = trackingDict[@"ec_close"];
                self.at_endcardCloseUrl = trackingDict[@"tp_ec_close"];
                
                self.deeplinkStartTKUrl = trackingDict[@"dp_start"];
                self.at_deeplinkStartTKUrl = trackingDict[@"tp_dp_start"];
                self.deeplinkSuccessTKUrl = trackingDict[@"dp_succ"];
                self.at_deeplinkSuccessTKUrl = trackingDict[@"tp_dp_succ"];
                
                // v5.7.7
                self.videoRewardedTKUrl = trackingDict[@"vrewarded"];
                self.at_videoRewardedTKUrl = trackingDict[@"tp_vrewarded"];
                self.videoDataLoadedTKUrl = trackingDict[@"vd_succ"];
                self.at_videoDataLoadedTKUrl = trackingDict[@"tp_vd_succ"];
                self.openSchemeFailedTKUrl = trackingDict[@"dp_uninst_fail"];
                self.at_openSchemeFailedTKUrl = trackingDict[@"tp_dp_uninst_fail"];
                
                NSArray *playTKItems = trackingDict[@"v_p_tracking"];
                if (playTKItems.isArray) {
                    NSMutableArray *tks = [NSMutableArray arrayWithCapacity:playTKItems.count];
                    for (NSDictionary *item in playTKItems) {
                        ATVideoPlayingTKItem *tkItem = [[ATVideoPlayingTKItem alloc]initWithDict:item];
                        [tks addObject:tkItem];
                    }
                    self.playingTKItems = tks;
                }
            }

            NSDictionary *ctrlDic = offersDict[@"ctrl"];
            if ([Utilities isEmpty:ctrlDic]) {
                //if ctrl is nil,should use onlineApi setting from placementmodel
                ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:self.placementID];
                ctrlDic = placementModel.adxSettingDict;
            }
            self.onlineApiSetting = [[ATOnlineApiPlacementSetting alloc] initWithPlacementDictionary:ctrlDic infoDictionary:content placementID:self.placementID];
        }
        
        self.resourceURLs = resourceURLs;
        
        self.localResourceID = [NSString stringWithFormat:@"%@%@%@%@%@%@", self.offerID, self.unitID, self.resourceID,self.fullScreenImageURL ? self.fullScreenImageURL : @"",self.videoURL ? self.videoURL : @"",(self.iconURL ? self.iconURL : @"")].md5;
        
        self.offerModelType = ATOfferModelOnlineApi;
        self.displayDuration = 1;
        
        // default: ATOfferCrtTypeOneImageWithText
        self.interActableArea = self.onlineApiSetting.endCardClickable == ATEndCardClickableFullscreen ? ATOfferInterActableAreaAll : ATOfferInterActableAreaVisibleItems;
        
        if (self.crtType == ATOfferCrtTypeOneImage) {
            self.interActableArea = self.onlineApiSetting.endCardClickable == ATEndCardClickableFullscreen ? ATOfferInterActableAreaAll : ATOfferInterActableAreaCTA;
        }
    }
    return self;
}

-(BOOL) isExpired {
//    return [_expireDate timeIntervalSinceDate:[NSDate date]] <= 0;
    return NO;
}

@end
