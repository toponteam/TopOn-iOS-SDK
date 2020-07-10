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
static NSString *kStartAppAdClass = @"STAStartAppAd";
static NSString *kAdTagKey = @"ad_tag";

@interface ATStartAppRewardedVideoAdapter()
@property(nonatomic, readonly) id<ATSTAStartAppAd> rewardedVideoAd;
@property(nonatomic, readonly) ATStartAppRewardedVideoCustomEvent *customEvent;
@end

@implementation ATStartAppRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:@""} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id<ATSTAStartAppAd>)customObject info:(NSDictionary*)info {
    return [customObject isReady];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATStartAppRewardedVideoCustomEvent *customEvent = (ATStartAppRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [((id<ATSTAStartAppAd>)rewardedVideo.customObject) showAdWithAdTag:rewardedVideo.unitGroup.content[kAdTagKey]];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameStartApp]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameStartApp];
            dispatch_async(dispatch_get_main_queue(), ^{
                id<ATSTAStartAppSDK> sdk = [NSClassFromString(@"STAStartAppSDK") sharedInstance];
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) { [sdk setUserConsent:!limit forConsentType:@"pas" withTimestamp:[[NSDate date] timeIntervalSince1970]]; }
                sdk.appID = info[@"app_id"];
            });
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kStartAppAdClass) != nil) {
        _customEvent = [[ATStartAppRewardedVideoCustomEvent alloc] initWithUnitID:@"" customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            id<ATSTAAdPreferences> pre = [NSClassFromString(@"STAAdPreferences") preferencesWithMinCPM:0];
            pre.adTag = info[kAdTagKey];
            
            self->_rewardedVideoAd = [[NSClassFromString(kStartAppAdClass) alloc] init];
            [self->_rewardedVideoAd loadRewardedVideoAdWithDelegate:self->_customEvent withAdPreferences:pre];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"StartApp"]}]);
    }
}
@end
