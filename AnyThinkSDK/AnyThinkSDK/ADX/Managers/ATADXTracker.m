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

NSString *const kATADXTrackerExtraLifeCircleID = @"adx_life_circle_id";
NSString *const kATADXTrackerExtraScene = @"adx_scene";
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
                    [self sendTKEventWithAddress:address parameters:[parameters isKindOfClass:[NSDictionary class]] ? parameters : nil retry:YES];
                }
            }
        }];
    }
}

+(NSString*) ADXEventArchivePath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.ADXTKEvents"];
}

NSDictionary *ADXExtractParameterFromURL(NSURL *URL, NSDictionary *extra) {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray<NSString*>*queries = [URL.query componentsSeparatedByString:@"&"];
    [queries enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString*>* components = [obj componentsSeparatedByString:@"="];
        if ([components count] == 2) { parameters[components[0]] = components[1]; }
    }];
    parameters[@"t"] = [NSString stringWithFormat:@"%@", [Utilities normalizedTimeStamp]];
    if ([extra[kATADXTrackerExtraLifeCircleID] isKindOfClass:[NSString class]]) { parameters[@"req_id"] = extra[kATADXTrackerExtraLifeCircleID]; }
    if ([extra[kATADXTrackerExtraScene] isKindOfClass:[NSString class]]) { parameters[@"scenario"] = extra[kATADXTrackerExtraScene]; }
    return parameters;
}

NSString *ADXExtractAddressFromURL(NSURL *URL) {
    NSString *address = [NSString stringWithFormat:@"%@://%@%@", URL.scheme, URL.host, URL.path];
    return address;
}

NSArray<NSURL*>* ADXBuildTKURL(ATADXOfferModel *offerModel, ATADXTrackerEvent event, NSDictionary *extra) {
    NSMutableArray *urlArrays = [NSMutableArray array];
    __block NSArray<NSString*> *tkURLStrArray = ADXRetrieveTKURL(offerModel, event);
    if (tkURLStrArray.count > 0) {
        for (int i = 0; i < tkURLStrArray.count; i++) {
            __block NSString *tkUrl = tkURLStrArray[i];
            [offerModel.trackingMapDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                tkUrl = [tkUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:obj];
            }];
            if (tkUrl.length > 0) {
                NSURL *url = [NSURL URLWithString:[tkUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                if (url != nil) {
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
             @(ATADXTrackerEventNTKurl):offerModel.nTKurl.count > 0 ? offerModel.nTKurl : @[]
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
             @(ATADXTrackerEventNTKurl):offerModel.at_nTKurl != nil ? offerModel.at_nTKurl : @{}
    }[@(event)];
}

-(void) trackEvent:(ATADXTrackerEvent)event offerModel:(ATADXOfferModel*)offerModel extra:(NSDictionary*)extra {
    NSArray<NSURL*>* tkURLs = ADXBuildTKURL(offerModel, event, extra);
    if (tkURLs.count > 0) {
        __weak typeof(self) weakSelf = self;
        [tkURLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf.redirectorsAccessor writeWithBlock:^{
                __weak __block ATOfferSessionRedirector *weakRedirector = nil;
                __block ATOfferSessionRedirector *redirector = [ATOfferSessionRedirector redirectorWithURL:obj completion:^(NSURL *finalURL, NSError *error) {
                    [weakSelf.redirectorsAccessor writeWithBlock:^{
                        [weakSelf.redirectors removeObject:weakRedirector];
                    }];
                }];
                weakRedirector = redirector;
                [weakSelf.redirectors addObject:redirector];
            }];
        }];
    }

    //topon tk http
    NSMutableDictionary *tkMapDict = [NSMutableDictionary dictionaryWithDictionary:offerModel.trackingMapDict];
    NSDictionary *tpTKDict = ADXRetrievetTPTKDict(offerModel, event);
    if (tpTKDict.count>0 && [ATAppSettingManager sharedManager].adxSetting.trackerHttpAdress != nil) {
        [tkMapDict addEntriesFromDictionary:tpTKDict];
        [self sendTKEventWithAddress:[ATAppSettingManager sharedManager].adxSetting.trackerHttpAdress parameters:tkMapDict retry:YES];
    }
}

-(void) sendTKEventWithAddress:(NSString*)address parameters:(NSDictionary*)parameters retry:(BOOL)retry{
    [[ATNetworkingManager sharedManager] sendHTTPRequestToAddress:address HTTPMethod:ATNetworkingHTTPMethodPOST parameters:parameters gzip:NO completion:^(NSData * _Nonnull data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (retry && (error.code == NSURLErrorNetworkConnectionLost || error.code == NSURLErrorNotConnectedToInternet || error.code == 53)) {
            [self appendFailedEventWithAddress:address parameters:parameters];
        }
    }];
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

-(void) impressionOfferWithOfferModel:(ATADXOfferModel*)offerModel extra:(NSDictionary*)extra {
    if (offerModel.impTKUrl.count > 0) {
        __weak typeof(self) weakSelf = self;
        [offerModel.impTKUrl enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf.redirectorsAccessor writeWithBlock:^{
                __weak __block ATOfferSessionRedirector *weakRedirector = nil;
                __block ATOfferSessionRedirector *redirector = [ATOfferSessionRedirector redirectorWithURL:[NSURL URLWithString:obj] completion:^(NSURL *finalURL, NSError *error) {
                    [weakSelf.redirectorsAccessor writeWithBlock:^{
                        [weakSelf.redirectors removeObject:weakRedirector];
                    }];
                }];
                weakRedirector = redirector;
                [weakSelf.redirectors addObject:redirector];
            }];
        }];
    }
}

-(void) clickOfferWithOfferModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting *)setting extra:(NSDictionary*)extra {
    [self clickOfferWithOfferModel:offerModel setting:setting extra:extra skDelegate:nil viewController:nil circleId:nil];
}

-(void) clickOfferWithOfferModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting *)setting extra:(NSDictionary*)extra skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController circleId:(NSString *) circleId{
    if (offerModel.clickURL != nil) {
        if (offerModel.linkType == ATLinkTypeSafari) {
            dispatch_async(dispatch_get_main_queue(), ^{ [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ADXAppendLifeCircleIDToURL(offerModel.clickURL, extra[kATADXTrackerExtraLifeCircleID])]]; });
        } else if (offerModel.linkType == ATLinkTypeWebView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ATOfferWebViewController *webVC = [ATOfferWebViewController new];
                webVC.urlString = offerModel.clickURL;
                webVC.storeUrlStr = offerModel.storeURL;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [viewController presentViewController:nav animated:YES completion:nil];
            });
        }else if (offerModel.linkType == ATLinkTypeInnerSafari) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([offerModel.clickURL hasPrefix:@"http"] == NO &&
                    [offerModel.clickURL hasPrefix:@"https"] == NO) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ADXAppendLifeCircleIDToURL(offerModel.clickURL, extra[kATADXTrackerExtraLifeCircleID])]];
                    return;
                }
                
                NSString *url = [offerModel.clickURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                SFSafariViewController *safari = [[SFSafariViewController alloc]initWithURL: [NSURL URLWithString:url]];
                safari.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:safari];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [viewController presentViewController:nav animated:YES completion:nil];

            });
        }
        else {
            if (ADXValidateFinalURL([NSURL URLWithString:offerModel.clickURL])) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(setting.storekitTime != ATATLoadStorekitTimeNone && offerModel.pkgName != nil  && [Utilities higherThanIOS13]){
                        [self presentStorekitViewControllerWithCircleId:circleId pkgName:offerModel.pkgName placementID:setting.placementID offerID:offerModel.offerID skDelegate:skDelegate viewController:viewController];
                    }else{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ADXAppendLifeCircleIDToURL(offerModel.clickURL, extra[kATADXTrackerExtraLifeCircleID])]];
                    }
                });
            } else {
                if (setting.clickMode == ATClickModeAsync && offerModel.storeURL != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(setting.storekitTime != ATATLoadStorekitTimeNone && offerModel.pkgName != nil && [Utilities higherThanIOS13]){
                            [self presentStorekitViewControllerWithCircleId:circleId pkgName:offerModel.pkgName placementID:setting.placementID offerID:offerModel.offerID skDelegate:skDelegate viewController:viewController];
                        }else{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:offerModel.storeURL]];
                        }
                    });
                }
                __weak typeof(self) weakSelf = self;
                [_redirectorsAccessor writeWithBlock:^{
                    if (setting.clickMode == ATClickModeSync) { dispatch_async(dispatch_get_main_queue(), ^{ [ATMyOfferProgressHud showProgressHud:[UIApplication sharedApplication].keyWindow]; }); }
                    __weak __block ATOfferSessionRedirector *weakRedirector = nil;
                    __block ATOfferSessionRedirector *redirector = [ATOfferSessionRedirector redirectorWithURL:[NSURL URLWithString:ADXAppendLifeCircleIDToURL(offerModel.clickURL, extra[kATADXTrackerExtraLifeCircleID])] completion:^(NSURL *finalURL, NSError *error) {
                        if (setting.clickMode == ATClickModeSync) { dispatch_async(dispatch_get_main_queue(), ^{ [ATMyOfferProgressHud hideProgressHud:[UIApplication sharedApplication].keyWindow]; }); }
                        if (error == nil || ADXValidateFinalURL(finalURL)) {
                            [weakSelf.redirectorsAccessor writeWithBlock:^{ [weakSelf.redirectors removeObject:weakRedirector]; }];
                            if (setting.clickMode == ATClickModeSync && ADXValidateFinalURL(finalURL)) { dispatch_async(dispatch_get_main_queue(), ^{
                                if(setting.storekitTime != ATATLoadStorekitTimeNone && offerModel.pkgName != nil  && [Utilities higherThanIOS13]){
                                    [self presentStorekitViewControllerWithCircleId:circleId pkgName:offerModel.pkgName placementID:setting.placementID offerID:offerModel.offerID skDelegate:skDelegate viewController:viewController];
                                }else{
                                    [[UIApplication sharedApplication] openURL:finalURL];
                                }
                            }); }
                        } else {
                            if (setting.clickMode == ATClickModeSync && offerModel.storeURL != nil) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if(setting.storekitTime != ATATLoadStorekitTimeNone && offerModel.pkgName != nil  && [Utilities higherThanIOS13]){
                                        [self presentStorekitViewControllerWithCircleId:circleId pkgName:offerModel.pkgName placementID:setting.placementID offerID:offerModel.offerID skDelegate:skDelegate viewController:viewController];
                                    }else{
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:offerModel.storeURL]];
                                    }
                                });
                            }
                            //agent event for click failed
                            [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyClickRedirectFailedKey placementID:setting.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoMyOfferOfferIDKey:offerModel.offerID, kAgentEventExtraInfoAdTypeKey:@1, kAgentEventExtraInfoAdClickUrlKey:offerModel.clickURL != nil ? [offerModel.clickURL stringUrlEncode] : @"", kAgentEventExtraInfoAdLastUrlKey:finalURL != nil? [finalURL.absoluteString stringUrlEncode]:@"",  kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@(error.code)}];
                        }
                    }];
                    weakRedirector = redirector;
                    [weakSelf.redirectors addObject:redirector];
                }];
            }//End of else of final url
        }//end of safari jump type
    }
}

BOOL ADXValidateFinalURL(NSURL *URL) {
    return [URL isKindOfClass:[NSURL class]] && ([[ATAppSettingManager sharedManager].trackingSetting.tcHosts containsObject:URL.host]);
}

-(void)preloadStorekitForOfferModel:(ATADXOfferModel *)offerModel setting:(ATADXPlacementSetting *) setting viewController:(UIViewController *)viewController circleId:(NSString *) circleId  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate {
    
    if(setting != nil && setting.storekitTime == ATLoadStorekitTimePreload && [Utilities higherThanIOS13]){
        //TODO preload storekit
        dispatch_async(dispatch_get_main_queue(), ^{
            if(offerModel != nil && offerModel.pkgName != nil){
                __block ATStoreProductViewController* storekitVC = [ATStoreProductViewController storekitWithPackageName:offerModel.pkgName skDelegate:skDelegate];
                [storekitVC atLoadProductWithPackageName:offerModel.pkgName placementID:setting.placementID offerID:offerModel.offerID pkgName:offerModel.pkgName finished:^(BOOL result, NSError *error, NSTimeInterval loadTime) {
                    
                    if(result){
                        [self setStorekitViewControllerWithPkgName:offerModel.pkgName storekitVC:storekitVC];
                    }
                }];
            }
        });
    }
}

-(void)presentStorekitViewControllerWithCircleId:(NSString *) circleId pkgName:(NSString *) pkgName placementID:(NSString *)placementID offerID:(NSString *)offerID  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController {
    ATStoreProductViewController* storekitVC = [self getStorekitViewControllerWithPkgName:pkgName skDelegate:skDelegate parentVC:viewController];
    storekitVC.skDelegate = skDelegate;
    [ATStoreProductViewController at_presentStorekit:storekitVC presenting:viewController];
    if(!storekitVC.loadSuccessed){
        [storekitVC atLoadProductWithPackageName:pkgName placementID:placementID offerID:offerID pkgName:pkgName finished:nil];
    }
}

-(ATStoreProductViewController *)getStorekitViewControllerWithPkgName:(NSString *) pkgName skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate parentVC:(UIViewController *) parentVC {
    __weak typeof(self) weakSelf = self;
    return [_storekitStorageAccessor readWithBlock:^id {
        if(weakSelf.preloadStorekitDict[pkgName] != nil && (((ATStoreProductViewController*)weakSelf.preloadStorekitDict[pkgName]).parentVC == nil || [((ATStoreProductViewController*)weakSelf.preloadStorekitDict[pkgName]).parentVC isEqual:parentVC])){
            return weakSelf.preloadStorekitDict[pkgName];
        }else{
            ATStoreProductViewController* storekitVC = [ATStoreProductViewController storekitWithPackageName:pkgName skDelegate:skDelegate];
            return storekitVC;
        }
    }];
}

-(void )setStorekitViewControllerWithPkgName:(NSString *) pkgName storekitVC:(ATStoreProductViewController *) storekitVC{
    __weak typeof(self) weakSelf = self;
    [_storekitStorageAccessor writeWithBlock:^ {
        weakSelf.preloadStorekitDict[pkgName] = storekitVC;
    }];
}

// MARK:- SFSafariViewControllerDelegate
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:true completion:^{
        
    }];
}

- (void)safariViewController:(SFSafariViewController *)controller initialLoadDidRedirectToURL:(NSURL *)URL {
    NSLog(@"redirect to: %@",URL.absoluteString);
}

@end
