//
//  ATInmobiRewardedVideoAdapter.m
//  AnyThinkInmobiRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "ATInmobiRewardedVideoCustomEvent.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAppSettingManager.h"

NSString *const kInmobiRVAssetsCustomEventKey = @"inmobi_rewarded_video_custom_object";
@interface ATInmobiRewardedVideoAdapter()
@property(nonatomic, readonly) ATInmobiRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATIMInterstitial> interstitial;
@end

static NSString *const kUnitIDKey = @"unit_id";
@implementation ATInmobiRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kUnitIDKey]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id<ATIMInterstitial>)customObject info:(NSDictionary*)info {
    return customObject != nil;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ((ATInmobiRewardedVideoCustomEvent*)objc_getAssociatedObject(rewardedVideo.customObject, (__bridge_retained void*)kInmobiRVAssetsCustomEventKey)).rewardedVideo = rewardedVideo;
    ((ATInmobiRewardedVideoCustomEvent*)objc_getAssociatedObject(rewardedVideo.customObject, (__bridge_retained void*)kInmobiRVAssetsCustomEventKey)).delegate = delegate;
    [((id<ATIMInterstitial>)rewardedVideo.customObject) showFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"IMSdk") getVersion] forNetwork:kNetworkNameInmobi];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameInmobi]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameInmobi];
                [NSClassFromString(@"IMSdk") initWithAccountID:info[@"app_id"]];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameInmobi]) {
                    [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":[ATAPI sharedInstance].networkConsentInfo[kNetworkNameInmobi][kInmobiConsentStringKey], @"gdpr":[ATAPI sharedInstance].networkConsentInfo[kNetworkNameInmobi][kInmobiGDPRStringKey]}];
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) { [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":limit ? @"false" : @"true", @"gdpr":[[ATAPI sharedInstance] inDataProtectionArea] ? @"1" : @"0"}]; }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"IMInterstitial") != nil) {
        _customEvent = [[ATInmobiRewardedVideoCustomEvent alloc] initWithUnitID:info[kUnitIDKey] customInfo:info];
        _customEvent.requestNumber = [info[@"request_num"] longValue];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        id<ATIMInterstitial> interstitial = (id<ATIMInterstitial>)[[NSClassFromString(@"IMInterstitial") alloc] initWithPlacementId:[info[kUnitIDKey] integerValue]  delegate:_customEvent];
        _interstitial = interstitial;
        _customEvent.interstitial = interstitial;
        for (NSInteger i = 0; i < [info[@"request_num"] integerValue]; i++) [interstitial load];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Inmobi"]}]);
    }
}
@end
