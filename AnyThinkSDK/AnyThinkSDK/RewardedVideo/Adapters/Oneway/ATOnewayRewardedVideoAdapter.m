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
NSString const* kOnewayCustomEventKey = @"custom_event";
@interface ATOnewayRewardedVideoAdapter()
@property(nonatomic, readonly) ATOnewayRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kPublisherIDKey = @"publisher_id";
@implementation ATOnewayRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kPublisherIDKey]} unitGroup:unitGroup];
}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATOnewayRewardedVideoCustomEvent *customEvent = [[ATOnewayRewardedVideoCustomEvent alloc] initWithUnitID:unitGroup.content[kPublisherIDKey] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:customEvent.unitID, kAdAssetsCustomObjectKey:customEvent, kRewardedVideoAssetsCustomEventKey:customEvent} unitGroup:unitGroup];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [NSClassFromString(@"OWRewardedAd") isReady];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [NSClassFromString(@"OWRewardedAd") isReady];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATOnewayRewardedVideoCustomEvent *customEvent = rewardedVideo.customObject;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [NSClassFromString(@"OWRewardedAd") show:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameOneway]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameOneway];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"OneWaySDK") getVersion] forNetwork:kNetworkNameOneway];

            [NSClassFromString(@"OneWaySDK") configure:info[kPublisherIDKey]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"OWRewardedAd")) {
        _customEvent = [[ATOnewayRewardedVideoCustomEvent alloc] initWithUnitID:info[kPublisherIDKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        
        if ([NSClassFromString(@"OWRewardedAd") isReady]) {
            NSArray<id<ATAd>>* ads = [[ATRewardedVideoManager sharedManager] adsWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID];
            __block id<ATAd> ad = nil;
            [ads enumerateObjectsUsingBlock:^(id<ATAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.unitID isEqualToString:info[kPublisherIDKey]]) {
                    ad = obj;
                    *stop = YES;
                }
            }];
            if (ad == nil) {
                completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:@"OWRewardedAd can't load rewarded video this time, please relaunch the app."}]);
            } else {
                [_customEvent oneWaySDKRewardedAdReady];
            }
        } else {
            if ([[ATRewardedVideoManager sharedManager] firstLoadFlagForNetwork:kNetworkNameOneway]) {
                completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:@"OWRewardedAd class' initWithDelegate: method has been invoked before and its isReady method returns NO at the moment; please try again later to check it."}]);
            } else {
                [[ATRewardedVideoManager sharedManager] setFirstLoadFlagForNetwork:kNetworkNameOneway];
                [NSClassFromString(@"OWRewardedAd") initWithDelegate:_customEvent];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Oneway"]}]);
    }
}
@end
