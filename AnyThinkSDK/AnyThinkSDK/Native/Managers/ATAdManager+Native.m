//
//  ATAdManager+Native.m
//  AnyThinkNative
//
//  Created by Martin Lau on 07/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdManager+Native.h"
#import "ATNativeADCache.h"
#import "ATNativeADRenderer.h"
#import "ATNativeRendering.h"
#import "ATNativeADView+Internal.h"
#import "ATNativeADConfiguration.h"
#import "ATNativeADOfferManager.h"
#import "ATLogger.h"
#import "Utilities.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATPlacementSettingManager.h"
#import "ATAdManager+Internal.h"


NSString *const kATNativeDelegateExtraNetworkIDKey = @"network_firm_id";
NSString *const kATNativeDelegateExtraAdSourceIDKey = @"adsource_id";
NSString *const kATNativeDelegateExtraIsHeaderBidding = @"adsource_isHeaderBidding";
NSString *const kATNativeDelegateExtraPrice = @"adsource_price";
NSString *const kATNativeDelegateExtraPriority = @"adsource_index";

NSString *const kExtraInfoNativeAdSizeKey = @"native_ad_size";
NSString *const kExtraInfoNativeAdTypeKey = @"native_ad_type";

NSString *const kExtraInfoNativeAdUserIDKey = @"naitve_user_id";
NSString *const kExtraInfoNativeAdMediationNameKey = @"mediation_name";
NSString *const kExtraInfoNaitveAdUserFeatureKey = @"user_feature";
NSString *const kExtraInfoNativeAdLocationEnabledFlagKey = @"location_enbaled_flag";

NSString *const kNativeAdAutorefreshConfigurationSwitchKey = @"switch";//BOOL wrapped in NSNumber
NSString *const kNativeAdAutorefreshConfigurationRefreshIntervalKey = @"interval";//NSTimeInterval wrapped in NSNumber
@implementation ATAdManager (Native)
-(BOOL) nativeAdReadyForPlacementID:(NSString*)placementID {
    return [self nativeAdReadyForPlacementID:placementID sendTK:YES];
}

-(BOOL) nativeAdReadyForPlacementID:(NSString*)placementID sendTK:(BOOL)send {
    BOOL ready = NO;
    
    if ([placementID isKindOfClass:[NSString class]] && [placementID length] > 0) {
        ready = [self nativeAdReadyForPlacementID:placementID caller:ATAdManagerReadyAPICallerReady sendTK:send scene:nil];
    } else {
        [ATLogger logError:[NSString stringWithFormat:@"Invalid placementID encountered:%@", placementID] type:ATLogTypeExternal];
        ready = NO;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:0 api:kATAPIIsReady]];
    info[@"result"] = ready ? @"YES" : @"NO";
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", info] type:ATLogTypeTemporary];
    return ready;
}

-(BOOL) nativeAdReadyForPlacementID:(NSString*)placementID caller:(ATAdManagerReadyAPICaller)caller sendTK:(BOOL)send scene:(NSString *)scene {
    return [[ATAdManager sharedManager] adReadyForPlacementID:placementID scene:scene caller:caller sendTK:send context:^BOOL(NSDictionary *__autoreleasing *extra) {
        return [[ATNativeADOfferManager sharedManager] nativeAdWithPlacementID:placementID invalidateStatus:caller == ATAdManagerReadyAPICallerShow extra:extra] != nil;
    }];
}

- (__kindof UIView*) retriveAdViewWithPlacementID:(NSString*)placementID configuration:(ATNativeADConfiguration*)configuration  {
    return [self retriveAdViewWithPlacementID:placementID configuration:configuration scene:nil];
}

- (__kindof UIView*) retriveAdViewWithPlacementID:(NSString*)placementID configuration:(ATNativeADConfiguration*)configuration scene:(NSString *)scene {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:0 api:kATAPIShow]] type:ATLogTypeTemporary];
    
    NSString *showScene = nil;
    if ([Utilities validateShowingScene:scene]) {
        showScene = scene;
    } else {
        NSLog(@"Invalid scene is passed:%@, scene should be a string of 14 characters from '_', [0-9], [a-z], [A-Z]", scene);
    }
    
    NSError *error = nil;
    ATNativeADView *adView = nil;
    if ([self nativeAdReadyForPlacementID:placementID caller:ATAdManagerReadyAPICallerShow sendTK:YES scene:showScene]) {
        adView = [[configuration.renderingViewClass alloc] initWithConfiguration:configuration placementID:placementID];
        if ([adView isKindOfClass:[ATNativeADView class]]) {
            ATNativeADCache *cache = (ATNativeADCache*)adView.nativeAd;
            cache.scene = showScene;
        }
        [ATLogger logMessage:[NSString stringWithFormat:@"returned ad view class:%@", [adView class]] type:ATLogTypeInternal];
    } else {
        error = [NSError errorWithDomain:ATADShowingErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to show Native ad", NSLocalizedFailureReasonErrorKey:@"Native ad's not ready for the placement"}];
    }
    
    return adView;
}

-(NSDictionary*) autoRefreshConfigurationForPlacementID:(NSString*)placementID {
    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
    if (placementModel != nil) {
        return @{kNativeAdAutorefreshConfigurationSwitchKey:@(placementModel.autoRefresh), kNativeAdAutorefreshConfigurationRefreshIntervalKey:@(placementModel.autoRefreshInterval)};
    } else {
        return nil;
    }
}

- (ATCheckLoadModel*)checkNativeLoadStatusForPlacementID:(NSString*)placementID {
    
    ATCheckLoadModel *checkLoadModel = [[ATCheckLoadModel alloc] init];
    if ([[ATWaterfallManager sharedManager] loadingAdForPlacementID:placementID]) {
        checkLoadModel.isLoading = YES;
    }
    
    NSDictionary *dic = nil;
    ATNativeADCache *nativeAd = [[ATNativeADOfferManager sharedManager] nativeAdWithPlacementID:placementID extra:&dic];

    if ([self nativeAdReadyForPlacementID:placementID caller:ATAdManagerReadyAPICallerReady sendTK:YES scene:nil]) {
        checkLoadModel.isReady = YES;
        
        NSMutableDictionary *delegateExtra = [nativeAd.customEvent delegateExtraWithNativeAD:nativeAd];
        if ([delegateExtra containsObjectForKey:kATADDelegateExtraIDKey]) { [delegateExtra removeObjectForKey:kATADDelegateExtraIDKey]; }
        checkLoadModel.adOfferInfo = delegateExtra;
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:ATAdFormatNative api:kATAPICheckLoadStatus]];
    info[@"result"] = @{@"isLoading":checkLoadModel.isLoading ? @"YES" : @"NO", @"isReady":checkLoadModel.isReady ? @"YES" : @"NO", @"adOfferInfo":![Utilities isBlankDictionary:checkLoadModel.adOfferInfo] ? checkLoadModel.adOfferInfo : @{}};
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", info] type:ATLogTypeTemporary];
    return checkLoadModel;
}
@end
