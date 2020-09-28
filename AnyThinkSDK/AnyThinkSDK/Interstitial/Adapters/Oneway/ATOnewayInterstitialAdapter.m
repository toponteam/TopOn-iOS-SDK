//
//  ATOnewayInterstitialAdapter.m
//  AnyThinkOnewayInterstitialAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATOnewayInterstitialAdapter.h"
#import "ATOnewayInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAdAdapter.h"

NSString *const kATOnewayInterstitialReadyNotification = @"com.anythink.OWInterstitialReadyNotificaiton";
NSString *const kATOnewayInterstitialShowNotification = @"com.anythink.OWInterstitialShowNotificaiton";
NSString *const kATOnewayInterstitialClickNotification = @"com.anythink.OWInterstitialClickNotificaiton";
NSString *const kATOnewayInterstitialFinishNotification = @"com.anythink.OWInterstitialFinishNotificaiton";
NSString *const kATOnewayInterstitialCloseNotification = @"com.anythink.OWInterstitialCloseNotificaiton";
NSString *const kATOnewayInterstitialErrorNotification = @"com.anythink.OWErrorNotificaiton";

NSString *const kATOnewayInterstitialImageReadyNotification = @"com.anythink.OWInterstitialImageReadyNotificaiton";
NSString *const kATOnewayInterstitialImageShowNotification = @"com.anythink.OWInterstitialImageShowNotificaiton";
NSString *const kATOnewayInterstitialImageClickNotification = @"com.anythink.OWInterstitialImageClickNotificaiton";
NSString *const kATOnewayInterstitialImageFinishNotification = @"com.anythink.OWInterstitialImageFinishNotificaiton";
NSString *const kATOnewayInterstitialImageCloseNotification = @"com.anythink.OWInterstitialImageCloseNotificaiton";
NSString *const kATOnewayInterstitialImageErrorNotification = @"com.anythink.OWInterstitialImageErrorNotificaiton";

NSString *const kATOnewayInterstitialNotificationUserInfoTagKey = @"tag";
NSString *const kATOnewayInterstitialNotificationUserInfoMessageKey = @"message";
NSString *const kATOnewayInterstitialNotificationUserInfoErrorCodeKey = @"error_code";
NSString *const kATOnewayInterstitialNotificationUserInfoStateKey = @"state";
NSString *const kATOnewayInterstitialNotificationUserInfoSessionKey = @"session";

@interface ATOWInterstitialDelegate:NSObject<oneWaySDKInterstitialAdDelegate,oneWaySDKInterstitialImageAdDelegate>
+(instancetype) sharedDelegate;
@end
@implementation ATOWInterstitialDelegate
+(instancetype) sharedDelegate {
    static ATOWInterstitialDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATOWInterstitialDelegate alloc] init];
    });
    return sharedDelegate;
}

#pragma mark - image
- (void)oneWaySDKInterstitialImageAdReady {
    [ATLogger logMessage:@"oneWaySDKInterstitialImageAdReady" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialImageReadyNotification object:nil userInfo:@{}];
}

- (void)oneWaySDKInterstitialImageAdDidShow:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKInterstitialImageAdDidShow:%@", tag] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialImageShowNotification object:nil userInfo:@{kATOnewayInterstitialNotificationUserInfoTagKey:tag != nil ? tag : @""}];
}

- (void)oneWaySDKInterstitialImageAdDidFinish:(NSString *)tag withState:(NSNumber *)state session:(NSString *)session {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKInterstitialImageAdDidFinish:%@ withState:%@ session:%@", tag, state, session] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (tag != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoTagKey] = tag; }
    if (state != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoStateKey] = state; }
    if (session != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoSessionKey] = session; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialImageFinishNotification object:nil userInfo:userInfo];
}

- (void)oneWaySDKInterstitialImageAdDidClose:(NSString *)tag withState:(NSNumber *)state {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKInterstitialImageAdDidClose:%@ withState:%@", tag, state] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (tag != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoTagKey] = tag; }
    if (state != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoStateKey] = state; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialImageCloseNotification object:nil userInfo:userInfo];
}

- (void)oneWaySDKInterstitialImageAdDidClick:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKInterstitialImageAdDidClick:%@", tag] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialImageClickNotification object:nil userInfo:@{kATOnewayInterstitialNotificationUserInfoTagKey:tag != nil ? tag : @""}];
}

- (void)oneWaySDKDidError:(NSInteger)error withMessage:(NSString *)message {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKDidError:oneWaySDKDidError:%ld :%@", error, message] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialErrorNotification object:nil userInfo:@{kATOnewayInterstitialNotificationUserInfoErrorCodeKey:@(error), kATOnewayInterstitialNotificationUserInfoMessageKey:message != nil ? message : @""}];
}

#pragma mark - video
- (void)oneWaySDKInterstitialAdReady {
    [ATLogger logMessage:@"oneWaySDKInterstitialAdReady" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialReadyNotification object:nil userInfo:@{}];
}

- (void)oneWaySDKInterstitialAdDidShow:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKInterstitialAdDidShow:%@", tag] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialShowNotification object:nil userInfo:@{kATOnewayInterstitialNotificationUserInfoTagKey:tag != nil ? tag : @""}];
}

- (void)oneWaySDKInterstitialAdDidFinish:(NSString *)tag withState:(NSNumber *)state session:(NSString *)session {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKInterstitialAdDidFinish:%@ withState:%@ session:%@", tag, state, session] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (tag != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoTagKey] = tag; }
    if (state != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoStateKey] = state; }
    if (session != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoSessionKey] = session; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialFinishNotification object:nil userInfo:userInfo];
}

- (void)oneWaySDKInterstitialAdDidClose:(NSString *)tag withState:(NSNumber *)state {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKInterstitialAdDidClose:%@ withState:%@", tag, state] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (tag != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoTagKey] = tag; }
    if (state != nil) { userInfo[kATOnewayInterstitialNotificationUserInfoStateKey] = state; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialCloseNotification object:nil userInfo:userInfo];
}

- (void)oneWaySDKInterstitialAdDidClick:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"oneWaySDKInterstitialAdDidClick:%@", tag] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialClickNotification object:nil userInfo:@{kATOnewayInterstitialNotificationUserInfoTagKey:tag != nil ? tag : @""}];
}
@end

@interface ATOnewayInterstitialAdapter()
@property(nonatomic, readonly) ATOnewayInterstitialCustomEvent *customEvent;
@end
@implementation ATOnewayInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [info[@"is_video"] boolValue] ? [NSClassFromString(@"OWInterstitialAd") isReady] : [NSClassFromString(@"OWInterstitialImageAd") isReady];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((ATOnewayInterstitialCustomEvent*)interstitial.customEvent) showWithTag:@""];
    if ([interstitial.unitGroup.content[@"is_video"] boolValue]) {
        [NSClassFromString(@"OWInterstitialAd") show:viewController];
    } else {
        [NSClassFromString(@"OWInterstitialImageAd") show:viewController];
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameOneway]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameOneway];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"OneWaySDK") getVersion] forNetwork:kNetworkNameOneway];
            [NSClassFromString(@"OneWaySDK") configure:serverInfo[@"publisher_id"]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"OWInterstitialAd") != nil && NSClassFromString(@"OWInterstitialImageAd") != nil) {
        _customEvent = [[ATOnewayInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if ([serverInfo[@"is_video"] boolValue]) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{ [NSClassFromString(@"OWInterstitialAd") initWithDelegate:[ATOWInterstitialDelegate sharedDelegate]]; });
            if ([NSClassFromString(@"OWInterstitialAd") isReady]) { [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialReadyNotification object:nil]; }
        } else {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{ [NSClassFromString(@"OWInterstitialImageAd") initWithDelegate:[ATOWInterstitialDelegate sharedDelegate]]; });
            if ([NSClassFromString(@"OWInterstitialImageAd") isReady]) { [[NSNotificationCenter defaultCenter] postNotificationName:kATOnewayInterstitialImageReadyNotification object:nil]; }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Oneway"]}]);
    }
}
@end
