//
//  ATMaioRewardedVideoAdapter.m
//  AnyThinkMaioRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMaioRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATMaioRewardedVideoCustomEvent.h"
static NSString *const kMaioClassName = @"Maio";
static NSString *const kMediaIDKey = @"media_id";
static NSString *const kZoneIDKey = @"zone_id";

@interface ATMaioRewardedVideoAdapter()
@property(nonatomic, readonly) ATMaioRewardedVideoCustomEvent *customEvent;
@end
@implementation ATMaioRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kZoneIDKey]} unitGroup:unitGroup];
}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATMaioRewardedVideoCustomEvent *customEvent = [[ATMaioRewardedVideoCustomEvent alloc] initWithUnitID:unitGroup.content[kZoneIDKey] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
    [NSClassFromString(kMaioClassName) addDelegateObject:customEvent];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:[customEvent.unitID length] > 0 ? customEvent.unitID : @"", kRewardedVideoAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:customEvent.unitID != nil ? customEvent.unitID : @""} unitGroup:unitGroup];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [NSClassFromString(kMaioClassName) canShowAtZoneId:info[kZoneIDKey]];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [NSClassFromString(kMaioClassName) canShowAtZoneId:info[kZoneIDKey]];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ((ATMaioRewardedVideoCustomEvent*)rewardedVideo.customEvent).delegate = delegate;
    [NSClassFromString(kMaioClassName) showAtZoneId:rewardedVideo.unitGroup.content[kZoneIDKey] vc:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMaio]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMaio];
                if (NSClassFromString(kMaioClassName) != nil) { [[ATAPI sharedInstance] setVersion:[NSClassFromString(kMaioClassName) sdkVersion] forNetwork:kNetworkNameMaio]; }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kMaioClassName) != nil) {
        _customEvent = [[ATMaioRewardedVideoCustomEvent alloc] initWithUnitID:info[kZoneIDKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if ([NSClassFromString(kMaioClassName) canShowAtZoneId:info[kZoneIDKey]]) {
            [NSClassFromString(kMaioClassName) addDelegateObject:_customEvent];
            [_customEvent handleAssets:@{kRewardedVideoAssetsUnitIDKey:[_customEvent.unitID length] > 0 ? _customEvent.unitID : @"", kRewardedVideoAssetsCustomEventKey:_customEvent, kAdAssetsCustomObjectKey:_customEvent.unitID != nil ? _customEvent.unitID : @""}];
        } else {
            [NSClassFromString(kMaioClassName) startWithMediaId:info[kMediaIDKey] delegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Maio"]}]);
    }
}
@end
