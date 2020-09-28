//
//  ATOnewayRewardedVideoAdapter.m
//  AnyThinkOnewayRewardedVideoAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATOnewayRewardedVideoAdapter.h"
#import "ATOnewayRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdAdapter.h"

NSString *const kATOnewayRVReadyNotification = @"com.anythink.OWRVReadyNotificaiton";
NSString *const kATOnewayRVShowNotification = @"com.anythink.OWRVShowNotificaiton";
NSString *const kATOnewayRVClickNotification = @"com.anythink.OWRVClickNotificaiton";
NSString *const kATOnewayRVFinishNotification = @"com.anythink.OWRVFinishNotificaiton";
NSString *const kATOnewayRVCloseNotification = @"com.anythink.OWRVCloseNotificaiton";
NSString *const kATOnewayRVErrorNotification = @"com.anythink.OWErrorNotificaiton";

NSString *const kATOnewayRVNotificationUserInfoTagKey = @"tag";
NSString *const kATOnewayRVNotificationUserInfoMessageKey = @"message";
NSString *const kATOnewayRVNotificationUserInfoErrorCodeKey = @"error_code";
NSString *const kATOnewayRVNotificationUserInfoStateKey = @"state";
NSString *const kATOnewayRVNotificationUserInfoSessionKey = @"session";

@interface ATOnewayRewardedVideoDelegate:NSObject<oneWaySDKRewardedAdDelegate>
@end
@implementation ATOnewayRewardedVideoDelegate
+(instancetype) sharedDelegate {
    static ATOnewayRewardedVideoDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATOnewayRewardedVideoDelegate alloc] init];
    });
    return sharedDelegate;
}

- (void)oneWaySDKRewardedAdReady {
    [ATLogger logMessage:@"oneWaySDKRewardedAdReady" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayRVReadyNotification object:nil];
}

- (void)oneWaySDKRewardedAdDidShow:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKRewardedAdDidShow:%@", tag] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayRVShowNotification object:nil userInfo:@{kATOnewayRVNotificationUserInfoTagKey:tag != nil ? tag : @""}];
}

- (void)oneWaySDKRewardedAdDidFinish:(NSString *)tag withState:(NSNumber *)state session:(NSString *)session {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKRewardedAdDidFinish:%@ withState:%@ withMessage:%@", tag, state, session] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (tag != nil) { userInfo[kATOnewayRVNotificationUserInfoTagKey] = tag; }
    if (state != nil) { userInfo[kATOnewayRVNotificationUserInfoStateKey] = state; }
    if (session != nil) { userInfo[kATOnewayRVNotificationUserInfoSessionKey] = session; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayRVFinishNotification object:nil userInfo:userInfo];
}

- (void)oneWaySDKRewardedAdDidClose:(NSString *)tag withState:(NSNumber *)state {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKRewardedAdDidClose:%@ withState:%@", tag, state] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (tag != nil) { userInfo[kATOnewayRVNotificationUserInfoTagKey] = tag; }
    if (state != nil) { userInfo[kATOnewayRVNotificationUserInfoStateKey] = state; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayRVCloseNotification object:nil userInfo:userInfo];
}

- (void)oneWaySDKRewardedAdDidClick:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKRewardedAdDidClick:%@", tag] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayRVClickNotification object:nil userInfo:@{kATOnewayRVNotificationUserInfoTagKey:tag != nil ? tag : @""}];
}

- (void)oneWaySDKDidError:(NSInteger)error withMessage:(NSString *)message {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKDidError:%ld withMessage:%@", error, message] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayRVErrorNotification object:nil];
}
@end

@interface ATOnewayRewardedVideoAdapter()
@property(nonatomic, readonly) ATOnewayRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kPublisherIDKey = @"publisher_id";
@implementation ATOnewayRewardedVideoAdapter
//+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
//    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kPublisherIDKey]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [NSClassFromString(@"OWRewardedAd") isReady];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATOnewayRewardedVideoCustomEvent *customEvent = rewardedVideo.customObject;
    [customEvent showWithTag:nil];
    customEvent.delegate = delegate;
    [NSClassFromString(@"OWRewardedAd") show:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameOneway]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameOneway];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"OneWaySDK") getVersion] forNetwork:kNetworkNameOneway];

            [NSClassFromString(@"OneWaySDK") configure:serverInfo[kPublisherIDKey]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"OWRewardedAd")) {
        _customEvent = [[ATOnewayRewardedVideoCustomEvent alloc] initWithUnitID:serverInfo[kPublisherIDKey] serverInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{ [NSClassFromString(@"OWRewardedAd") initWithDelegate:[ATOnewayRewardedVideoDelegate sharedDelegate]]; });
        
        if ([NSClassFromString(@"OWRewardedAd") isReady]) { [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayRVReadyNotification object:nil]; }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Oneway"]}]);
    }
}
@end
