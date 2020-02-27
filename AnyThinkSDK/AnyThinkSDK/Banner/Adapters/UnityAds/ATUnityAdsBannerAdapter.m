//
//  ATUnityAdsBannerAdapter.m
//  AnyThinkUnityAdsBannerAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsBannerAdapter.h"
#import "ATUnityAdsBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAppSettingManager.h"

NSString *const kATUnityAdsBannerNotificationLoaded = @"com.anythink.UnityAdsBannerNotificationLoaded";
NSString *const kATUnityAdsBannerNotificationShow = @"com.anythink.UnityAdsBannerNotificationShow";
NSString *const kATUnityAdsBannerNotificationClick = @"com.anythink.UnityAdsBannerNotificationClick";
NSString *const kATUnityAdsBannerNotificationUserInfoPlacementIDKey = @"placement_id";
NSString *const kATUnityAdsBannerNotificationUserInfoViewKey = @"view";
@interface ATUnityAdsBannerDelegate:NSObject<UnityAdsBannerDelegate>
@end
@implementation ATUnityAdsBannerDelegate
+(instancetype) sharedDelegate {
    static ATUnityAdsBannerDelegate *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATUnityAdsBannerDelegate alloc] init];
    });
    return sharedManager;
}

-(void)unityAdsBannerDidLoad:(NSString *)placementId view:(UIView *)view {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsBanner::unityAdsBannerDidLoad:%@ view:", placementId] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (placementId != nil) { userInfo[kATUnityAdsBannerNotificationUserInfoPlacementIDKey] = placementId; }
    if (view != nil) { userInfo[kATUnityAdsBannerNotificationUserInfoViewKey] = view; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsBannerNotificationLoaded object:nil userInfo:userInfo];
}

-(void)unityAdsBannerDidUnload:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsBanner::unityAdsBannerDidUnload:%@", placementId] type:ATLogTypeExternal];
}

-(void)unityAdsBannerDidShow:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsBanner:::%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsBannerNotificationShow object:nil userInfo:@{kATUnityAdsBannerNotificationUserInfoPlacementIDKey: placementId != nil ? placementId : @""}];
}

-(void)unityAdsBannerDidHide:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsBanner::unityAdsBannerDidHide:%@", placementId] type:ATLogTypeExternal];
    [NSClassFromString(@"UnityAdsBanner") destroy];
}

-(void)unityAdsBannerDidClick:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsBanner::unityAdsBannerDidClick:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsBannerNotificationClick object:nil userInfo:@{kATUnityAdsBannerNotificationUserInfoPlacementIDKey: placementId != nil ? placementId : @""}];
}

-(void)unityAdsBannerDidError:(NSString *)message {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsBanner::unityAdsBannerDidError:%@", message] type:ATLogTypeExternal];
}
@end
@interface ATUnityAdsBannerAdapter()<UnityAdsDelegate>
@property(nonatomic, readonly) ATUnityAdsBannerCustomEvent *customEvent;
@end
@implementation ATUnityAdsBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameUnityAds]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameUnityAds];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"UnityAds") getVersion] forNetwork:kNetworkNameUnityAds];
            id playerMetaData = [[NSClassFromString(@"UADSMetaData") alloc] init];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameUnityAds]) {
                [playerMetaData set:@"gdpr.consent" value:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameUnityAds]];
            } else {
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) { [playerMetaData set:@"gdpr.consent" value:@(!limit)]; }
                
            }
            [playerMetaData commit];
        }
    }
    return self;
}

-(void)placementContentReady:(NSString *)placementId placementContent:(id)decision {
    [NSClassFromString(@"UnityAdsBanner") loadBanner:_customEvent.unitID];
}

-(void)placementContentStateDidChange:(NSString *)placementId placementContent:(id)placementContent previousState:(NSInteger)previousState newState:(NSInteger)newState {
    
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"UnityAdsBanner") != nil && NSClassFromString(@"UnityMonetization") != nil && NSClassFromString(@"UnityAds") != nil) {
        _customEvent = [[ATUnityAdsBannerCustomEvent alloc] initWithUnitID:info[@"placement_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        [NSClassFromString(@"UnityAdsBanner") setBannerPosition:6];
        [NSClassFromString(@"UnityAdsBanner") setDelegate:[ATUnityAdsBannerDelegate sharedDelegate]];
        if ([NSClassFromString(@"UnityAds") isInitialized]) {
            [NSClassFromString(@"UnityAdsBanner") loadBanner:_customEvent.unitID];
        } else {
            [NSClassFromString(@"UnityMonetization") initialize:info[@"game_id"] delegate:self];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"UnityAds"]}]);
    }
}
@end
