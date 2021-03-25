//
//  ATADXOfferModel.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOfferModel.h"
#import "ATADXPlacementSetting.h"

@interface ATADXOfferModel : ATOfferModel
-(instancetype) initWithDictionary:(NSDictionary *)dictionary content:(NSDictionary *)content;

@property(nonatomic, readwrite) NSDate *expireDate;

@property(nonatomic, readwrite) NSString *placementID;
@property(nonatomic, readwrite) NSInteger format;
@property(nonatomic, readwrite) NSString *unitID;
@property(nonatomic, readwrite) NSString *requestID;
@property(nonatomic, readwrite) NSString *rtbId;
@property(nonatomic, readwrite) NSString *price;
@property(nonatomic, readwrite) NSInteger videoLength;
@property(nonatomic, readwrite) NSString *videoResolution;
@property(nonatomic, readwrite) NSString *endcardUrl;
@property(nonatomic, readwrite) NSString *bannerXhtml;
@property (nonatomic, copy) NSArray<NSString *> *imageList;

//tk
@property(nonatomic, readwrite) NSDictionary<NSString*,NSString*>* trackingMapDict;
@property(nonatomic, readwrite) NSArray<NSString*>* nTKurl;
@property(nonatomic, readwrite) NSDictionary* at_nTKurl;
@property(nonatomic, readwrite) NSArray<NSString*>* impTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_impTKUrl;
//@property(nonatomic, readwrite) NSArray<NSString*>* clickTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_clickTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* videoStartTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_videoStartTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* video25TKUrl;
@property(nonatomic, readwrite) NSDictionary* at_video25TKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* video50TKUrl;
@property(nonatomic, readwrite) NSDictionary* at_video50TKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* video75TKUrl;
@property(nonatomic, readwrite) NSDictionary* at_video75TKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* video100TKUrl;
@property(nonatomic, readwrite) NSDictionary* at_video100TKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* videoPausedTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_videoPausedTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* videoClickTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_videoClickTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* videoMuteTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_videoMuteTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* videoUnMuteTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_videoUnMuteTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* endcardShowTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_endcardShowTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* endcardCloseUrl;
@property(nonatomic, readwrite) NSDictionary* at_endcardCloseUrl;

@property(nonatomic, readwrite) NSArray<NSString*>* videoFailTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* videoResumedTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_videoResumedTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* videoSkipTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_videoSkipTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* deeplinkStartTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_deeplinkStartTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* deeplinkSuccessUrl;
@property(nonatomic, readwrite) NSDictionary* at_deeplinkSuccessUrl;

@property(nonatomic, readwrite) NSArray<NSString*>* videoRewardedTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_videoRewardedTKUrl;
@property(nonatomic, readwrite) NSArray<NSString*>* videoDataLoadedTKUrl;
@property(nonatomic, readwrite) NSDictionary* at_videoDataLoadedTKUrl;
@property(nonatomic, copy) NSArray<ATVideoPlayingTKItem *> *playingTKItems;
@property(nonatomic, readwrite) NSDictionary* at_openSchemeFailedTKUrl;

//ctrl
@property(nonatomic, readwrite) ATADXPlacementSetting *adxSetting;

@property(nonatomic, readonly, getter=isExpired) BOOL expired;

@end


