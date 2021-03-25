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
#import "ATGDTBaseManager.h"

@interface ATGDTRewardedVideoAdapter()
@property(nonatomic, readonly) ATGDTRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGDTRewardVideoAd> rewardedVideoAd;
@property(nonatomic, readonly) id<ATGDTNativeExpressRewardVideoAd> expressRewardVideoAd;
@end
@implementation ATGDTRewardedVideoAdapter
+(BOOL) adReadyWithCustomObject:(id<ATGDTRewardVideoAd>)customObject info:(NSDictionary*)info {
    return customObject.expiredTimestamp > [[NSDate date] timeIntervalSince1970] && customObject.adValid;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATGDTRewardedVideoCustomEvent *customEvent = (ATGDTRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [rewardedVideo.customObject showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATGDTBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GDTRewardVideoAd") != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_customEvent = [[ATGDTRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            self->_customEvent.requestCompletionBlock = completion;
            self->_customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
            
            id<ATGDTServerSideVerificationOptions> ssv = [[NSClassFromString(@"GDTServerSideVerificationOptions") alloc] init];
            if (localInfo[kATAdLoadingExtraUserIDKey] != nil) { ssv.userIdentifier = localInfo[kATAdLoadingExtraUserIDKey]; }
            if (localInfo[kATAdLoadingExtraMediaExtraKey] != nil) { ssv.customRewardString = localInfo[kATAdLoadingExtraMediaExtraKey]; }
            
            if ([serverInfo[@"personalized_template"] integerValue] == 1) {
                self->_expressRewardVideoAd = [[NSClassFromString(@"GDTNativeExpressRewardVideoAd") alloc] initWithPlacementId:serverInfo[@"unit_id"]];
                self->_expressRewardVideoAd.videoMuted = [serverInfo[@"video_muted"] boolValue];
                self->_expressRewardVideoAd.delegate = self->_customEvent;
                self->_expressRewardVideoAd.serverSideVerificationOptions = ssv;
                [self->_expressRewardVideoAd loadAd];
            }else {
                self->_rewardedVideoAd = [[NSClassFromString(@"GDTRewardVideoAd") alloc] initWithPlacementId:serverInfo[@"unit_id"]];
                self->_rewardedVideoAd.videoMuted = [serverInfo[@"video_muted"] boolValue];
                self->_rewardedVideoAd.delegate = self->_customEvent;
                self->_rewardedVideoAd.serverSideVerificationOptions = ssv;
                [self->_rewardedVideoAd loadAd];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GDT"]}]);
    }
}
@end
