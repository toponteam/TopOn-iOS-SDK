//
//  ATStartAppRewardedVideoAdapter.m
//  AnyThinkStartAppRewardedVideoAdapter
//
//  Created by Martin Lau on 2020/3/18.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "ATLogger.h"
#import "Utilities.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATAppSettingManager.h"
#import "ATStartAppRewardedVideoCustomEvent.h"
#import "ATStartAppBaseManager.h"

static NSString *kStartAppAdClass = @"STAStartAppAd";
static NSString *kAdTagKey = @"ad_tag";

@interface ATStartAppRewardedVideoAdapter()
@property(nonatomic, readonly) id<ATSTAStartAppAd> rewardedVideoAd;
@property(nonatomic, readonly) ATStartAppRewardedVideoCustomEvent *customEvent;
@end

@implementation ATStartAppRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id<ATSTAStartAppAd>)customObject info:(NSDictionary*)info {
    return [customObject isReady];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATStartAppRewardedVideoCustomEvent *customEvent = (ATStartAppRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [((id<ATSTAStartAppAd>)rewardedVideo.customObject) showAdWithAdTag:rewardedVideo.unitGroup.content[kAdTagKey]];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATStartAppBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kStartAppAdClass) != nil) {
        _customEvent = [[ATStartAppRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            id<ATSTAAdPreferences> pre = [NSClassFromString(@"STAAdPreferences") preferencesWithMinCPM:0];
            pre.adTag = serverInfo[kAdTagKey];
            
            self->_rewardedVideoAd = [[NSClassFromString(kStartAppAdClass) alloc] init];
            [self->_rewardedVideoAd loadRewardedVideoAdWithDelegate:self->_customEvent withAdPreferences:pre];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"StartApp"]}]);
    }
}
@end
