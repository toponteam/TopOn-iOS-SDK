//
//  ATAdManager+Splash.m
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdManager+Splash.h"
#import "ATSplashManager.h"
#import "ATPlacementSettingManager.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "Utilities.h"
#import "ATTracker.h"
#import "ATSplashCustomEvent.h"
#import "ATSplash.h"
#import "ATCapsManager.h"
#import "ATSplashAdapter.h"
#import "ATSplashDelegate.h"
#import "ATGeneralAdAgentEvent.h"

NSString *const kATSplashDelegateExtraNetworkIDKey = @"network_firm_id";
NSString *const kATSplashDelegateExtraAdSourceIDKey = @"adsource_id";
NSString *const kATSplashDelegateExtraIsHeaderBidding = @"adsource_isHeaderBidding";
NSString *const kATSplashDelegateExtraPrice = @"adsource_price";
NSString *const kATSplashDelegateExtraPriority = @"adsource_index";

NSString *const kATSplashExtraCountdownKey = @"countdown";
NSString *const kATSplashExtraTolerateTimeoutKey = @"tolerate_timeout";
NSString *const kATSplashExtraHideSkipButtonFlagKey = @"hide_skip_button_flag";
NSString *const kATSplashExtraBackgroundImageKey = @"background_image";
NSString *const kATSplashExtraBackgroundColorKey = @"background_color";
NSString *const kATSplashExtraSkipButtonCenterKey = @"skip_button_center";
NSString *const kATSplashExtraCustomSkipButtonKey = @"custom_skip_button";
NSString *const kATSplashExtraCanClickFlagKey = @"can_click_flag";
NSString *const kATSplashExtraShowDirectionKey = @"showDirection";

NSString *const kATSplashExtraBackgroundImageViewKey = @"background_image_view";

NSString *const kATSplashExtraPlacementIDKey = @"topon_placement_id";
NSString *const kATSplashExtraNetworkFirmID = @"network_firm_id";
NSString *const kATSplashExtraAdSourceIDKey = @"adsource_id";
#pragma mark - Mintegral
NSString *const kATSplashExtraMintegralAppKey = @"appkey";
NSString *const kATSplashExtraMintegralAppID = @"appid";
NSString *const kATSplashExtraMintegralPlacementID = @"placement_id";
NSString *const kATSplashExtraMintegralUnitID = @"unitid";
#pragma mark - GDT
NSString *const kATSplashExtraGDTAppID = @"app_id";
NSString *const kATSplashExtraGDTUnitID = @"unit_id";
#pragma mark - TT
NSString *const kATSplashExtraAppID = @"app_id";
NSString *const kATSplashExtraSlotID = @"slot_id";
NSString *const kATSplashExtraPersonalizedTemplateFlag = @"personalized_template";
NSString *const kATSplashExtraZoomOutKey = @"zoomoutad_sw";

#pragma mark - Baidu
NSString *const kATSplashExtraBaiduAppID = @"app_id";
NSString *const kATSplashExtraBaiduAdPlaceID = @"ad_place_id";
#pragma mark - Sigmob
NSString *const kATSplashExtraSigmobAppKey = @"app_key";
NSString *const kATSplashExtraSigmobAppID = @"app_id";
NSString *const kATSplashExtraSigmobPlacementID = @"placement_id";
#pragma mark - Admob
NSString *const kATSplashExtraAdmobAppID = @"app_id";
NSString *const kATSplashExtraAdmobUnitID = @"unit_id";
NSString *const kATSplashExtraAdmobOrientation = @"orientation";
#pragma mark - KuaiShou
NSString *const kATSplashExtraKSAppID = @"app_id";
NSString *const kATSplashExtraKSPosID = @"position_id";

NSString *const kATAdLoadingExtraSplashAdSizeKey = @"splash_ad_size";

#pragma mark - Mobrain
NSString *const kATSplashExtraRootViewControllerKey = @"at_splash_root_view_controller";
NSString *const kATSplashExtraRIDKey = @"at_splash_rid";
NSString *const kATSplashExtraAppIDKey = @"at_splash_app_id";
NSString *const kATSplashExtraMobrainAdnTypeKey = @"at_splash_mobrain_adn_type";
NSString *const kATSplashExtraMobrainAppKeyKey = @"at_splash_mobrain_app_key";

Class Splash_AdapterClcass(NSInteger networkFirmID) {
    return NSClassFromString(@{@29:@"ATSigmobSplashAdapter",
                               @15:@"ATTTSplashAdapter",
                               @22:@"ATBaiduSplashAdapter",
                               @8:@"ATGDTSplashAdapter",
                               @6:@"ATMintegralSplashAdapter",
                               @2:@"ATAdmobSplashAdapter",
                               @28:@"ATKSSplashAdapter"
                             }[@(networkFirmID)]);
}
@implementation ATAdManager (Splash)

- (void)loadADWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<ATSplashDelegate>)delegate containerView:(UIView *)containerView {
    if ([[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID] != nil || extra[kATSplashExtraNetworkFirmID] == nil) {
        NSMutableDictionary *modifiedExtra = [NSMutableDictionary dictionaryWithDictionary:extra];
        if (placementID != nil) { modifiedExtra[kATSplashExtraPlacementIDKey] = placementID; }
        modifiedExtra[kATSplashExtraLoadingStartDateKey] = [NSDate date];
        if ([modifiedExtra[kATSplashExtraBackgroundImageKey] isKindOfClass:[UIImage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                bgImageView.image = modifiedExtra[kATSplashExtraBackgroundImageKey];
                [[UIApplication sharedApplication].keyWindow addSubview:bgImageView];
                modifiedExtra[kATSplashExtraBackgroundImageViewKey] = bgImageView;
            });
        }
        if ([containerView isKindOfClass:[UIView class]]) { modifiedExtra[kATSplashExtraContainerViewKey] = containerView; }
    
        [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:modifiedExtra delegate:delegate];
    } else {
        NSDictionary *curCustomData = [[ATPlacementSettingManager sharedManager] calculateCustomDataForPlacementID:placementID];
        [[ATPlacementSettingManager sharedManager] requestPlacementSettingWithPlacementID:placementID customData:curCustomData extra:nil completion:^(ATPlacementModel *placementModel, NSError *error) { if (error == nil) { [[ATPlacementSettingManager sharedManager] addNewPlacementSetting:placementModel]; } }];
        NSMutableDictionary *customInfo = [NSMutableDictionary dictionary];
        if (extra[kATSplashExtraTolerateTimeoutKey] != nil) { customInfo[kATSplashExtraTolerateTimeoutKey] = extra[kATSplashExtraTolerateTimeoutKey]; }
        customInfo[kATSplashExtraLoadingStartDateKey] = [NSDate date];
        if ([containerView isKindOfClass:[UIView class]]) { customInfo[kATSplashExtraContainerViewKey] = containerView; }
        NSMutableDictionary *modifiedExtra = [NSMutableDictionary dictionaryWithDictionary:extra];
//        modifiedExtra[kAdapterCustomInfoExtraKey] = customInfo;
        if (placementID != nil) { modifiedExtra[kATSplashExtraPlacementIDKey] = placementID; }
        NSString *reqID = [Utilities generateRequestID];
        modifiedExtra[kATSplashExtraRequestIDKey] = reqID;
        ATUnitGroupModel *unitGroupModel = [[ATUnitGroupModel alloc]initWithDictionary:@{
            kAdStorageExtraUnitGroupInfoNetworkFirmIDKey:modifiedExtra[kATSplashExtraNetworkFirmID],
            kAdStorageExtraUnitGroupInfoContentKey: @"", @"unit_id":extra[kATSplashExtraAdSourceIDKey]}];
        
        ATPlacementModel *placementModel = [[ATPlacementModel alloc]initWithDictionary:@{@"format":@(ATAdFormatSplash)} placementID:placementID];
        
        //TODO may be some wrong for the exta data
        __block id<ATAdAdapter>adapter = [[Splash_AdapterClcass([modifiedExtra[kATSplashExtraNetworkFirmID] integerValue]) alloc] initWithNetworkCustomInfo:modifiedExtra localInfo:customInfo];
        ((NSObject*)adapter).delegateToBePassed = delegate;
        
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraUGUnitIDKey:@([extra[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraASIDKey:@"0",kATTrackerExtraSDKCalledFlagKey:@1, kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
        if([ATAPI isOfm]){
            trackingExtra[kATTrackerExtraOFMTrafficIDKey] = extra[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):extra[kATTrackerExtraOFMTrafficIDKey];
            trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
        }
        
        [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeAdTrackTypeLoad extra:trackingExtra];
        
        NSMutableDictionary *requestExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraUnitIDKey:@([extra[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraNetworkFirmIDKey:@([extra[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
        if([ATAPI isOfm]){
            requestExtra[kATTrackerExtraOFMTrafficIDKey] = customInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):customInfo[kATTrackerExtraOFMTrafficIDKey];
            requestExtra[kATTrackerExtraOFMSystemKey] = @(1);
        }
        
        [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeADTrackTypeADRequest extra:requestExtra];
        // load splash
        [adapter loadADWithInfo:modifiedExtra localInfo:customInfo completion:^(NSArray<NSDictionary *> *assets, NSError *error) {
            if (error == nil) {
                if ([(NSObject*)delegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) {
                    [(id<ATAdLoadingDelegate>)delegate didFinishLoadingADWithPlacementID:placementID];
                }
                
                ATSplash *splash = [[ATSplash alloc] initWithPriority:0 placementModel:placementModel requestID:reqID assets:assets.firstObject unitGroup:unitGroupModel finalWaterfall:nil];
                splash.adapterClass = adapter.class;
                [[ATSplashManager sharedManager] saveAdWithoutPlacementSetting:splash extra:@{kAdStorageExtraRequestIDKey:reqID,kAdStoreageExtraUnitGroupUnitID:extra[kATSplashExtraAdSourceIDKey],kAdStorageExtraNetworkFirmIDKey:extra[kATSplashExtraNetworkFirmID]} placementID:placementID];
                
                NSMutableDictionary *loadResultExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraUGUnitIDKey:@([extra[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
                if([ATAPI isOfm]){
                    loadResultExtra[kATTrackerExtraOFMTrafficIDKey] = extra[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):extra[kATTrackerExtraOFMTrafficIDKey];
                    loadResultExtra[kATTrackerExtraOFMSystemKey] = @(1);
                }
                
                [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeAdTrackTypeLoadResult extra:loadResultExtra];
                
                NSMutableDictionary *reqResultExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraUnitIDKey:@([extra[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraNetworkFirmIDKey:@([extra[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
                if([ATAPI isOfm]){
                    reqResultExtra[kATTrackerExtraOFMTrafficIDKey] = extra[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):extra[kATTrackerExtraOFMTrafficIDKey];
                    reqResultExtra[kATTrackerExtraOFMSystemKey] = @(1);
                }
                
                [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeADTrackTypeADRecalledSuccessfully extra:reqResultExtra];
                
//                [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeADTrackTypeADShow extra:@{kATTrackerExtraUnitIDKey:extra[kATSplashExtraAdSourceIDKey] != nil ? @([extra[kATSplashExtraAdSourceIDKey] integerValue]) : @0, kATTrackerExtraNetworkFirmIDKey:@([extra[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
            } else {
                if ([(NSObject*)delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { [(id<ATAdLoadingDelegate>)delegate didFailToLoadADWithPlacementID:placementID error:error]; }
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ adapter = nil; });
        }];
    }
}

/** check AdSource List */
- (void)checkAdSourceList:(NSString *)placementID {
    if ([ATAPI logEnabled]) {
        NSDictionary *curCustomData = [[ATPlacementSettingManager sharedManager] calculateCustomDataForPlacementID:placementID];
        [[ATPlacementSettingManager sharedManager] requestPlacementSettingWithPlacementID:placementID customData:curCustomData extra:nil completion:^(ATPlacementModel *placementModel, NSError *error) {
            if (error == nil) {
                if (placementModel.format == 4) {
                    if (placementModel.unitGroups.count > 0) {
                        NSMutableArray *adSourcelist = [NSMutableArray array];
                        for (ATUnitGroupModel *unitGroupModel in placementModel.unitGroups) {
                            NSMutableDictionary *info = [NSMutableDictionary dictionary];
                            info[@"Network_Firm_id"] = @(unitGroupModel.networkFirmID);
                            info[@"network"] = [self networkNameWithNetworkFirmID:unitGroupModel.networkFirmID];
                            info[@"adsource_id"] = unitGroupModel.unitGroupID != nil ? unitGroupModel.unitGroupID : @"";
                            info[@"network_unit_info"] = unitGroupModel.content;
                            [adSourcelist addObject:info];
                        }
                        [ATLogger logMessage:[NSString stringWithFormat:@"\nGet Splash Config info:\n*****************************\n%@\n*****************************",adSourcelist] type:ATLogTypeExternal];
                    }else {
                        [ATLogger logMessage:[NSString stringWithFormat:@"\nGet Splash Config info:\n*****************************\nThis placement(%@) does not contain any unit group!\n*****************************",placementID] type:ATLogTypeExternal];
                    }
                }else {
                    [ATLogger logMessage:[NSString stringWithFormat:@"\nGet Splash Config info:\n*****************************\nThis placement(%@) does not belong to Splash!\n*****************************",placementID] type:ATLogTypeExternal];
                }
            }else {
                [ATLogger logMessage:[NSString stringWithFormat:@"\nGet Splash Config info:\n*****************************\nThis placement(%@) request error:%@ mode!\n*****************************",placementID,error] type:ATLogTypeExternal];
            }
        }];
    }else {
        NSLog(@"\n********************Get Splash Config Start******************\nThis API Only use in debug mode!\n********************Get Splash Config End********************");
    }
}

- (NSString*)networkNameWithNetworkFirmID:(NSInteger)nwFirmID {
    return [ATAPI networkNameMap][@(nwFirmID)] != nil ? [ATAPI networkNameMap][@(nwFirmID)] : @"";
}

// MARK:- ready
- (BOOL)splashReadyForPlacementID:(NSString *)placementID {
    return [self splashReadyForPlacementID:placementID sendTK:YES];
}

- (BOOL)splashReadyForPlacementID:(NSString *)placementID sendTK:(BOOL)send {
    BOOL ready = [self splashReadyForPlacementID:placementID caller:ATAdManagerReadyAPICallerReady splash:nil sendTK:send];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:ATAdFormatSplash api:kATAPIIsReady]];
    info[@"result"] = ready ? @"YES" : @"NO";
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", info] type:ATLogTypeTemporary];
    return ready;
}

- (BOOL)splashReadyForPlacementID:(NSString*)placementID caller:(ATAdManagerReadyAPICaller)caller splash:(ATSplash * __strong*)splash sendTK:(BOOL)send {
    return [[ATAdManager sharedManager] adReadyForPlacementID:placementID scene:nil caller:caller sendTK:send context:^BOOL(NSDictionary *__autoreleasing *extra) {
        ATSplash *localSplash = [[ATSplashManager sharedManager] splashForPlacementID:placementID invalidateStatus:caller == ATAdManagerReadyAPICallerShow extra:extra];
        if (splash) {
            *splash = localSplash;
        }
        return localSplash;
    }];
}

- (void)showSplashWithPlacementID:(NSString *)placementID window:(UIWindow*)window delegate:(id<ATSplashDelegate>)delegate {
    [self showSplashWithPlacementID:placementID window:window windowScene:nil delegate:delegate];
}

- (void)showSplashWithPlacementID:(NSString*)placementID window:(UIWindow*)window windowScene:(UIWindowScene *)windowScene delegate:(id<ATSplashDelegate>)delegate {
    NSError *error = nil;
    ATSplash *splash = nil;
    if ([self splashReadyForPlacementID:placementID caller:ATAdManagerReadyAPICallerShow splash:&splash sendTK:YES]) {
        splash.customEvent.delegate = delegate;
        [splash.customEvent saveShowAPIContext];
        splash.showTimes++;
        
        NSMutableDictionary *modifiedExtra = [NSMutableDictionary dictionary];
        if ([window isKindOfClass:[UIWindow class]]) {
            modifiedExtra[kATSplashExtraWindowKey] = window;
        }
        if ([windowScene isKindOfClass:[UIWindowScene class]]) {
            modifiedExtra[kATSplashExtraWindowSceneKey] = windowScene;
        }
        
        if (splash.unitGroup.adapterClass) {
            [splash.unitGroup.adapterClass showSplash:splash localInfo:modifiedExtra delegate:delegate];
        }else {
            [splash.adapterClass showSplash:splash localInfo:modifiedExtra delegate:delegate];
        }
        [[ATCapsManager sharedManager] setShowFlagForPlacementID:placementID requestID:splash.requestID];
        [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:placementID];
    }else {
        error = [NSError errorWithDomain:ATADShowingErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to show splash ad", NSLocalizedFailureReasonErrorKey:@"Splash's not ready for the placement"}];
    }
    if (error) {
        if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
            [delegate didFailToLoadADWithPlacementID:placementID error:error];
        }
    }
}

// MARK:-
- (ATCheckLoadModel*)checkSplashLoadStatusForPlacementID:(NSString *)placementID {
    ATSplash *splash = nil;
    ATCheckLoadModel *checkLoadModel = [[ATCheckLoadModel alloc] init];
    if ([[ATWaterfallManager sharedManager] loadingAdForPlacementID:placementID]) {
        checkLoadModel.isLoading = YES;
    }
    if ([self splashReadyForPlacementID:placementID scene:nil caller:ATAdManagerReadyAPICallerReady splash:&splash sendTK:YES]) {
        checkLoadModel.isReady = YES;
        NSMutableDictionary *delegateExtra = [NSMutableDictionary dictionaryWithDictionary:[splash.customEvent delegateExtra]];
        if ([delegateExtra containsObjectForKey:kATADDelegateExtraIDKey]) { [delegateExtra removeObjectForKey:kATADDelegateExtraIDKey]; }
        checkLoadModel.adOfferInfo = delegateExtra;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:ATAdFormatSplash api:kATAPICheckLoadStatus]];
    info[@"result"] = @{@"isLoading":checkLoadModel.isLoading ? @"YES" : @"NO", @"isReady":checkLoadModel.isReady ? @"YES" : @"NO", @"adOfferInfo":![Utilities isBlankDictionary:checkLoadModel.adOfferInfo] ? checkLoadModel.adOfferInfo : @{}};
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", info] type:ATLogTypeTemporary];
    return checkLoadModel;
}

- (BOOL)splashReadyForPlacementID:(NSString*)placementID scene:(NSString*)scene caller:(ATAdManagerReadyAPICaller)caller splash:(ATSplash *__strong *)splash sendTK:(BOOL)send {
    return [[ATAdManager sharedManager] adReadyForPlacementID:placementID scene:scene caller:caller sendTK:send context:^BOOL(NSDictionary *__autoreleasing *extra) {

        ATSplash *kSplash = [[ATSplashManager sharedManager] splashForPlacementID:placementID invalidateStatus:caller == ATAdManagerReadyAPICallerShow extra:extra];
        if (kSplash) {
            *splash = kSplash;
        }
        return kSplash;
    }];
}
@end
