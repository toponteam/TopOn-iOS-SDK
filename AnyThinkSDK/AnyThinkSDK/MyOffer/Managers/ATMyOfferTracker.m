//
//  ATMyOfferTracker.m
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/30.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferTracker.h"
#import "ATNetworkingManager.h"
#import "ATThreadSafeAccessor.h"
#import "Utilities.h"
#import "ATMyOfferProgressHud.h"
#import "ATAppSettingManager.h"
#import "ATStoreProductViewController.h"
#import "ATOfferWebViewController.h"
#import "ATAgentEvent.h"
#import "ATOfferSessionRedirector.h"
#import <SafariServices/SFSafariViewController.h>

NSString *const kATMyOfferTrackerExtraLifeCircleID = @"life_circle_id";
NSString *const kATMyOfferTrackerExtraScene = @"scene";
#pragma mark - tracker
@interface ATMyOfferTracker()<SFSafariViewControllerDelegate>
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* failedEventStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *failedEventStorageAccessor;
@property(nonatomic, readonly) NSMutableArray<ATOfferSessionRedirector*> *redirectors;
@property(nonatomic, readonly) ATThreadSafeAccessor *redirectorsAccessor;
@property(nonatomic, readonly) ATThreadSafeAccessor *storekitStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary *preloadStorekitDict;

@end
static NSString *kFailedEventStorageAddressKey = @"address";
static NSString *kFailedEventStorageParametersKey = @"parameters";
@implementation ATMyOfferTracker
+(instancetype) sharedTracker {
    static ATMyOfferTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[ATMyOfferTracker alloc] init];
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
    NSArray<NSDictionary*>* archivedEvents = [NSArray<NSDictionary*> arrayWithContentsOfFile:[ATMyOfferTracker eventArchivePath]];
    [[NSFileManager defaultManager] removeItemAtPath:[ATMyOfferTracker eventArchivePath] error:nil];
    if ([archivedEvents isKindOfClass:[NSArray class]]) {
        [archivedEvents enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSString *address = obj[kFailedEventStorageAddressKey];
                NSDictionary *parameters = obj[kFailedEventStorageParametersKey];
                if ([address isKindOfClass:[NSString class]] && [address length] > 0) {
                    [self sendTKEventWithAddress:address parameters:[parameters isKindOfClass:[NSDictionary class]] ? parameters : nil];
                }
            }
        }];
    }
}

+(NSString*)eventArchivePath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.MyOfferTKEvents"];
}

NSDictionary *ExtractParameterFromURL(NSURL *URL, NSDictionary *extra) {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray<NSString*>*queries = [URL.query componentsSeparatedByString:@"&"];
    [queries enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString*>* components = [obj componentsSeparatedByString:@"="];
        if ([components count] == 2) { parameters[components[0]] = components[1]; }
    }];
    parameters[@"t"] = [NSString stringWithFormat:@"%@", [Utilities normalizedTimeStamp]];
    if ([extra[kATMyOfferTrackerExtraLifeCircleID] isKindOfClass:[NSString class]]) { parameters[@"req_id"] = extra[kATMyOfferTrackerExtraLifeCircleID]; }
    if ([extra[kATMyOfferTrackerExtraScene] isKindOfClass:[NSString class]]) { parameters[@"scenario"] = extra[kATMyOfferTrackerExtraScene]; }
    return parameters;
}

NSString *ExtractAddressFromURL(NSURL *URL) {
    NSString *address = [NSString stringWithFormat:@"%@://%@%@", URL.scheme, URL.host, URL.path];
    return address;
}

NSURL *BuildTKURL(ATMyOfferOfferModel *offerModel, ATMyOfferTrackerEvent event, NSDictionary *extra) {
    NSURL *url = nil;
    __block NSString *tkURLStr = RetrieveTKURL(offerModel, event);
    if ([tkURLStr length] > 0) {
        [offerModel.placeholders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) { tkURLStr = [tkURLStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:obj]; }];
        url = [NSURL URLWithString:tkURLStr];
    }
    return url;
}

NSString* RetrieveTKURL(ATMyOfferOfferModel *offerModel, ATMyOfferTrackerEvent event) {
    return @{@(ATMyOfferTrackerEventVideoStart):offerModel.videoStartTKURL != nil ? offerModel.videoStartTKURL : @"",
             @(ATMyOfferTrackerEventVideo25Percent):offerModel.video25TKURL != nil ? offerModel.video25TKURL : @"",
             @(ATMyOfferTrackerEventVideo50Percent):offerModel.video50TKURL != nil ? offerModel.video50TKURL : @"",
             @(ATMyOfferTrackerEventVideo75Percent):offerModel.video75TKURL != nil ? offerModel.video75TKURL : @"",
             @(ATMyOfferTrackerEventVideoEnd):offerModel.videoEndTKURL != nil ? offerModel.videoEndTKURL : @"",
             @(ATMyOfferTrackerEventImpression):offerModel.impTKURL != nil ? offerModel.impTKURL : @"",
             @(ATMyOfferTrackerEventClick):offerModel.clickTKURL != nil ? offerModel.clickTKURL : @"",
             @(ATMyOfferTrackerEventEndCardShow):offerModel.endCardShowTKURL != nil ? offerModel.endCardShowTKURL : @"",
             @(ATMyOfferTrackerEventEndCardClose):offerModel.endCardCloseTKURL != nil ? offerModel.endCardCloseTKURL : @""
    }[@(event)];
}

-(void) trackEvent:(ATMyOfferTrackerEvent)event offerModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra {
    NSURL *tkURL = BuildTKURL(offerModel, event, extra);
    NSString *address = ExtractAddressFromURL(tkURL);
    NSDictionary *parameters = ExtractParameterFromURL(tkURL, extra);
    if ([address length] > 0) { [self sendTKEventWithAddress:address parameters:parameters]; }
}

-(void) sendTKEventWithAddress:(NSString*)address parameters:(NSDictionary*)parameters {
    [[ATNetworkingManager sharedManager] sendHTTPRequestToAddress:address HTTPMethod:ATNetworkingHTTPMethodPOST parameters:parameters completion:^(NSData * _Nonnull data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error.code == NSURLErrorNetworkConnectionLost || error.code == NSURLErrorNotConnectedToInternet || error.code == 53) {
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
            [weakSelf.failedEventStorage writeToFile:[ATMyOfferTracker eventArchivePath] atomically:YES];
        }];
    }
}

NSString *AppendLifeCircleIDToURL(NSString *URL, NSString *lifeCircleID) {
    return [lifeCircleID isKindOfClass:[NSString class]] ? ([URL stringByReplacingOccurrencesOfString:@"{req_id}" withString:lifeCircleID]) : URL;
}

-(void) impressionOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra {
    if (offerModel.impURL != nil) {
        __weak typeof(self) weakSelf = self;
        [_redirectorsAccessor writeWithBlock:^{
            __weak __block ATOfferSessionRedirector *weakRedirector = nil;
            __block ATOfferSessionRedirector *redirector = [ATOfferSessionRedirector redirectorWithURL:[NSURL URLWithString:AppendLifeCircleIDToURL(offerModel.impURL, extra[kATMyOfferTrackerExtraLifeCircleID])] completion:^(NSURL *finalURL, NSError *error) { [weakSelf.redirectorsAccessor writeWithBlock:^{ [weakSelf.redirectors removeObject:weakRedirector]; }]; }];
            weakRedirector = redirector;
            [weakSelf.redirectors addObject:redirector];
        }];
    }
}

-(void) clickOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting *)setting extra:(NSDictionary*)extra {
    [self clickOfferWithOfferModel:offerModel setting:setting extra:extra skDelegate:nil viewController:nil circleId:nil];
}

-(void) clickOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting *)setting extra:(NSDictionary*)extra skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController circleId:(NSString *) circleId{
    if (offerModel.clickURL != nil) {
        if (offerModel.linkType == ATLinkTypeSafari) {
            dispatch_async(dispatch_get_main_queue(), ^{ [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppendLifeCircleIDToURL(offerModel.clickURL, extra[kATMyOfferTrackerExtraLifeCircleID])]]; });
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
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppendLifeCircleIDToURL(offerModel.clickURL, extra[kATMyOfferTrackerExtraLifeCircleID])]];
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
            if (validateFinalURL([NSURL URLWithString:offerModel.clickURL])) {
                dispatch_async(dispatch_get_main_queue(), ^{ [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppendLifeCircleIDToURL(offerModel.clickURL, extra[kATMyOfferTrackerExtraLifeCircleID])]]; });
            } else {
                if (offerModel.performsAsynchronousRedirection && offerModel.storeURL != nil) { dispatch_async(dispatch_get_main_queue(), ^{
                    if(setting.storekitTime != ATATLoadStorekitTimeNone && offerModel.pkgName != nil && [Utilities higherThanIOS13]){
                        [self presentStorekitViewControllerWithCircleId:circleId pkgName:offerModel.pkgName placementID:setting.placementID offerID:offerModel.offerID skDelegate:skDelegate viewController:viewController];
                    }else{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:offerModel.storeURL]];
                    }
                }); }
                __weak typeof(self) weakSelf = self;
                [_redirectorsAccessor writeWithBlock:^{
                    if (!offerModel.performsAsynchronousRedirection) { dispatch_async(dispatch_get_main_queue(), ^{ [ATMyOfferProgressHud showProgressHud:[UIApplication sharedApplication].keyWindow]; }); }
                    __weak __block ATOfferSessionRedirector *weakRedirector = nil;
                    __block ATOfferSessionRedirector *redirector = [ATOfferSessionRedirector redirectorWithURL:[NSURL URLWithString:AppendLifeCircleIDToURL(offerModel.clickURL, extra[kATMyOfferTrackerExtraLifeCircleID])] completion:^(NSURL *finalURL, NSError *error) {
                        if (!offerModel.performsAsynchronousRedirection) { dispatch_async(dispatch_get_main_queue(), ^{ [ATMyOfferProgressHud hideProgressHud:[UIApplication sharedApplication].keyWindow]; }); }
                        if (error == nil || validateFinalURL(finalURL)) {
                            [weakSelf.redirectorsAccessor writeWithBlock:^{ [weakSelf.redirectors removeObject:weakRedirector]; }];
                            if (!offerModel.performsAsynchronousRedirection && validateFinalURL(finalURL)) { dispatch_async(dispatch_get_main_queue(), ^{
                                if(setting.storekitTime != ATATLoadStorekitTimeNone && offerModel.pkgName != nil  && [Utilities higherThanIOS13]){
                                    [self presentStorekitViewControllerWithCircleId:circleId pkgName:offerModel.pkgName placementID:setting.placementID offerID:offerModel.offerID skDelegate:skDelegate viewController:viewController];
                                }else{
                                    [[UIApplication sharedApplication] openURL:finalURL];
                                }
                            }); }
                        } else {
                            if (!offerModel.performsAsynchronousRedirection && offerModel.storeURL != nil) {
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

BOOL validateFinalURL(NSURL *URL) {
    return [URL isKindOfClass:[NSURL class]] && ([[ATAppSettingManager sharedManager].trackingSetting.tcHosts containsObject:URL.host]);
}

-(void)preloadStorekitForOfferModel:(ATMyOfferOfferModel *)offerModel setting:(ATMyOfferSetting *) setting viewController:(UIViewController *)viewController circleId:(NSString *) circleId  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate {
    
    if(setting != nil && setting.storekitTime == ATLoadStorekitTimePreload && [Utilities higherThanIOS13]){
        //TODO preload storekit
        dispatch_async(dispatch_get_main_queue(), ^{
            if(offerModel != nil && offerModel.pkgName != nil){
               
                __block ATStoreProductViewController* storekitVC = [ATStoreProductViewController storekitWithPackageName:offerModel.pkgName skDelegate:skDelegate];
                [storekitVC atLoadProductWithPackageName:offerModel.pkgName placementID:setting.placementID offerID:offerModel.offerID pkgName:offerModel.pkgName finished:^(BOOL result, NSError *error, NSTimeInterval loadTime) {
                    
                    if(result){
                        [ATLogger logMessage:@"ATMyOfferBannerView::atLoadProductWithPackageName:finished success!" type:ATLogTypeInternal];
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
    return [weakSelf.storekitStorageAccessor readWithBlock:^id {
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
