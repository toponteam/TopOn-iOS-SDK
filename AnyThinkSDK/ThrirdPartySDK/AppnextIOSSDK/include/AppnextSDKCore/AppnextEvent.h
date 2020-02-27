//
//  AppnextEvent.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 27/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

// Events ID's
static NSString * const kAppnextEventShowRequest = @"show_request";
static NSString * const kAppnextEventAdDisplayed = @"ad_displayed";
static NSString * const kAppnextEventAdNotReady = @"ad_not_ready";
static NSString * const kAppnextEventCacheReady = @"cache_ready";
static NSString * const kAppnextEventCachingError = @"caching_error";
static NSString * const kAppnextEventPlayVideo = @"play_video";
static NSString * const kAppnextEventVideoEnded = @"video_ended";
static NSString * const kAppnextEventVideoError = @"video_error";
static NSString * const kAppnextEventInstallClicked = @"install_clicked";
static NSString * const kAppnextEventInstallClickedPage1 = @"install_clicked_page1";
static NSString * const kAppnextEventInstallClickedPage2 = @"install_clicked_page2";
static NSString * const kAppnextEventVideoPaused = @"video_paused";
static NSString * const kAppnextEventVideoResumed = @"video_resumed";
static NSString * const kAppnextEventAdClosed = @"ad_closed";
static NSString * const kAppnextEventVideoClosedPage2 = @"video_closed_page2";
static NSString * const kAppnextEventVideoTimeToShow = @"time_to_show";
static NSString * const kAppnextEventVideoBrokenLink = @"broken_link";
static NSString * const kAppnextEventAdError = @"ad_error";
static NSString * const kAppnextEventStartLoadingHTML = @"start_loading_html";

// Events Parameters ID's
static NSString * const kAppnextEventParamTID = @"TID";
static NSString * const kAppnextEventParamAUID = @"AUID";
static NSString * const kAppnextEventParamVID = @"VID";
static NSString * const kAppnextEventParamPID = @"PID";
static NSString * const kAppnextEventParamSessionID = @"SessionID";
static NSString * const kAppnextEventParamAdsType = @"AdsType";
static NSString * const kAppnextEventParamBID = @"BID";
static NSString * const kAppnextEventParamCID = @"CID";

@interface AppnextEvent : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *eventParams;

+ (instancetype) createEvent:(NSString *)eventId withParams:(NSDictionary *)params;

- (instancetype) initEvent:(NSString *)eventId;
- (instancetype) initEvent:(NSString *)eventId withParams:(NSDictionary *)params;

- (NSString *) getEventId;
- (NSDate *) getEventTime;

@end
