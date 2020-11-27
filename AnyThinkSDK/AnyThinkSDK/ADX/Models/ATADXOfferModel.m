//
//  ATADXOfferModel.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//


#import "ATADXOfferModel.h"
#import "ATADXPlacementSetting.h"
#import "ATMyOfferCapsManager.h"
#import "Utilities.h"

@implementation ATADXOfferModel
-(instancetype) initWithDictionary:(NSDictionary *)dictionary content:(NSDictionary *)content{
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
            self.price = [[NSString stringWithFormat:@"%@",bidObjDict[@"price"]] fixECPMLoseWithPrice];
            self.resourceID = bidObjDict[@"c_id"];
            self.pkgName = bidObjDict[@"pkg"];
            self.title = bidObjDict[@"title"];
            self.text = bidObjDict[@"desc"];
            self.rating = [bidObjDict[@"rating"] integerValue];
            self.iconURL = bidObjDict[@"icon_u"];
            if ([self.iconURL isKindOfClass:[NSString class]] && [self.iconURL length] > 0) { [resourceURLs addObject:self.iconURL]; }
            self.fullScreenImageURL = bidObjDict[@"full_u"];
            if ([self.fullScreenImageURL isKindOfClass:[NSString class]] && [self.fullScreenImageURL length] > 0) { [resourceURLs addObject:self.fullScreenImageURL]; }
            self.interstitalType = [bidObjDict[@"unit_type"] integerValue];
            self.logoURL = bidObjDict[@"tp_logo_u"];
            if ([self.logoURL isKindOfClass:[NSString class]] && [self.logoURL length] > 0) { [resourceURLs addObject:self.logoURL]; }
            self.CTA = bidObjDict[@"cta"];
            self.videoURL = bidObjDict[@"video_u"];
            if ([self.videoURL isKindOfClass:[NSString class]] && [self.videoURL length] > 0) { [resourceURLs addObject:self.videoURL]; }
            self.videoLength = [bidObjDict[@"video_l"] integerValue];
            self.videoSize = bidObjDict[@"video_r"];
            self.endcardUrl = bidObjDict[@"ec_u"];
            self.bannerXhtml = bidObjDict[@"banner_xhtml"];
            self.storeURL = bidObjDict[@"store_u"];
            self.linkType = [bidObjDict[@"link_type"] integerValue];
            self.clickURL = bidObjDict[@"click_u"];//
            self.deeplinkUrl = bidObjDict[@"deeplink"];
            
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
            }
            if(bidObjDict[@"ctrl"] != nil && [bidObjDict[@"ctrl"] count] > 0){
                //if ctrl is nil,should use adx setting from placementmodel
                self.adxSetting = [[ATADXPlacementSetting alloc] initWithPlacementDictionary:bidObjDict[@"ctrl"] infoDictionary:content placementID:self.placementID];
            }
            
        }
        
        self.resourceURLs = resourceURLs;
        
        self.localResourceID = [NSString stringWithFormat:@"%@%@%@%@%@%@", self.offerID, self.unitID, self.resourceID,self.fullScreenImageURL ? self.fullScreenImageURL : @"",self.videoURL ? self.videoURL : @"",(self.iconURL ? self.iconURL : @"")].md5;
        
        self.offerModelType = ATOfferModelADX;
    }
    return self;
}

-(BOOL) isExpired {
    return [_expireDate timeIntervalSinceDate:[NSDate date]] <= 0;
}

@end
