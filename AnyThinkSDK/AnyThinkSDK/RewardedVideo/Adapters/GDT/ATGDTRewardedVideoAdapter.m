//
//  ATGDTRewardedVideoAdapter.m
//  AnyThinkGDTRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/12/11.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTRewardedVideoAdapter.h"
#import "ATGDTRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
@interface ATGDTRewardedVideoAdapter()
@property(nonatomic, readonly) ATGDTRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGDTRewardVideoAd> rewardedVideoAd;
@end
@implementation ATGDTRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"unit_id"]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id<ATGDTRewardVideoAd>)customObject info:(NSDictionary*)info {
    return customObject.expiredTimestamp > [[NSDate date] timeIntervalSince1970] && customObject.adValid;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATGDTRewardedVideoCustomEvent *customEvent = (ATGDTRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [rewardedVideo.customObject showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameGDT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameGDT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"GDTSDKConfig") sdkVersion] forNetwork:kNetworkNameGDT];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GDTRewardVideoAd") != nil) {
        _customEvent = [[ATGDTRewardedVideoCustomEvent alloc] initWithUnitID:info[@"unit_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        _rewardedVideoAd = [[NSClassFromString(@"GDTRewardVideoAd") alloc] initWithAppId:info[@"app_id"] placementId:info[@"unit_id"]];
        _rewardedVideoAd.delegate = _customEvent;
        [_rewardedVideoAd loadAd];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GDT"]}]);
    }
}
@end
