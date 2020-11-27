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

Class Splash_AdapterClcass(NSInteger networkFirmID) {
    return NSClassFromString(@{@29:@"ATSigmobSplashAdapter",
                               @15:@"ATTTSplashAdapter",
                               @22:@"ATBaiduSplashAdapter",
                               @8:@"ATGDTSplashAdapter",
                               @6:@"ATMintegralSplashAdapter",
                               @2:@"ATAdmobSplashAdapter"
                             }[@(networkFirmID)]);
}
@implementation ATAdManager (Splash)
-(void) loadADWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATAdLoadingDelegate>)delegate window:(UIWindow*)window containerView:(UIView*)containerView {
    [self loadADWithPlacementID:placementID extra:extra customData:customData delegate:delegate window:window windowScene:nil containerView:containerView];
}

- (void)loadADWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra customData:(NSDictionary *)customData delegate:(id<ATSplashDelegate>)delegate window:(UIWindow *)window windowScene:(UIWindowScene *)windowScene containerView:(UIView *)containerView {
    if ([[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID] != nil || extra[kATSplashExtraNetworkFirmID] == nil) {
        NSMutableDictionary *modifiedExtra = [NSMutableDictionary dictionaryWithDictionary:extra];
        if (placementID != nil) { modifiedExtra[kATSplashExtraPlacementIDKey] = placementID; }
        modifiedExtra[kATSplashExtraLoadingStartDateKey] = [NSDate date];
        if ([window isKindOfClass:[UIWindow class]]) {
            modifiedExtra[kATSplashExtraWindowKey] = window;
            if ([modifiedExtra[kATSplashExtraBackgroundImageKey] isKindOfClass:[UIImage class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:window.bounds];
                    bgImageView.image = modifiedExtra[kATSplashExtraBackgroundImageKey];
                    [window addSubview:bgImageView];
                    modifiedExtra[kATSplashExtraBackgroundImageViewKey] = bgImageView;
                });
            }
        }
        if ([windowScene isKindOfClass:[UIWindowScene class]]) { modifiedExtra[kATSplashExtraWindowSceneKey] = windowScene;}
        if ([containerView isKindOfClass:[UIView class]]) { modifiedExtra[kATSplashExtraContainerViewKey] = containerView; }
        [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:modifiedExtra delegate:delegate];
    } else {
        NSDictionary *curCustomData = [[ATPlacementSettingManager sharedManager] calculateCustomDataForPlacementID:placementID];
        [[ATPlacementSettingManager sharedManager] requestPlacementSettingWithPlacementID:placementID customData:curCustomData extra:nil completion:^(ATPlacementModel *placementModel, NSError *error) { if (error == nil) { [[ATPlacementSettingManager sharedManager] addNewPlacementSetting:placementModel]; } }];
        NSMutableDictionary *customInfo = [NSMutableDictionary dictionary];
        if (extra[kATSplashExtraTolerateTimeoutKey] != nil) { customInfo[kATSplashExtraTolerateTimeoutKey] = extra[kATSplashExtraTolerateTimeoutKey]; }
        customInfo[kATSplashExtraLoadingStartDateKey] = [NSDate date];
        if ([window isKindOfClass:[UIWindow class]]) {
            customInfo[kATSplashExtraWindowKey] = window;
            if ([customInfo[kATSplashExtraBackgroundImageKey] isKindOfClass:[UIImage class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:window.bounds];
                    bgImageView.image = customInfo[kATSplashExtraBackgroundImageKey];
                    [window addSubview:bgImageView];
                    customInfo[kATSplashExtraBackgroundImageViewKey] = bgImageView;
                });
            }
        }
        if ([windowScene isKindOfClass:[UIWindowScene class]]) { customInfo[kATSplashExtraWindowSceneKey] = windowScene;}
        if ([containerView isKindOfClass:[UIView class]]) { customInfo[kATSplashExtraContainerViewKey] = containerView; }
        NSMutableDictionary *modifiedExtra = [NSMutableDictionary dictionaryWithDictionary:extra];
//        modifiedExtra[kAdapterCustomInfoExtraKey] = customInfo;
        if (placementID != nil) { modifiedExtra[kATSplashExtraPlacementIDKey] = placementID; }
        NSString *reqID = [Utilities generateRequestID];
        modifiedExtra[kATSplashExtraRequestIDKey] = reqID;
        //TODO may be some wrong for the exta data
        __block id<ATAdAdapter>adapter = [[Splash_AdapterClcass([modifiedExtra[kATSplashExtraNetworkFirmID] integerValue]) alloc] initWithNetworkCustomInfo:modifiedExtra localInfo:customInfo];
        ((NSObject*)adapter).delegateToBePassed = delegate;
        
        [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeAdTrackTypeLoad extra:@{kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraUGUnitIDKey:@([extra[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraASIDKey:@"0",kATTrackerExtraSDKCalledFlagKey:@1, kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
        
        [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeADTrackTypeADRequest extra:@{kATTrackerExtraUnitIDKey:@([extra[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraNetworkFirmIDKey:@([extra[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
        [adapter loadADWithInfo:modifiedExtra localInfo:customInfo completion:^(NSArray<NSDictionary *> *assets, NSError *error) {
            if (error == nil) {
                if ([(NSObject*)delegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) { [(id<ATAdLoadingDelegate>)delegate didFinishLoadingADWithPlacementID:placementID]; }
                [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeAdTrackTypeLoadResult extra:@{kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraUGUnitIDKey:@([extra[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
                [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeADTrackTypeADRecalledSuccessfully extra:@{kATTrackerExtraUnitIDKey:@([extra[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraNetworkFirmIDKey:@([extra[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
                
                [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:reqID trackType:ATNativeADTrackTypeADShow extra:@{kATTrackerExtraUnitIDKey:extra[kATSplashExtraAdSourceIDKey] != nil ? @([extra[kATSplashExtraAdSourceIDKey] integerValue]) : @0, kATTrackerExtraNetworkFirmIDKey:@([extra[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
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

@end
