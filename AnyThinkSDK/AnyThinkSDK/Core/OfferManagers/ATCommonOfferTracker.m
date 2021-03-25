//
//  ATBaseTrackingKit.m
//  AnyThinkSDK
//
//  Created by stephen on 28/10/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATCommonOfferTracker.h"
#import "ATOfferSessionRedirector.h"
#import "ATNetworkingManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATOfferModel.h"
#import "ATOfferSetting.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATMyOfferProgressHud.h"
#import "ATAgentEvent.h"
#import "ATStoreProductViewController.h"

@interface ATCommonOfferTracker()
@property(nonatomic, readonly) ATThreadSafeAccessor *trackerAccessor;
@property(nonatomic, readonly) ATThreadSafeAccessor *storekitStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString *, ATStoreProductViewController *> *preloadStorekitDict;

@end

@implementation ATCommonOfferTracker

+(instancetype)sharedTracker {
    static ATCommonOfferTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[ATCommonOfferTracker alloc] init];
    });
    return sharedTracker;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _trackerAccessor = [ATThreadSafeAccessor new];
        _storekitStorageAccessor = [ATThreadSafeAccessor new];
        _preloadStorekitDict = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) openWithDeepLinkUrl:(NSString*_Nullable)deepLinkUrl completionHandler:(void (^ __nullable)(BOOL success))completion {
    [ATLogger logMessage:[NSString stringWithFormat:@"try to open deeplink:%@", deepLinkUrl] type:ATLogTypeInternal];
    
    NSURL *url = [NSURL URLWithString:deepLinkUrl];
    if (url == nil) {
        completion(NO);
        return;
    }
    
    if (@available(iOS 10.0, *)) {
        AsyncInMain(^{
            BOOL success = [[UIApplication sharedApplication] openURL:url];
            completion(success);
        })
    } else {
        // Fallback on earlier versions
        completion(NO);
    }
}

-(void) openUrlWithInnerSafari:(NSString *_Nullable)urlStr parentCtrl:(UIViewController *_Nullable)pc {
    
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (@available(iOS 9.0, *)) {
        AsyncInMain(^{
            SFSafariViewController *sf = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:url]];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:sf];
            [pc presentViewController:nav animated:YES completion:nil];
        })
    } else {
        // Fallback on earlier versions
    }
}

-(void) openUrlInWebview:(NSString *_Nullable)urlStr storeUrlStr:(NSString *_Nullable)storeStr parentCtrl:(UIViewController *_Nullable)pc {
    [self openUrlInWebview:urlStr storeUrlStr:storeStr parentCtrl:pc openInSafariWhenFailed:NO];
}

-(void) openUrlInWebview:(NSString *_Nullable)urlStr storeUrlStr:(NSString *_Nullable)storeStr parentCtrl:(UIViewController *_Nullable)pc openInSafariWhenFailed:(BOOL)open {
    AsyncInMain(^{
        
        ATOfferWebViewController *webVC = [ATOfferWebViewController new];
        webVC.urlString = urlStr;
        webVC.storeUrlStr = storeStr;
        webVC.openInSafariWhenFailed = open;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [pc presentViewController:nav animated:YES completion:nil];
    })
}

-(void) openUrlInSafari:(NSString *_Nullable)urlStr requestId:(NSString *_Nullable)requestId {
    urlStr = [self urlString:urlStr appending:requestId];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (url == nil) {
        return;
    }
    AsyncInMain(^{
        [[UIApplication sharedApplication] openURL:url];
    })
}

- (NSString *_Nonnull)urlString:(NSString *_Nonnull)urlStr appending:(NSString *_Nullable)requestId {
    if (urlStr.isString && requestId) {
        return [urlStr stringByReplacingOccurrencesOfString:@"{req_id}" withString:requestId];
    }
    return urlStr;
}

/**
 send notice url to network and support 302 redirection
 */
-(void) sendNoticeWithUrls:(NSArray *)urls completion:(void(^)(NSURL *finalURL, NSError *error))completion {
    [_trackerAccessor writeWithBlock:^{
        for (id item in urls) {
            NSURL *target = nil;
            if ([item isKindOfClass:[NSString class]]) {
                target = [NSURL URLWithString:[item stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            
            if ([item isKindOfClass:[NSURL class]]) {
                target = item;
            }
            
            if (target == nil) {
                continue;
            }
            __block ATOfferSessionRedirector *redirector = [ATOfferSessionRedirector redirectorWithURL:target completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error){
                if (completion) {
                    completion(finalURL, error);
                }
            }];
        }
    }];
}

-(void) sendTKEventWithAddress:(NSString*)address parameters:(NSDictionary*)parameters retry:(BOOL)retry completionHandler:(void (^ __nullable)(BOOL retry))completion {
    [[ATNetworkingManager sharedManager] sendHTTPRequestToAddress:address HTTPMethod:ATNetworkingHTTPMethodPOST parameters:parameters gzip:NO completion:^(NSData * _Nonnull data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (retry &&
            (error.code == NSURLErrorNetworkConnectionLost ||
                      error.code == NSURLErrorNotConnectedToInternet ||
                      error.code == 53)) {
            completion(YES);
        }else{
            completion(NO);
        }
    }];
}

/**
 click for offermodel with no deeplink
 */
- (void)clickOfferWithOfferModel:(ATOfferModel *)offerModel setting:(ATOfferSetting *)setting circleID:(NSString *)circleId delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)viewController extra:(NSDictionary*) extra clickCallbackHandler:(void (^ __nullable)(ATClickType clickType, BOOL isEnd, BOOL success)) clickCallback {
    
    if ([Utilities isEmpty:offerModel.jumpUrl] == NO) {
        NSURL *url = [NSURL URLWithString:offerModel.jumpUrl];

        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success == NO) {
                    [self handleDeepLinkOrLinkTypeWhenJumpFailed:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:clickCallback];
                }
                if (clickCallback && success) {
                    clickCallback(ATClickTypeClickJumpUrl, YES, YES);
                }
                [self sendJumpUrlResultWithOfferModel:offerModel setting:setting circleID:circleId success:success];
            }];
        } else {
            // Fallback on earlier versions
            BOOL success = [[UIApplication sharedApplication] openURL:url];
            if (success == NO) {
                [self handleDeepLinkOrLinkTypeWhenJumpFailed:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:clickCallback];
            }
            if (clickCallback && success) {
                clickCallback(ATClickTypeClickJumpUrl, YES, YES);
            }
            [self sendJumpUrlResultWithOfferModel:offerModel setting:setting circleID:circleId success:success];
        }
        return;
    }
    [self handleDeepLinkOrLinkTypeWhenJumpFailed:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:clickCallback];

}

- (void)handleDeepLinkOrLinkTypeWhenJumpFailed:(ATOfferModel *)offerModel setting:(ATOfferSetting *)setting circleID:(NSString *)circleId delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)viewController extra:(NSDictionary*) extra clickCallbackHandler:(void (^ __nullable)(ATClickType clickType, BOOL isEnd, BOOL success)) clickCallback {
    //TODO check deeplink if ok open deeplink else check linktype
    
    if([Utilities isEmpty:offerModel.deeplinkUrl] == NO) {
        if(clickCallback != nil){
            clickCallback(ATClickTypeDeepLinkUrl, NO, NO);
        }
        switch (setting.deeplinkClickMoment) {
            case ATDeepLinkModePreClickUrl:
                [self jumpDeepLinkPreClickUrlWithOfferModel:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:clickCallback];
                break;
            case ATDeepLinkModeLastClickUrl:
                [self jumpDeepLinkLastClickUrlWithOfferModel:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:clickCallback];
                break;
            default:
                [self jumpDeepLinkWithOfferModel:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:clickCallback];
                break;
        }
    }else{
        if(clickCallback != nil){
            clickCallback(ATClickTypeClickUrl, NO, NO);
        }
        if ([Utilities isEmpty:offerModel.clickURL]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"This ads does not support click to open." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:cancel];
            [viewController presentViewController:alert animated:YES completion:nil];

            [self sendNoticeWithUrls:offerModel.clickTKUrl completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error) {
                            
            }];
            
            return;
        }
        [self jumpClickUrlWithOfferModel:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:clickCallback];
    }
}

-(void) jumpDeepLinkPreClickUrlWithOfferModel:(ATOfferModel*)offerModel setting:(ATOfferSetting *)setting circleID:(NSString *)circleId delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)viewController  extra:(NSDictionary*)extra clickCallbackHandler:(void (^ __nullable)(ATClickType clickType, BOOL isEnd, BOOL success)) clickCallback {
    [self showHud:YES];
    __block NSString* deepLinkUrl = offerModel.deeplinkUrl;
    NSString* finalClickUrl = [self finalUrlWithExtraAndClickId:nil extra:extra url:offerModel.clickURL];
    [self clickForDeeplinkWithClickUrl:finalClickUrl completionHandler:^(NSString * _Nonnull clickId, NSError * _Nonnull error) {
        NSString* finalDeepLinkUrl = [self finalUrlWithExtraAndClickId:clickId extra:extra url:deepLinkUrl];
        [self hideHud:YES];
        [self openWithDeepLinkUrl:finalDeepLinkUrl completionHandler:^(BOOL success){
            if(clickCallback != nil){
                clickCallback(ATClickTypeDeepLinkUrl, YES, success);
            }
            if(!success){
                [self jumpClickUrlWithOfferModel:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:clickCallback];
            }
            [self sendDeepLinkJumpResultWithOfferModel:offerModel setting:setting circleID:circleId success:success];
        }];
       
    }];
}

-(void) jumpDeepLinkLastClickUrlWithOfferModel:(ATOfferModel*)offerModel setting:(ATOfferSetting *)setting circleID:(NSString *)circleId delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)viewController  extra:(NSDictionary*)extra clickCallbackHandler:(void (^ __nullable)(ATClickType clickType, BOOL isEnd, BOOL success)) clickCallback {
    [self openWithDeepLinkUrl:offerModel.deeplinkUrl completionHandler:^(BOOL success){
        if(clickCallback != nil){
            clickCallback(ATClickTypeDeepLinkUrl, YES, success);
        }
       
        if(!success){
            [self jumpClickUrlWithOfferModel:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:clickCallback];
        }else{
            NSString* finalClickUrl = [self finalUrlWithExtraAndClickId:nil extra:extra url:offerModel.clickURL];
            [self clickForDeeplinkWithClickUrl:finalClickUrl completionHandler:nil];
        }
        [self sendDeepLinkJumpResultWithOfferModel:offerModel setting:setting circleID:circleId success:success];
    }];
}

-(void) jumpDeepLinkWithOfferModel:(ATOfferModel*)offerModel setting:(ATOfferSetting *)setting circleID:(NSString *)circleId delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)viewController  extra:(NSDictionary*)extra clickCallbackHandler:(void (^ __nullable)(ATClickType clickType, BOOL isEnd, BOOL success)) clickCallback {
    [self openWithDeepLinkUrl:offerModel.deeplinkUrl completionHandler:^(BOOL success){
        if(clickCallback != nil){
            clickCallback(ATClickTypeDeepLinkUrl, YES, success);
        }
        if(!success){
            if ([Utilities isEmpty:offerModel.clickURL]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"This ads does not support click to open." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alert addAction:cancel];
                [viewController presentViewController:alert animated:YES completion:nil];

                [self sendNoticeWithUrls:offerModel.clickTKUrl completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error) {
                                
                }];
                
                return;
            }
            [self jumpClickUrlWithOfferModel:offerModel setting:setting circleID:circleId delegate:delegate viewController:viewController extra:extra clickCallbackHandler:nil];
        }
        [self sendDeepLinkJumpResultWithOfferModel:offerModel setting:setting circleID:circleId success:success];
    }];
}

-(void) clickForDeeplinkWithClickUrl:(NSString*)redirectUrl completionHandler:(void (^ __nullable)(NSString * _Nonnull clickId, NSError * _Nonnull error))handler {
    __block ATOfferSessionRedirector *redirector = [ATOfferSessionRedirector redirectorWithURL:[NSURL URLWithString:redirectUrl] completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error){
        __block NSString* clickId = nil;
        if(finalURL != nil){
            NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:finalURL.absoluteString];
            [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [parm setObject:obj.value forKey:obj.name];
                if([@"qz_gdt" isEqualToString:obj.name]){
                    clickId = obj.value;
                    *stop = YES;
                }
            }];
        }
        handler(clickId, error);
        
    }];
}

/**
 replace the value that gdt requre when click with deeplink
 */
-(NSString*) finalUrlWithExtraAndClickId:(NSString*)clickId  extra:(NSDictionary*) extra url:(NSString*)url {
    __block NSString* finalUrl = url;
    if(clickId != nil){
        finalUrl = [finalUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", kATOfferTrackerGDTClickID] withString:clickId];
    }
    [extra enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        finalUrl = [finalUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:[NSString stringWithFormat:@"%@",obj]];
    }];
    return finalUrl;
}

/**
 send agent event for deeplink
 */
-(void) sendDeepLinkJumpResultWithOfferModel:(ATOfferModel*)offerModel setting:(ATOfferSetting *)setting circleID:(NSString *)circleId success:(BOOL)success {
    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyDeepLinkResultKey placementID:setting.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoMyOfferOfferIDKey:offerModel.offerID, kAgentEventExtraInfoAdTypeKey:@(offerModel.offerModelType), kAgentEventExtraInfoAdDeeplinkUrlKey:offerModel.deeplinkUrl != nil ? [offerModel.deeplinkUrl stringUrlEncode] : @"", kAgentEventExtraInfoIsSuccessKey:@(success?1:0)}];
    
    if (success == NO) {
        [self sendNoticeWithUrls:offerModel.openSchemeFailedTKUrl completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error) {
                    
        }];
    }
}

- (void)sendJumpUrlResultWithOfferModel:(ATOfferModel*)offerModel setting:(ATOfferSetting *)setting circleID:(NSString *)circleId success:(BOOL)success {
    NSDictionary *extra = @{
        kAgentEventExtraInfoMyOfferOfferIDKey:offerModel.offerID,
        kAgentEventExtraInfoAdTypeKey:@(offerModel.offerModelType),
        kAgentEventExtraInfoAdDeeplinkUrlKey:offerModel.jumpUrl != nil ? [offerModel.jumpUrl stringUrlEncode] : @"",
        kAgentEventExtraInfoIsSuccessKey:@(success?1:0),
        kAgentEventExtraInfoDeeplinkOrJumpKey:@1
    };
    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyDeepLinkResultKey placementID:setting.placementID unitGroupModel:nil extraInfo:extra];
    
    if (success == NO) {
        [self sendNoticeWithUrls:offerModel.openSchemeFailedTKUrl completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error) {
                    
        }];
    }
}

- (void)jumpClickUrlWithOfferModel:(ATOfferModel *)offerModel setting:(ATOfferSetting *)setting circleID:(NSString *)cid delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)pc extra:(NSDictionary *)extra clickCallbackHandler:(void (^ __nullable)(ATClickType clickType, BOOL isEnd, BOOL success)) clickCallback {
    NSString* finalClickUrl = [self finalUrlWithExtraAndClickId:nil extra:extra url:offerModel.clickURL];
    switch (offerModel.linkType) {
        case ATLinkTypeSafari:
            [self openUrlInSafari:finalClickUrl requestId:cid];
            break;
        case ATLinkTypeWebView:
        {
            BOOL failStrategy = setting.loadType == 1;
            [self openUrlInWebview:finalClickUrl storeUrlStr:offerModel.storeURL parentCtrl:pc openInSafariWhenFailed:failStrategy];
            break;
        }
        case ATLinkTypeInnerSafari:
            if ([offerModel.clickURL hasPrefix:@"http"] == NO) {
                [self openUrlInSafari:finalClickUrl requestId:cid];
                return;
            }
            [self openUrlWithInnerSafari:finalClickUrl parentCtrl:pc];
            break;
        case ATLinkTypeAppStore:
        {
//            BOOL failStrategy = setting.loadType == 1;
            [self openInAppStoreWithOfferModel:offerModel setting:setting circleID:cid delegate:delegate viewController:pc extra:extra clickCallbackHandler:clickCallback];
        }
            break;
        default:
            [self openUrlInSafari:finalClickUrl requestId:cid];
            break;
    }
}

- (void)finalStepToOpenInAppStoreWithUrlString:(NSString *)urlStr placementSetting:(ATOfferSetting *)setting circleID:(NSString *)cid offerModel:(ATOfferModel *)offerModel pkgName:(NSString *)pkg offerID:(NSString *)oid delegate:(id<SKStoreProductViewControllerDelegate>)delegate parentVC:(UIViewController *)pc openInSafariWhenFailed:(BOOL)open {
    BOOL canOpenAfter13 =
    setting.storekitTime != ATATLoadStorekitTimeNone &&
    pkg &&
    [Utilities higherThanIOS13];
    
    if (canOpenAfter13) {
        AsyncInMain(^{
            [self presentStorekitViewControllerWithCircleId:cid offerModel:offerModel pkgName:pkg placementID:setting.placementID offerID:oid skDelegate:delegate viewController:pc];
        })
    }else{
        [[ATCommonOfferTracker sharedTracker] openUrlInSafari:urlStr requestId:cid];
    }
}

- (void)openInAppStoreWithOfferModel:(ATOfferModel *)model setting:(ATOfferSetting *)setting circleID:(NSString *)cid delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)pc extra:(NSDictionary *)extra clickCallbackHandler:(void (^ __nullable)(ATClickType clickType, BOOL isEnd, BOOL success)) clickCallback {
    [self openInAppStoreWithOfferModel:model setting:setting circleID:cid delegate:delegate viewController:pc extra:extra clickCallbackHandler:clickCallback openInSafariWhenFailed:NO];
}

- (void)openInAppStoreWithOfferModel:(ATOfferModel *)model setting:(ATOfferSetting *)setting circleID:(NSString *)cid delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)pc extra:(NSDictionary *)extra clickCallbackHandler:(void (^ __nullable)(ATClickType clickType, BOOL isEnd, BOOL success)) clickCallback openInSafariWhenFailed:(BOOL)open {
    
    BOOL sync = setting.clickMode == ATClickModeSync;
    __block BOOL opened = NO;
    NSArray *hosts = [ATAppSettingManager sharedManager].trackingSetting.tcHosts;

    if (sync == NO) {
        NSString* finalClickUrl = [self finalUrlWithExtraAndClickId:nil extra:extra url: model.storeURL];
        NSURL *url = [NSURL URLWithString:finalClickUrl];
        
        if ([hosts containsObject:url.host]) {
            opened = YES;
            AsyncInMain(^{
                [self finalStepToOpenInAppStoreWithUrlString:finalClickUrl placementSetting:setting circleID:cid offerModel:model pkgName:model.pkgName offerID:model.offerID delegate:delegate parentVC:pc openInSafariWhenFailed:open];
                if(clickCallback != nil){
                    clickCallback(ATClickTypeClickUrl, YES, YES);
                }
            })
        }
    }else {
        NSString* finalClickUrl = [self finalUrlWithExtraAndClickId:nil extra:extra url: model.clickURL];
        NSURL *url = [NSURL URLWithString:finalClickUrl];
        if ([hosts containsObject:url.host]) {
            opened = YES;
            AsyncInMain(^{
                [self finalStepToOpenInAppStoreWithUrlString:finalClickUrl placementSetting:setting circleID:cid offerModel:model pkgName:model.pkgName offerID:model.offerID delegate:delegate parentVC:pc openInSafariWhenFailed:open];
                if(clickCallback != nil){
                    clickCallback(ATClickTypeClickUrl, YES, YES);
                }
            })
            return;
        }
    }
    
    // 302 redirection
    [self.trackerAccessor writeWithBlock:^{
        AsyncInMain(^{
            [self showHud:sync];
        })
        
        NSString *urlStr = [[ATCommonOfferTracker sharedTracker] urlString:model.clickURL appending:cid];
        __block ATOfferSessionRedirector *redirector = [ATOfferSessionRedirector redirectorWithURL:[NSURL URLWithString:urlStr] completion:^(NSURL * _Nonnull finalURL, NSError * _Nonnull error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud:sync];
                
                if (error == nil) {

                    if (opened) {
                        return;
                    }
                    if ([hosts containsObject:finalURL.host]) {
                        [self finalStepToOpenInAppStoreWithUrlString:finalURL.absoluteString placementSetting:setting circleID:cid offerModel:model pkgName:model.pkgName offerID:model.offerID delegate:delegate parentVC:pc openInSafariWhenFailed:open];
                    }else {
                        [[UIApplication sharedApplication] openURL:finalURL];
                    }
                    
                    if(clickCallback != nil){
                        clickCallback(ATClickTypeClickUrl, YES, YES);
                    }
                    return;
                }
                
                if (sync && model.storeURL && !opened) {
                    NSURL *storeUrl = [NSURL URLWithString:model.storeURL];
                    if ([hosts containsObject:storeUrl.host]) {
                        [self finalStepToOpenInAppStoreWithUrlString:model.storeURL placementSetting:setting circleID:cid offerModel:model pkgName:model.pkgName offerID:model.offerID delegate:delegate parentVC:pc openInSafariWhenFailed:open];
                        if(clickCallback != nil){
                            clickCallback(ATClickTypeClickUrl, YES, NO);
                        }
                    }else {
                        NSURL *url = [NSURL URLWithString:[model.clickURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }else {
                    if(!opened){
                        NSURL *url = [NSURL URLWithString:[model.clickURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        [[UIApplication sharedApplication] openURL:url];
                    }
                  
                }
                NSDictionary *dic = @{kAgentEventExtraInfoMyOfferOfferIDKey:model.offerID, kAgentEventExtraInfoAdTypeKey:@(model.offerModelType), kAgentEventExtraInfoAdClickUrlKey:model.clickURL != nil ? [model.clickURL stringUrlEncode] : @"", kAgentEventExtraInfoAdLastUrlKey:finalURL != nil? [finalURL.absoluteString stringUrlEncode]:@"",  kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@(error.code)};
                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyClickRedirectFailedKey placementID:setting.placementID unitGroupModel:nil extraInfo:dic];
                
            });
            
           
        }];
//        [self.redirectors addObject:redirector];
    }];
}


- (void)showHud:(BOOL)sync {
    
    if (sync == NO) {
        return;
    }
    
    AsyncInMain(^{
        [ATMyOfferProgressHud showProgressHud:[UIApplication sharedApplication].keyWindow];
    })
}

- (void)hideHud:(BOOL)sync {
    
    if (sync == NO) {
        return;
    }
    
    AsyncInMain(^{
        [ATMyOfferProgressHud hideProgressHud:[UIApplication sharedApplication].keyWindow];
    })
}



- (void)preloadStorekitForOfferModel:(ATOfferModel *)model setting:(ATOfferSetting *)setting  viewController:(UIViewController *)viewController circleId:(NSString *)cid skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate {
    
    if (setting.storekitTime == ATLoadStorekitTimePreload && [Utilities higherThanIOS13]) {
        if (model.pkgName) {
            AsyncInMain(^{
                // todo
                ATStoreProductViewController *spc = [ATStoreProductViewController storekitWithPackageName:model.pkgName skDelegate:skDelegate];
                [spc atLoadProductWithOfferModel:model packageName:model.pkgName placementID:setting.placementID offerID:model.offerID pkgName:model.pkgName finished:^(BOOL result, NSError *error, NSTimeInterval loadTime) {
                    if (result) {
                        [self.storekitStorageAccessor writeWithBlock:^ {
                            self.preloadStorekitDict[model.pkgName] = spc;
                        }];
                    }
                }];
            })
        }
    }
    
}
// MARK:- private methods
-(ATStoreProductViewController *)getStorekitViewControllerWithPkgName:(NSString *) pkgName skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate parentVC:(UIViewController *) parentVC {
    
    return [_storekitStorageAccessor readWithBlock:^id {
        
        UIViewController *pc = self.preloadStorekitDict[pkgName].parentVC;
        if(pc || [pc isEqual:parentVC]) {
            return self.preloadStorekitDict[pkgName];
        }else{
            ATStoreProductViewController* storekitVC = [ATStoreProductViewController storekitWithPackageName:pkgName skDelegate:skDelegate];
            return storekitVC;
        }
    }];
}

- (void)presentStorekitViewControllerWithCircleId:(NSString *)cid offerModel:(ATOfferModel *)offerModel pkgName:(NSString *)pkgName placementID:(NSString *)placementID offerID:(NSString *)offerID  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController {
    
    ATStoreProductViewController* storekitVC = [self getStorekitViewControllerWithPkgName:pkgName skDelegate:skDelegate parentVC:viewController];
    storekitVC.skDelegate = skDelegate;
    [ATStoreProductViewController at_presentStorekit:storekitVC presenting:viewController];
    if(storekitVC.loadSuccessed == NO){
        [storekitVC atLoadProductWithOfferModel:offerModel packageName:pkgName placementID:placementID offerID:offerID pkgName:pkgName finished:nil];
    }
}


@end
