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
#import "ATMaioBaseManager.h"

static NSString *const kMediaIDKey = @"media_id";
static NSString *const kZoneIDKey = @"zone_id";

@interface ATMaioRewardedVideoAdapter()
@property(nonatomic, readonly) ATMaioRewardedVideoCustomEvent *customEvent;
@end
@implementation ATMaioRewardedVideoAdapter

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    ATMaioRewardedVideoCustomEvent *customEvent = [[ATMaioRewardedVideoCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
    [NSClassFromString(kMaioClassName) addDelegateObject:customEvent];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:[customEvent.unitID length] > 0 ? customEvent.unitID : @"", kRewardedVideoAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:customEvent.unitID != nil ? customEvent.unitID : @""} unitGroup:unitGroup finalWaterfall:finalWaterfall];
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

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMaioBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kMaioClassName) != nil) {
        _customEvent = [[ATMaioRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if ([NSClassFromString(kMaioClassName) canShowAtZoneId:serverInfo[kZoneIDKey]]) {
            [NSClassFromString(kMaioClassName) addDelegateObject:_customEvent];
            [_customEvent trackRewardedVideoAdLoaded:_customEvent.unitID != nil ? _customEvent.unitID : @"" adExtra:nil];
        } else {
            [NSClassFromString(kMaioClassName) startWithMediaId:serverInfo[kMediaIDKey] delegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Maio"]}]);
    }
}
@end
