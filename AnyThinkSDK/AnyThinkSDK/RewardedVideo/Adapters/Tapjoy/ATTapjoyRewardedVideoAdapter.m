//
//  ATTapjoyRewardedVideoAdapter.m
//  AnyThinkTapjoyRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTapjoyRewardedVideoAdapter.h"
#import "ATTapjoyRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
NSString *const kTapjoyRVCustomEventKey = @"custom_event";

static NSString *const kConnectSuccessNotification = @"TJC_Connect_Success";
static NSString *const kConnectFailureNotification = @"TJC_Connect_Failed";
@interface ATTapjoyRewardedVideoAdapter()
@property(nonatomic, readonly) ATTapjoyRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *info;
@end

static NSString *const kTapjoyClassName = @"Tapjoy";
static NSString *const kPlacementNameKey = @"placement_name";
@implementation ATTapjoyRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:kPlacementNameKey} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id<ATTJPlacement>)customObject info:(NSDictionary*)info {
    return customObject.isContentReady;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATTapjoyRewardedVideoCustomEvent *customEvent = objc_getAssociatedObject(rewardedVideo.customObject, (__bridge_retained void*)kTapjoyRVCustomEventKey);
    customEvent.delegate = delegate;
    customEvent.rewardedVideo = rewardedVideo;
    ((id<ATTJPlacement>)rewardedVideo.customObject).videoDelegate = customEvent;
    [((id<ATTJPlacement>)rewardedVideo.customObject) showContentWithViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        _info = info;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"Tapjoy") getVersion] forNetwork:kNetworkNameTapjoy];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameTapjoy]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameTapjoy];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameTapjoy]) {
                    [NSClassFromString(kTapjoyClassName) setUserConsent:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameTapjoy][kTapjoyConsentValueKey]];
                    [NSClassFromString(kTapjoyClassName) subjectToGDPR:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameTapjoy][kTapjoyGDPRSubjectionKey] boolValue]];
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) {
                        [NSClassFromString(kTapjoyClassName) setUserConsent:limit ? @"0" : @"1"];
                        [NSClassFromString(kTapjoyClassName) subjectToGDPR:[[ATAPI sharedInstance] inDataProtectionArea]];
                    }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kTapjoyClassName)) {
        _customEvent = [[ATTapjoyRewardedVideoCustomEvent alloc] initWithUnitID:info[kPlacementNameKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        if ([NSClassFromString(kTapjoyClassName) isConnected]) {
            [ATLogger logMessage:@"Tapjoy: Connected alreadly, will start load" type:ATLogTypeExternal];
            [self startLoad];
        } else {
            [ATLogger logMessage:@"Tapjoy: Not yet connected, will connect" type:ATLogTypeExternal];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(tjcConnectSuccess:)
                                                         name:kConnectSuccessNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(tjcConnectFail:)
                                                         name:kConnectFailureNotification
                                                       object:nil];
            [NSClassFromString(kTapjoyClassName) connect:info[@"sdk_key"]];
        }
    } else {
        [ATLogger logError:@"Tapjoy: Failed to load, Tapjoy class not found." type:ATLogTypeExternal];
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, kTapjoyClassName]}]);
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) startLoad {
    if ([[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)_info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:_info[kAdapterCustomInfoRequestIDKey]] containsObjectForKey:kATAdLoadingExtraUserIDKey]) [NSClassFromString(kTapjoyClassName) setUserID:[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)_info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:_info[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey]];
    id<ATTJPlacement> placement = [NSClassFromString(@"TJPlacement") placementWithName:_info[kPlacementNameKey] delegate:_customEvent];
    [placement requestContent];
}
#pragma mark - notification
-(void)tjcConnectSuccess:(NSNotification*)notifyObj {
    [ATLogger logMessage:@"tjcConnectSuccess:" type:ATLogTypeExternal];
    [self startLoad];
}

-(void)tjcConnectFail:(NSNotification*)notifyObj {
    [ATLogger logError:@"tjcConnectFail:" type:ATLogTypeExternal];
}
@end
