//
//  ATFyberRewardedVideoAdapter.m
//  AnyThinkFyberRewardedVideoAdapter
//
//  Created by Topon on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATFyberRewardedVideoAdapter.h"
#import "ATFyberRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATFyberBaseManager.h"

@interface ATFyberRewardedVideoAdapter ()
@property (nonatomic, readonly) id<ATIAVideoContentController> videoContentController;
@property (nonatomic, readonly) id<ATIAFullscreenUnitController> fullscreenUnitController;
@property (nonatomic, readonly) id<ATIAAdSpot> adSpot;
@property (nonatomic, readonly) ATFyberRewardedVideoCustomEvent *customEvent;
@end

@implementation ATFyberRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return customObject != nil;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATFyberRewardedVideoCustomEvent *customEvent = (ATFyberRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    customEvent.viewController = viewController;
    [customEvent.fullscreenUnitController showAdAnimated:YES completion:nil];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATFyberBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"IAAdRequest") != nil && NSClassFromString(@"IAVideoContentController") != nil && NSClassFromString(@"IAFullscreenUnitController") != nil && NSClassFromString(@"IAAdSpot") != nil) {
        _customEvent = [[ATFyberRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        
        id<ATIAAdRequest> request = [NSClassFromString(@"IAAdRequest") build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
            builder.useSecureConnections = NO;
            builder.spotID = serverInfo[@"spot_id"];
        }];
        
        _videoContentController = [NSClassFromString(@"IAVideoContentController") build:^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
            builder.videoContentDelegate = self.customEvent;
        }];
        
        _fullscreenUnitController = [NSClassFromString(@"IAFullscreenUnitController") build:^(id<IAFullscreenUnitControllerBuilder>  _Nonnull builder) {
            builder.unitDelegate = self.customEvent;
            [builder addSupportedContentController:self.videoContentController];
        }];
        
        _adSpot = [NSClassFromString(@"IAAdSpot") build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
            builder.adRequest = request;
            [builder addSupportedUnitController:self.fullscreenUnitController];
        }];
        
        [_adSpot fetchAdWithCompletion:^(id<ATIAAdSpot>  _Nullable adSpot, id  _Nullable adModel, NSError * _Nullable error) {
            if (error) {
                [self->_customEvent trackRewardedVideoAdLoadFailed:error];
            } else {
                self->_customEvent.fullscreenUnitController = self->_fullscreenUnitController;
                [self->_customEvent trackRewardedVideoAdLoaded:self->_fullscreenUnitController adExtra:nil];
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Fyber"]}]);
    }
}
@end
