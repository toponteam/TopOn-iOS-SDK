//
//  ATADXOfferModel.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//


#import "ATADXOfferModel.h"
#import "ATADXPlacementSetting.h"
#import "ATADXAdManager.h"
#import "Utilities.h"
#import "ATPlacementSettingManager.h"

@implementation ATADXOfferModel
- (instancetype) initWithDictionary:(NSDictionary *)dictionary content:(NSDictionary *)content{
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        NSMutableArray<NSString*> *resourceURLs = [NSMutableArray<NSString*> array];
        
        self.expireDate = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"expire_timestamp"] doubleValue]];
        _rtbId = dictionary[@"id"];
        self.placementID = dictionary[@"at_placement_id"];
        self.unitID = dictionary[@"at_unit_id"];
        self.format = [dictionary[@"at_format"] integerValue];
        self.requestID = dictionary[@"at_request_id"];
        NSArray<NSDictionary*>* bidArray = dictionary[@"seatbid"];
        if(bidArray != nil && bidArray.count>0){
            NSDictionary* bidObjDict = [bidArray objectAtIndex:0];
            self.offerID = bidObjDict[@"oid"];
            self.offerFirmID = [bidObjDict[@"offer_firm_id"] integerValue];
            self.price = [[NSString stringWithFormat:@"%@",bidObjDict[@"price"]] fixECPMLoseWithPrice];
            self.resourceID = bidObjDict[@"c_id"];
            self.pkgName = bidObjDict[@"pkg"];
            self.title = bidObjDict[@"title"];
            self.text = bidObjDict[@"desc"];
            self.rating = [bidObjDict[@"rating"] integerValue];
            self.iconURL = bidObjDict[@"icon_u"];
            if ([self.iconURL isKindOfClass:[NSString class]] && [self.iconURL length] > 0) { [resourceURLs addObject:self.iconURL]; }
            self.fullScreenImageURL = bidObjDict[@"full_u"];
            self.imageList = bidObjDict[@"img_list"];
            if ([self.fullScreenImageURL isKindOfClass:[NSString class]] && [self.fullScreenImageURL length] > 0) { [resourceURLs addObject:self.fullScreenImageURL]; }
            self.interstitialType = [bidObjDict[@"unit_type"] integerValue];
            self.logoURL = bidObjDict[@"tp_logo_u"];
            if ([self.logoURL isKindOfClass:[NSString class]] && [self.logoURL length] > 0) { [resourceURLs addObject:self.logoURL]; }
            self.videoURL = bidObjDict[@"video_u"];
            if ([self.videoURL isKindOfClass:[NSString class]] && [self.videoURL length] > 0) { [resourceURLs addObject:self.videoURL]; }
            self.videoLength = [bidObjDict[@"video_l"] integerValue];
            self.videoResolution = bidObjDict[@"video_r"];
            self.endcardUrl = bidObjDict[@"ec_u"];
            self.bannerXhtml = bidObjDict[@"banner_xhtml"];
            self.storeURL = bidObjDict[@"store_u"];
            self.linkType = [bidObjDict[@"link_type"] integerValue];
            self.clickURL = bidObjDict[@"click_u"];
            self.deeplinkUrl = bidObjDict[@"deeplink"];
            self.crtType = [bidObjDict[@"crt_type"] integerValue];
            self.jumpUrl = bidObjDict[@"jump_url"];
            self.CTA = bidObjDict[@"cta"];
            if (self.crtType == ATOfferCrtTypeOneImage && [Utilities isEmpty:self.CTA]) {
                self.CTA = [Utilities localizationForLearnMore];
            }
            NSDictionary* trackingDict = bidObjDict[@"tk"];
            if(trackingDict != nil){
                self.trackingMapDict = trackingDict[@"ks"];
                self.nTKurl = trackingDict[@"nurl"];
                self.at_nTKurl = trackingDict[@"tp_nurl"];
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
                self.videoClickTKUrl = trackingDict[@"vclick"];
                self.at_videoClickTKUrl = trackingDict[@"tp_vclick"];
                self.videoMuteTKUrl = trackingDict[@"vmute"];
                self.at_videoMuteTKUrl = trackingDict[@"tp_vmute"];
                self.videoUnMuteTKUrl = trackingDict[@"vunmute"];
                self.at_videoUnMuteTKUrl = trackingDict[@"tp_vunmute"];
                self.endcardShowTKUrl = trackingDict[@"ec_show"];
                self.at_endcardShowTKUrl = trackingDict[@"tp_ec_show"];
                self.endcardCloseUrl = trackingDict[@"ec_close"];
                self.at_endcardCloseUrl = trackingDict[@"tp_ec_close"];
                self.videoFailTKUrl = trackingDict[@"vfail"];
                self.videoResumedTKUrl = trackingDict[@"vresumed"];
                self.at_videoResumedTKUrl = trackingDict[@"tp_vresumed"];
                self.videoSkipTKUrl = trackingDict[@"vskip"];
                self.at_videoSkipTKUrl = trackingDict[@"tp_vskip"];
                self.deeplinkStartTKUrl = trackingDict[@"dp_start"];
                self.at_deeplinkStartTKUrl = trackingDict[@"tp_dp_start"];
                self.deeplinkSuccessUrl = trackingDict[@"dp_succ"];
                self.at_deeplinkSuccessUrl = trackingDict[@"tp_dp_succ"];
                
                // v5.7.7
                self.videoRewardedTKUrl = trackingDict[@"vrewarded"];
                self.at_videoRewardedTKUrl = trackingDict[@"tp_vrewarded"];
                self.videoDataLoadedTKUrl = trackingDict[@"vd_succ"];
                self.at_videoDataLoadedTKUrl = trackingDict[@"tp_vd_succ"];
                self.openSchemeFailedTKUrl = trackingDict[@"dp_uninst_fail"];
                self.at_openSchemeFailedTKUrl = trackingDict[@"tp_dp_uninst_fail"];
                
                NSArray *playTKItems = trackingDict[@"v_p_tracking"];
                if ([playTKItems isKindOfClass:[NSArray class]]) {
                    NSMutableArray *tks = [NSMutableArray arrayWithCapacity:playTKItems.count];
                    for (NSDictionary *item in playTKItems) {
                        ATVideoPlayingTKItem *tkItem = [[ATVideoPlayingTKItem alloc]initWithDict:item];
                        [tks addObject:tkItem];
                    }
                    self.playingTKItems = tks;
                }
            }
            
            NSDictionary *ctrlDic = bidObjDict[@"ctrl"];
            if ([Utilities isEmpty:ctrlDic]) {
                //if ctrl is nil,should use adx setting from placementmodel
                ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:self.placementID];
                ctrlDic = placementModel.adxSettingDict;
            }
            self.adxSetting = [[ATADXPlacementSetting alloc] initWithPlacementDictionary:ctrlDic infoDictionary:content placementID:self.placementID];
        }
        
        self.resourceURLs = resourceURLs;
        
        self.localResourceID = [NSString stringWithFormat:@"%@%@%@%@%@%@", self.offerID, self.unitID, self.resourceID,self.fullScreenImageURL ? self.fullScreenImageURL : @"",self.videoURL ? self.videoURL : @"",(self.iconURL ? self.iconURL : @"")].md5;
        
        self.offerModelType = ATOfferModelADX;
        
        // default: ATOfferCrtTypeOneImageWithText
        self.interActableArea = self.adxSetting.endCardClickable == ATEndCardClickableFullscreen ? ATOfferInterActableAreaAll : ATOfferInterActableAreaVisibleItems;
        
        if (self.crtType == ATOfferCrtTypeOneImage) {
            self.interActableArea = self.adxSetting.endCardClickable == ATEndCardClickableFullscreen ? ATOfferInterActableAreaAll : ATOfferInterActableAreaCTA;
        }
    }
    return self;
}

-(BOOL) isExpired {
    return [_expireDate timeIntervalSinceDate:[NSDate date]] <= 0;
}

@end
