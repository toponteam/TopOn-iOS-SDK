//
//  ATADXTracker.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXTracker.h"
#import "ATNetworkingManager.h"
#import "ATThreadSafeAccessor.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATOfferSessionRedirector.h"
#import "ATStoreProductViewController.h"
#import "ATOfferWebViewController.h"
#import "ATAgentEvent.h"
#import "ATMyOfferProgressHud.h"
#import <SafariServices/SFSafariViewController.h>
#import "ATCommonOfferTracker.h"

@interface ATADXTracker()<SFSafariViewControllerDelegate>
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* failedEventStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *failedEventStorageAccessor;
@property(nonatomic, readonly) NSMutableArray<ATOfferSessionRedirector*> *redirectors;
@property(nonatomic, readonly) ATThreadSafeAccessor *redirectorsAccessor;
@property(nonatomic, readonly) ATThreadSafeAccessor *storekitStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary *preloadStorekitDict;

@end
static NSString *kFailedEventStorageAddressKey = @"address";
static NSString *kFailedEventStorageParametersKey = @"parameters";

@implementation ATADXTracker

+(instancetype) sharedTracker {
    static ATADXTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[ATADXTracker alloc] init];
    });
    return sharedTracker;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _failedEventStorage = [NSMutableArray<NSDictionary*> array];
        _failedEventStorageAccessor = [ATThreadSafeAccessor new];
        _redirectors = [NSMutableArray<ATOfferSessionRedirector*> array];
        _redirectorsAccessor = [ATThreadSafeAccessor new];
        _storekitStorageAccessor = [ATThreadSafeAccessor new];
        _preloadStorekitDict = [NSMutableDictionary dictionary];
        [self sendArchivedEvents];
    }
    return self;
}

-(void) sendArchivedEvents {
    NSArray<NSDictionary*>* archivedEvents = [NSArray<NSDictionary*> arrayWithContentsOfFile:[ATADXTracker ADXEventArchivePath]];
    [[NSFileManager defaultManager] removeItemAtPath:[ATADXTracker ADXEventArchivePath] error:nil];
    if ([archivedEvents isKindOfClass:[NSArray class]]) {
        [archivedEvents enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSString *address = obj[kFailedEventStorageAddressKey];
                NSDictionary *parameters = obj[kFailedEventStorageParametersKey];
                if ([address isKindOfClass:[NSString class]] && [address length] > 0) {
                    [[ATCommonOfferTracker sharedTracker] sendTKEventWithAddress:address parameters:[parameters isKindOfClass:[NSDictionary class]] ? parameters : nil retry:YES completionHandler:^(BOOL retry){
                        if(retry){
                            [self appendFailedEventWithAddress:address parameters:[parameters isKindOfClass:[NSDictionary class]] ? parameters : nil];
                        }
                    }];
                }
            }
        }];
    }
}

+(NSString*) ADXEventArchivePath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.ADXTKEvents"];
}

//NSDictionary *ADXExtractParameterFromURL(NSURL *URL, NSDictionary *extra) {
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    NSArray<NSString*>*queries = [URL.query componentsSeparatedByString:@"&"];
//    [queries enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSArray<NSString*>* components = [obj componentsSeparatedByString:@"="];
//        if ([components count] == 2) { parameters[components[0]] = components[1]; }
//    }];
//    parameters[@"t"] = [NSString stringWithFormat:@"%@", [Utilities normalizedTimeStamp]];
//    if ([extra[kATOfferTrackerExtraLifeCircleID] isKindOfClass:[NSString class]]) { parameters[@"req_id"] = extra[kATOfferTrackerExtraLifeCircleID]; }
//    if ([extra[kATOfferTrackerExtraScene] isKindOfClass:[NSString class]]) { parameters[@"scenario"] = extra[kATOfferTrackerExtraScene]; }
//    return parameters;
//}
//
//NSString *ADXExtractAddressFromURL(NSURL *URL) {
//    NSString *address = [NSString stringWithFormat:@"%@://%@%@", URL.scheme, URL.host, URL.path];
//    return address;
//}

NSArray<NSURL*>* ADXBuildTKURL(ATADXOfferModel *offerModel, ATADXTrackerEvent event, NSDictionary *extra) {
    NSMutableArray *urlArrays = [NSMutableArray array];
    __block NSArray<NSString*> *tkURLStrArray = ADXRetrieveTKURL(offerModel, event);
    if (tkURLStrArray.count > 0) {
        for (int i = 0; i < tkURLStrArray.count; i++) {
            __block NSString *tkUrl = tkURLStrArray[i];
            [offerModel.trackingMapDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                tkUrl = [tkUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:obj];
            }];
            if ([Utilities isEmpty:tkUrl] == NO) {
                NSURL *url = [NSURL URLWithString:tkUrl];
                if ([Utilities isEmpty:url]) {
                    url = [NSURL URLWithString:[tkUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                }
                if ([Utilities isEmpty:url] == NO) {
                    [urlArrays addObject:url];
                }
            }
        }
    }
    return urlArrays;
}

NSArray<NSString*>* ADXRetrieveTKURL(ATADXOfferModel *offerModel, ATADXTrackerEvent event) {
    return @{@(ATADXTrackerEventVideoStart):offerModel.videoStartTKUrl.count > 0 ? offerModel.videoStartTKUrl : @[],
             @(ATADXTrackerEventVideo25Percent):offerModel.video25TKUrl.count > 0 ? offerModel.video25TKUrl : @[],
             @(ATADXTrackerEventVideo50Percent):offerModel.video50TKUrl.count > 0 ? offerModel.video50TKUrl : @[],
             @(ATADXTrackerEventVideo75Percent):offerModel.video75TKUrl.count > 0 ? offerModel.video75TKUrl : @[],
             @(ATADXTrackerEventVideoEnd):offerModel.video100TKUrl.count > 0 ? offerModel.video100TKUrl : @[],
             @(ATADXTrackerEventImpression):offerModel.impTKUrl.count > 0 ? offerModel.impTKUrl : @[],
             @(ATADXTrackerEventClick):offerModel.clickTKUrl.count > 0 ? offerModel.clickTKUrl : @[],
             @(ATADXTrackerEventVideoClick):offerModel.videoClickTKUrl.count > 0 ? offerModel.videoClickTKUrl : @[],
             @(ATADXTrackerEventEndCardShow):offerModel.endcardShowTKUrl.count > 0 ? offerModel.endcardShowTKUrl : @[],
             @(ATADXTrackerEventEndCardClose):offerModel.endcardCloseUrl.count > 0 ? offerModel.endcardCloseUrl : @[],
             @(ATADXTrackerEventVideoMute):offerModel.videoMuteTKUrl.count > 0 ? offerModel.videoMuteTKUrl : @[],
             @(ATADXTrackerEventVideoUnMute):offerModel.videoUnMuteTKUrl.count > 0 ? offerModel.videoUnMuteTKUrl : @[],
             @(ATADXTrackerEventVideoPaused):offerModel.videoPausedTKUrl.count > 0 ? offerModel.videoPausedTKUrl : @[],
             @(ATADXTrackerEventNTKurl):offerModel.nTKurl.count > 0 ? offerModel.nTKurl : @[],
             @(ATADXTrackerEventVideoResumed):offerModel.videoResumedTKUrl.count > 0 ? offerModel.videoResumedTKUrl : @[],
             @(ATADXTrackerEventVideoSkip):offerModel.videoSkipTKUrl.count > 0 ? offerModel.videoSkipTKUrl : @[],
             @(ATADXTrackerEventVideoPlayFail):offerModel.videoFailTKUrl.count > 0 ? offerModel.videoFailTKUrl : @[],
             @(ATADXTrackerEventVideoDeeplinkStart):offerModel.deeplinkStartTKUrl.count > 0 ? offerModel.deeplinkStartTKUrl : @[],
             @(ATADXTrackerEventVideoDeeplinkSuccess):offerModel.deeplinkSuccessUrl.count > 0 ? offerModel.deeplinkSuccessUrl : @[],
             @(ATADXTrackerEventVideoRewarded): offerModel.videoRewardedTKUrl.count > 0 ? offerModel.videoRewardedTKUrl : @[],
             @(ATADXTrackerEventVideoLoaded): offerModel.videoDataLoadedTKUrl.count > 0 ? offerModel.videoDataLoadedTKUrl : @[],

    }[@(event)];
}

NSDictionary* ADXRetrievetTPTKDict(ATADXOfferModel *offerModel, ATADXTrackerEvent event) {
    return @{@(ATADXTrackerEventVideoStart):offerModel.at_videoStartTKUrl != nil ? offerModel.at_videoStartTKUrl : @{},
             @(ATADXTrackerEventVideo25Percent):offerModel.at_video25TKUrl != nil ? offerModel.at_video25TKUrl : @{},
             @(ATADXTrackerEventVideo50Percent):offerModel.at_video50TKUrl != nil ? offerModel.at_video50TKUrl : @{},
             @(ATADXTrackerEventVideo75Percent):offerModel.at_video75TKUrl != nil ? offerModel.at_video75TKUrl : @{},
             @(ATADXTrackerEventVideoEnd):offerModel.at_video100TKUrl != nil ? offerModel.at_video100TKUrl : @{},
             @(ATADXTrackerEventImpression):offerModel.at_impTKUrl != nil ? offerModel.at_impTKUrl : @{},
             @(ATADXTrackerEventClick):offerModel.at_clickTKUrl != nil ? offerModel.at_clickTKUrl : @{},
             @(ATADXTrackerEventVideoClick):offerModel.at_videoClickTKUrl != nil ? offerModel.at_videoClickTKUrl : @{},
             @(ATADXTrackerEventEndCardShow):offerModel.at_endcardShowTKUrl != nil ? offerModel.at_endcardShowTKUrl : @{},
             @(ATADXTrackerEventEndCardClose):offerModel.at_endcardCloseUrl != nil ? offerModel.at_endcardCloseUrl : @{},
             @(ATADXTrackerEventVideoMute):offerModel.at_videoMuteTKUrl != nil ? offerModel.at_videoMuteTKUrl : @{},
             @(ATADXTrackerEventVideoUnMute):offerModel.at_videoUnMuteTKUrl != nil ? offerModel.at_videoUnMuteTKUrl : @{},
             @(ATADXTrackerEventVideoPaused):offerModel.at_videoPausedTKUrl != nil ? offerModel.at_videoPausedTKUrl : @{},
             @(ATADXTrackerEventNTKurl):offerModel.at_nTKurl != nil ? offerModel.at_nTKurl : @{},
             @(ATADXTrackerEventVideoResumed):offerModel.at_videoResumedTKUrl.count > 0 ? offerModel.at_videoResumedTKUrl : @{},
             @(ATADXTrackerEventVideoSkip):offerModel.at_videoSkipTKUrl.count > 0 ? offerModel.at_videoSkipTKUrl : @{},
             @(ATADXTrackerEventVideoDeeplinkStart):offerModel.at_deeplinkStartTKUrl.count > 0 ? offerModel.at_deeplinkStartTKUrl : @{},
             @(ATADXTrackerEventVideoDeeplinkSuccess):offerModel.at_deeplinkSuccessUrl.count > 0 ? offerModel.at_deeplinkSuccessUrl : @{},
             @(ATADXTrackerEventVideoRewarded): offerModel.at_videoRewardedTKUrl.count > 0 ? offerModel.at_videoRewardedTKUrl : @{},
             @(ATADXTrackerEventVideoLoaded): offerModel.at_videoDataLoadedTKUrl.count > 0 ? offerModel.at_videoDataLoadedTKUrl : @{}
    }[@(event)];
}

- (void)trackWithUrls:(NSArray<NSString *> *)urls offerModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    
    if ([Utilities isEmpty:urls]) {
        return;
    }
    NSArray<NSURL *> *kUrls = [self getProcessedUrlsWithUlrStrings:urls model:offerModel event:0 extra:extra];
    if (kUrls.count) {
        [[ATCommonOfferTracker sharedTracker] sendNoticeWithUrls:kUrls completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error) {
            
        }];
    }
}

-(void) trackEvent:(ATADXTrackerEvent)event offerModel:(ATADXOfferModel*)offerModel extra:(NSDictionary*)extra {
    //send network notice url
//    NSArray<NSURL*>* tkURLs = ADXBuildTKURL(offerModel, event, extra);
//    if (tkURLs.count > 0) {
//        [[ATCommonOfferTracker sharedTracker] sendNoticeWithUrls:tkURLs completion:nil];
//    }
    NSArray<NSString*> *tkURLStrArray = ADXRetrieveTKURL(offerModel, event);
    NSArray<NSURL *> *kUrls = [self getProcessedUrlsWithUlrStrings:tkURLStrArray model:offerModel event:event extra:extra];
    if (kUrls) {
        [[ATCommonOfferTracker sharedTracker] sendNoticeWithUrls:kUrls completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error) {
            
        }];
    }
    
    //sent tk notice url

    NSMutableDictionary *tkMapDict = [NSMutableDictionary dictionaryWithCapacity:0];
    if ([Utilities isEmpty:offerModel.trackingMapDict] == NO) {
        [tkMapDict addEntriesFromDictionary:offerModel.trackingMapDict];
    }

    NSDictionary *tpTKDict = ADXRetrievetTPTKDict(offerModel, event);
    if (tpTKDict.count>0 && [ATAppSettingManager sharedManager].adxSetting.trackerHttpAdress != nil) {
        [tkMapDict addEntriesFromDictionary:tpTKDict];
        [[ATCommonOfferTracker sharedTracker] sendTKEventWithAddress:[ATAppSettingManager sharedManager].adxSetting.trackerHttpAdress parameters:tkMapDict retry:YES completionHandler:^(BOOL retry){
            if(retry){
                [self appendFailedEventWithAddress:[ATAppSettingManager sharedManager].adxSetting.trackerHttpAdress parameters:tkMapDict];
            }
        }];
    }
}

-(void) appendFailedEventWithAddress:(NSString*)address parameters:(NSDictionary*)parameters {
    if ([address length] > 0) {
        __weak typeof(self) weakSelf = self;
        [_failedEventStorageAccessor writeWithBlock:^{
            NSMutableDictionary *eventDict = [NSMutableDictionary dictionaryWithObject:address forKey:kFailedEventStorageAddressKey];
            if ([parameters count] > 0) { eventDict[kFailedEventStorageParametersKey] = parameters; }
            [weakSelf.failedEventStorage addObject:eventDict];
            [weakSelf.failedEventStorage writeToFile:[ATADXTracker ADXEventArchivePath] atomically:YES];
        }];
    }
}

NSString *ADXAppendLifeCircleIDToURL(NSString *URL, NSString *lifeCircleID) {
    return [lifeCircleID isKindOfClass:[NSString class]] ? ([URL stringByReplacingOccurrencesOfString:@"{req_id}" withString:lifeCircleID]) : URL;
}

-(void) clickOfferWithOfferModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting *)setting extra:(NSDictionary*)extra  clickCallbackHandler:(void (^ __nullable)(BOOL success))clickCallback{
    [self clickOfferWithOfferModel:offerModel setting:setting extra:extra skDelegate:nil viewController:nil circleId:nil clickCallbackHandler:clickCallback];
}

-(void) clickOfferWithOfferModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting *)setting extra:(NSDictionary*)extra skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController circleId:(NSString *) circleId  clickCallbackHandler:(void (^ __nullable)(BOOL success))clickCallback {
    [[ATCommonOfferTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:setting circleID:circleId delegate:skDelegate viewController:viewController  extra:extra clickCallbackHandler:^(ATClickType clickType, BOOL isEnd, BOOL success) {
        if (clickCallback && (clickType == ATClickTypeDeepLinkUrl || ATClickTypeClickJumpUrl) && isEnd) {
            clickCallback(success);
        }
    }];
}

-(void)preloadStorekitForOfferModel:(ATADXOfferModel *)offerModel setting:(ATADXPlacementSetting *) setting viewController:(UIViewController *)viewController circleId:(NSString *) circleId  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate {
    [[ATCommonOfferTracker sharedTracker] preloadStorekitForOfferModel:offerModel setting:setting viewController:viewController circleId:circleId skDelegate:skDelegate];
}

-(void)presentStorekitViewControllerWithCircleId:(NSString *) circleId offerModel:(ATADXOfferModel *)offerModel pkgName:(NSString *) pkgName placementID:(NSString *)placementID offerID:(NSString *)offerID  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController {
    [[ATCommonOfferTracker sharedTracker] presentStorekitViewControllerWithCircleId:circleId offerModel:offerModel pkgName:pkgName placementID:placementID offerID:offerID skDelegate:skDelegate viewController:viewController];
}

// MARK:- SFSafariViewControllerDelegate
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:true completion:^{
        
    }];
}

- (void)safariViewController:(SFSafariViewController *)controller initialLoadDidRedirectToURL:(NSURL *)URL {
    NSLog(@"redirect to: %@",URL.absoluteString);
}

// MARK:- private
- (NSArray<NSURL *> *)getProcessedUrlsWithUlrStrings:(NSArray<NSString *> *)tkUrlStrings model:(ATADXOfferModel *)model event:(ATADXTrackerEvent)event extra:(NSDictionary*)extra {
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
                                       @"{__STATUS__}":event == ATADXTrackerEventVideoPlayFail ? @"2":@"0"
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
