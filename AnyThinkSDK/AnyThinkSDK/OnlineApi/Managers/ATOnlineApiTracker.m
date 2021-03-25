//
//  ATOnlineApiTracker.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiTracker.h"
#import "ATOnlineApiOfferModel.h"
#import "NSArray+KAKit.h"
#import "NSDictionary+KAKit.h"
#import "ATAppSettingManager.h"
#import "ATNetworkingManager.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATOfferSessionRedirector.h"
#import "NSObject+KAKit.h"
#import "ATOfferWebViewController.h"
#import <SafariServices/SFSafariViewController.h>
#import "ATOnlineApiPlacementSetting.h"
#import "ATStoreProductViewController.h"
#import "ATMyOfferProgressHud.h"
#import "ATAgentEvent.h"
#import "ATCommonOfferTracker.h"

static NSString *kFailedEventStorageAddressKey = @"address";
static NSString *kFailedEventStorageParametersKey = @"parameters";

@interface ATOnlineApiTracker ()
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* failedEventStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *failedEventStorageAccessor;
@property(nonatomic, readonly) ATThreadSafeAccessor *redirectorsAccessor;
@property(nonatomic, readonly) NSMutableArray<ATOfferSessionRedirector*> *redirectors;
@property(nonatomic, readonly) ATThreadSafeAccessor *storekitStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString *, ATStoreProductViewController *> *preloadStorekitDict;

@end
@implementation ATOnlineApiTracker

// MARK:- initialization

+(instancetype) sharedTracker {
    static ATOnlineApiTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[ATOnlineApiTracker alloc] init];
    });
    return sharedTracker;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _failedEventStorage = [NSMutableArray<NSDictionary*> array];
        _redirectorsAccessor = [ATThreadSafeAccessor new];
        _redirectors = [NSMutableArray<ATOfferSessionRedirector*> array];
        _storekitStorageAccessor = [ATThreadSafeAccessor new];
        _preloadStorekitDict = [NSMutableDictionary dictionary];

        [self sendArchivedEvent];

    }
    return self;
}

// MARK:- functions claimed in .h
- (void)trackWithUrls:(NSArray<NSString *> *)urls offerModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    
    if ([Utilities isEmpty:urls]) {
        return;
    }
    NSArray<NSURL *> *kUrls = [self getProcessedUrlsWithUlrStrings:urls model:offerModel event:0 extra:extra];
    if (kUrls.count) {
        [[ATCommonOfferTracker sharedTracker] sendNoticeWithUrls:kUrls completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error) {
            
        }];
    }
    
}

- (void)trackEvent:(ATOnlineApiTrackerEvent)event offerModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    
    NSArray<NSURL *> *urls = [self getTKURLsArrWithEvent:event model:offerModel extra:extra];
    if (urls.count) {
        [[ATCommonOfferTracker sharedTracker] sendNoticeWithUrls:urls completion:nil];
    }
    
    NSString *address = [ATAppSettingManager sharedManager].onlineApiSetting.trackerHttpAdress;
    NSDictionary *tpTKDict = [self getTPTKDicsWithEvent:event model:offerModel];
    
    if ([Utilities isEmpty:tpTKDict] ||
        address == nil) {
        return;
    }
    NSMutableDictionary *tkMapDict = offerModel.trackingMapDict.mutableCopy;
    [tkMapDict addEntriesFromDictionary:tpTKDict];
    
    [[ATCommonOfferTracker sharedTracker] sendTKEventWithAddress:address parameters:tkMapDict retry:YES completionHandler:^(BOOL retry){
        if(retry){
            [self appendFailedEventWithAddress:address parameters:tkMapDict];
        }
    }];
    
}

/**
 click offer with redirect url
 */
- (void)clickOfferWithOfferModel:(ATOnlineApiOfferModel *)model setting:(ATOnlineApiPlacementSetting *)setting circleID:(NSString *)cid delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)pc extra:(NSDictionary*)extra clickCallbackHandler:(void (^ __nullable)(BOOL success))kClickCallback {
    [[ATCommonOfferTracker sharedTracker] clickOfferWithOfferModel:model setting:setting circleID:cid delegate:delegate viewController:pc extra:extra clickCallbackHandler:^(ATClickType clickType, BOOL isEnd, BOOL success) {
        //TODO send deeplink notice
        if(clickType == ATClickTypeDeepLinkUrl){
            if(!isEnd && !success){
                [self trackEvent:ATOnlineApiTrackerEventVideoDeeplinkStart offerModel:model extra:extra];
            }
            if(isEnd){
                if (success) {
                    [self trackEvent:ATOnlineApiTrackerEventVideoDeeplinkSuccess offerModel:model extra:extra];
                }
                if (kClickCallback) {
                    kClickCallback(success);
                }
            }
        }
        
        if (clickType == ATClickTypeClickJumpUrl &&
            kClickCallback &&
            isEnd) {
            kClickCallback(success);
        }
    }];
}

- (void)preloadStorekitForOfferModel:(ATOnlineApiOfferModel *)model setting:(ATOnlineApiPlacementSetting *)setting  viewController:(UIViewController *)viewController circleId:(NSString *)cid skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate {
    [[ATCommonOfferTracker sharedTracker] preloadStorekitForOfferModel:model setting:setting viewController:viewController circleId:cid skDelegate:skDelegate];
    
}

- (void)presentStorekitViewControllerWithCircleId:(NSString *)cid offerModel:(ATOnlineApiOfferModel *)offerModel pkgName:(NSString *)pkgName placementID:(NSString *)placementID offerID:(NSString *)offerID  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController {
    [[ATCommonOfferTracker sharedTracker] presentStorekitViewControllerWithCircleId:cid offerModel:offerModel pkgName:pkgName placementID:placementID offerID:offerID skDelegate:skDelegate viewController:viewController];
}

- (void)sendArchivedEvent {
    NSString *localPath = [self onlineApiEventArchivePath];
    NSArray<NSDictionary *> *archivedEvents = [NSArray<NSDictionary *> arrayWithContentsOfFile:localPath];
    [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
    if ([archivedEvents isArray] == NO) {
        return;
    }
    
    for (NSDictionary *dict in archivedEvents) {
        if (dict.isDictionary) {
            NSString *address = dict[kFailedEventStorageAddressKey];
            NSDictionary *parameters = dict[kFailedEventStorageParametersKey];
            if (parameters.isDictionary == NO) {
                parameters = nil;
            }
            if ([Utilities isEmpty:address]) {
                [[ATCommonOfferTracker sharedTracker] sendTKEventWithAddress:address parameters:parameters retry:YES completionHandler:^(BOOL retry){
                    if(retry){
                        [self appendFailedEventWithAddress:address parameters:parameters];
                    }
                }];
            }
        }
    }
}

- (void)appendFailedEventWithAddress:(NSString*)address parameters:(NSDictionary*)parameters {
    if ([address length] > 0) {
        [_failedEventStorageAccessor writeWithBlock:^{
            NSMutableDictionary *eventDict = [NSMutableDictionary dictionaryWithObject:address forKey:kFailedEventStorageAddressKey];
            if ([parameters count] > 0) { eventDict[kFailedEventStorageParametersKey] = parameters;
            }
            [self.failedEventStorage addObject:eventDict];
            [self.failedEventStorage writeToFile:[self onlineApiEventArchivePath] atomically:YES];
        }];
    }
}

- (NSArray<NSURL *> *)getTKURLsArrWithEvent:(ATOnlineApiTrackerEvent)event model:(ATOnlineApiOfferModel *)model extra:(NSDictionary *)extra {
    
    NSArray<NSString *> *tkUrlStrings = [self getTKURLStringsWithEvent:event model:model];
    if ([Utilities isEmpty:tkUrlStrings]) {
        return nil;
    }
    
    NSArray<NSURL *> *urls = [self getProcessedUrlsWithUlrStrings:tkUrlStrings model:model event:event extra:extra];
    return urls;
}

- (NSArray<NSString *> *)getTKURLStringsWithEvent:(ATOnlineApiTrackerEvent)event model:(ATOnlineApiOfferModel *)model {
    switch (event) {
        case ATOnlineApiTrackerEventVideoStart:
            return model.videoStartTKUrl;
        case ATOnlineApiTrackerEventVideo25Percent:
            return model.video25TKUrl;
        case ATOnlineApiTrackerEventVideo50Percent:
            return model.video50TKUrl;
        case ATOnlineApiTrackerEventVideo75Percent:
            return model.video75TKUrl;
        case ATOnlineApiTrackerEventVideoEnd:
            return model.video100TKUrl;
        case ATOnlineApiTrackerEventImpression:
            return model.impTKUrl;
        case ATOnlineApiTrackerEventClick:
            return model.clickTKUrl;
        case ATOnlineApiTrackerEventVideoClick:
            return model.videoClickTKUrl;
        case ATOnlineApiTrackerEventEndCardShow:
            return model.endcardShowTKUrl;
        case ATOnlineApiTrackerEventEndCardClose:
            return model.endcardCloseUrl;
        case ATOnlineApiTrackerEventVideoMute:
            return model.videoMuteTKUrl;
        case ATOnlineApiTrackerEventVideoUnMute:
            return model.videoUnMuteTKUrl;
        case ATOnlineApiTrackerEventVideoPaused:
            return model.videoPausedTKUrl;
        case ATOnlineApiTrackerEventVideoResumed:
            return model.videoResumedTKUrl;
        case ATOnlineApiTrackerEventVideoSkip:
            return model.videoSkipTKUrl;
        case ATOnlineApiTrackerEventVideoPlayFail:
            return model.videoFailedTKUrl;
        case ATOnlineApiTrackerEventVideoDeeplinkStart:
            return model.deeplinkStartTKUrl;
        case ATOnlineApiTrackerEventVideoDeeplinkSuccess:
            return model.deeplinkSuccessTKUrl;
        case ATOnlineApiTrackerEventVideoRewarded:
            return model.videoRewardedTKUrl;
        case ATOnlineApiTrackerEventVideoLoaded:
            return model.videoDataLoadedTKUrl;
//        case ATOnlineApiTrackerEventVideoPlaying:
//            return @[];
        default:
            break;
    }
}

- (NSDictionary *)getTPTKDicsWithEvent:(ATOnlineApiTrackerEvent)event model:(ATOnlineApiOfferModel *)model {
    switch (event) {
        case ATOnlineApiTrackerEventVideoStart:
            return model.at_videoStartTKUrl;
        case ATOnlineApiTrackerEventVideo25Percent:
            return model.at_video25TKUrl;
        case ATOnlineApiTrackerEventVideo50Percent:
            return model.at_video50TKUrl;
        case ATOnlineApiTrackerEventVideo75Percent:
            return model.at_video75TKUrl;
        case ATOnlineApiTrackerEventVideoEnd:
            return model.at_video100TKUrl;
        case ATOnlineApiTrackerEventImpression:
            return model.at_impTKUrl;
        case ATOnlineApiTrackerEventClick:
            return model.at_clickTKUrl;
        case ATOnlineApiTrackerEventVideoClick:
            return model.at_videoClickTKUrl;
        case ATOnlineApiTrackerEventEndCardShow:
            return model.at_endcardShowTKUrl;
        case ATOnlineApiTrackerEventEndCardClose:
            return model.at_endcardCloseUrl;
        case ATOnlineApiTrackerEventVideoMute:
            return model.at_videoMuteTKUrl;
        case ATOnlineApiTrackerEventVideoUnMute:
            return model.at_videoUnMuteTKUrl;
        case ATOnlineApiTrackerEventVideoPaused:
            return model.at_videoPausedTKUrl;
        case ATOnlineApiTrackerEventVideoResumed:
            return model.at_videoResumedTKUrl;
        case ATOnlineApiTrackerEventVideoSkip:
            return model.at_videoSkipTKUrl;
        case ATOnlineApiTrackerEventVideoDeeplinkStart:
            return model.at_deeplinkStartTKUrl;
        case ATOnlineApiTrackerEventVideoDeeplinkSuccess:
            return model.at_deeplinkSuccessTKUrl;
        case ATOnlineApiTrackerEventVideoPlayFail:
            return @{};
//        case ATOnlineApiTrackerEventNTKurl:
//            return model.at_nTKurl;
        case ATOnlineApiTrackerEventVideoRewarded:
            return model.at_videoRewardedTKUrl;
        case ATOnlineApiTrackerEventVideoLoaded:
            return model.at_videoDataLoadedTKUrl;
//        case ATOnlineApiTrackerEventVideoPlaying:
//            return @{};
        default:
            break;
    }
}

- (NSString *)onlineApiEventArchivePath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.OnlineTKEvents"];
}


// MARK:- private
- (NSArray<NSURL *> *)getProcessedUrlsWithUlrStrings:(NSArray<NSString *> *)tkUrlStrings model:(ATOnlineApiOfferModel *)model event:(ATOnlineApiTrackerEvent)event extra:(NSDictionary*)extra {
    NSMutableArray *urls = [[NSMutableArray alloc]initWithCapacity:tkUrlStrings.count];
    for (NSString *item in tkUrlStrings) {
        NSString *finalItem = item;
        if ([Utilities isEmpty:model.trackingMapDict] == NO) {
            for (NSString *key in model.trackingMapDict.allKeys) {
                @autoreleasepool {
                    NSString *replaceKey = [NSString stringWithFormat:@"{%@}",key];
                    finalItem = [finalItem stringByReplacingOccurrencesOfString:replaceKey withString:model.trackingMapDict[key]];
                }
            }
        }
        
        // for video
        NSDictionary *infoForVideo = @{@"{__VIDEO_TIME__}":@(model.videoLength).stringValue,
                                       @"{__BEGIN_TIME__}":@(model.videoResumeTime).stringValue,
                                       @"{__END_TIME__}":@(model.videoCurrentTime).stringValue,
                                       @"{__PLAY_FIRST_FRAME__}":model.videoResumeTime > 0 ? @"0" : @"1",
                                       @"{__PLAY_LAST_FRAME__}":(model.videoLength <= model.videoCurrentTime + model.videoResumeTime) ? @"1" : @"0",
                                       @"{__SCENE__}":@"2",
                                       @"{__TYPE__}":model.videoResumeTime > 0 ? @"2":@"1",
                                       @"{__BEHAVIOR__}":@"1",
                                       @"{__STATUS__}":event == ATOnlineApiTrackerEventVideoPlayFail ? @"2":@"0"
        };
        for (NSString *key in infoForVideo) {
            finalItem = [finalItem stringByReplacingOccurrencesOfString:key withString:infoForVideo[key]];
        }
        
        for (NSString *key in extra) {
            NSString *value = [NSString stringWithFormat:@"%@",extra[key]];
            finalItem = [finalItem stringByReplacingOccurrencesOfString:key withString:value];
        }
        
        for (NSString *key in model.tapInfoDict) {
            NSString *value = [NSString stringWithFormat:@"%@",model.tapInfoDict[key]];
            finalItem = [finalItem stringByReplacingOccurrencesOfString:key withString: value];
        }
        
        NSTimeInterval timeInterval = (NSInteger)[[NSDate date] timeIntervalSince1970];
        finalItem = [finalItem stringByReplacingOccurrencesOfString:kATOfferTrackerTimestamp withString:@(timeInterval).stringValue];
        finalItem = [finalItem stringByReplacingOccurrencesOfString:kATOfferTrackerMilliTimestamp withString:@(timeInterval * 1000).stringValue];
        finalItem = [finalItem stringByReplacingOccurrencesOfString:kATOfferTrackerEndTimestamp withString:@(timeInterval).stringValue];
        finalItem = [finalItem stringByReplacingOccurrencesOfString:kATOfferTrackerEndMilliTimestamp withString:@(timeInterval * 1000).stringValue];
        
        finalItem = [finalItem stringByReplacingOccurrencesOfString:@"{" withString:@""];
        finalItem = [finalItem stringByReplacingOccurrencesOfString:@"}" withString:@""];
        
        NSURL *url = [NSURL URLWithString:finalItem];
        if ([Utilities isEmpty:url]) {
            url = [NSURL URLWithString:[finalItem stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }
        if ([Utilities isEmpty:url] == NO) {
            [urls addObject:url];
        }
    }
    model.tapInfoDict = nil;
    return urls;
}
@end
