//
//  ATChartboostRewardedVideoAdapter.m
//  ATChartboostRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATChartboostRewardedVideoAdapter.h"
#import "ATChartboostRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
@interface ATChartboostRewardedVideoAdapter()
@property(nonatomic, readonly) ATChartboostRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) NSString *location;
@property(nonatomic, readonly) void (^LoadCompletionBlock)(NSArray<NSDictionary *> *, NSError *);
@property(nonatomic, readonly) NSDictionary *info;
@property(nonatomic, readonly) id<ATCHBRewarded> rewardedVideo;
@end

static NSString *const kUnitIDKey = @"unit_id";
static NSString *const kLocationKey = @"location";
static NSString *const kATChartboostInitNotification = @"com.anythink.ChartboostInitNotification";
@implementation ATChartboostRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kLocationKey]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id<ATCHBRewarded>)customObject info:(NSDictionary*)info {
    return [customObject isCached];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    rewardedVideo.customEvent.delegate = delegate;
    [(id<ATCHBRewarded>)(rewardedVideo.customObject) showFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{ [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"Chartboost") getSDKVersion] forNetwork:kNetworkNameChartboost]; });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"CHBRewarded") != nil && NSClassFromString(@"Chartboost") != nil) {
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameChartboost usingBlock:^NSInteger(NSInteger currentValue) {
            if (currentValue == 0) {
                [NSClassFromString(@"Chartboost") startWithAppId:info[@"app_id"] appSignature:info[@"app_signature"] completion:^(BOOL success) {
                    if (success) {
                        [[ATAPI sharedInstance] setInitFlag:2 forNetwork:kNetworkNameChartboost];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kATChartboostInitNotification object:nil];
                        [self loadAdUsingInfo:info completion:completion];
                    }
                }];
                return 1;
            } else if (currentValue == 1) {
                self->_info = info;
                self->_LoadCompletionBlock = completion;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATChartboostInitNotification object:nil];
                return currentValue;
            } else if (currentValue == 2) {
                [self loadAdUsingInfo:info completion:completion];
                return currentValue;
            }
            return currentValue;
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Chartboost"]}]);
    }
}

-(void) loadAdUsingInfo:(NSDictionary*)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATChartboostRewardedVideoCustomEvent alloc] initWithUnitID:info[kLocationKey] customInfo:info];
    _customEvent.requestCompletionBlock = completion;
    _rewardedVideo = [[NSClassFromString(@"CHBRewarded") alloc] initWithLocation:info[kLocationKey] delegate:_customEvent];
    _customEvent.rewardedVideoAd = _rewardedVideo;
    [_rewardedVideo cache];
}

-(void) handleInitNotification:(NSNotification*)notification { [self loadAdUsingInfo:_info completion:_LoadCompletionBlock]; }
@end
