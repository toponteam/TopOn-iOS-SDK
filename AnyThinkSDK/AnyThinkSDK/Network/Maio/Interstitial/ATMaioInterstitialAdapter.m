//
//  ATMaioInterstitialAdapter.m
//  AnyThinkMaioInterstitialAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMaioInterstitialAdapter.h"
#import "ATMaioInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import <objc/runtime.h>
#import "ATMaioBaseManager.h"

@interface ATMaioInterstitialAdapter()
@property(nonatomic, readonly) ATMaioInterstitialCustomEvent *customEvent;
@end

static NSString *const kMediaIDKey = @"media_id";
static NSString *const kZoneIDKey = @"zone_id";
@implementation ATMaioInterstitialAdapter
+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
    ATMaioInterstitialCustomEvent *customEvent = [[ATMaioInterstitialCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
    [NSClassFromString(kMaioClassName) addDelegateObject:customEvent];
    ATInterstitial *ad = [[ATInterstitial alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kInterstitialAssetsUnitIDKey:[customEvent.unitID length] > 0 ? customEvent.unitID : @"", kInterstitialAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:customEvent.unitID != nil ? customEvent.unitID : @""} unitGroup:unitGroup finalWaterfall:finalWaterfall];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [NSClassFromString(kMaioClassName) canShowAtZoneId:info[kZoneIDKey]];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [NSClassFromString(kMaioClassName) canShowAtZoneId:info[kZoneIDKey]];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSClassFromString(kMaioClassName) showAtZoneId:interstitial.unitGroup.content[kZoneIDKey] vc:viewController];
    });
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
        _customEvent = [[ATMaioInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if ([NSClassFromString(kMaioClassName) canShowAtZoneId:serverInfo[kZoneIDKey]]) {
            [NSClassFromString(kMaioClassName) addDelegateObject:_customEvent];
            [_customEvent handleAssets:@{kInterstitialAssetsUnitIDKey:[_customEvent.unitID length] > 0 ? _customEvent.unitID : @"", kInterstitialAssetsCustomEventKey:_customEvent, kAdAssetsCustomObjectKey:_customEvent.unitID != nil ? _customEvent.unitID : @""}];
        } else {
            [NSClassFromString(kMaioClassName) startWithMediaId:serverInfo[kMediaIDKey] delegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Maio"]}]);
    }
}
@end
