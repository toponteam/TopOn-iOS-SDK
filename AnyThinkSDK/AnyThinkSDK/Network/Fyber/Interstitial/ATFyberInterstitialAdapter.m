//
//  ATFyberInterstitialAdapter.m
//  AnyThinkFyberInterstitialAdapter
//
//  Created by Topon on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATFyberInterstitialAdapter.h"
#import "ATFyberInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATInterstitialManager.h"
#import "ATFyberBaseManager.h"

@interface ATFyberInterstitialAdapter ()
@property (nonatomic, readonly) id<ATIAVideoContentController> videoContentController;
@property (nonatomic, readonly) id<ATIAMRAIDContentController> MRAIDContentController;
@property (nonatomic, readonly) id<ATIAFullscreenUnitController> fullscreenUnitController;
@property (nonatomic, readonly) id<ATIAAdSpot> adSpot;
@property(nonatomic, readonly) ATFyberInterstitialCustomEvent *customEvent;
@end

@implementation ATFyberInterstitialAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return customObject != nil;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    ATFyberInterstitialCustomEvent *customEvent = (ATFyberInterstitialCustomEvent*)interstitial.customEvent;
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
        _customEvent = [[ATFyberInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        
        id<ATIAAdRequest> request = [NSClassFromString(@"IAAdRequest") build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
            builder.useSecureConnections = NO;
            builder.spotID = serverInfo[@"spot_id"];
            builder.muteAudio = [serverInfo[@"video_muted"] boolValue];
        }];
        
        _videoContentController = [NSClassFromString(@"IAVideoContentController") build:^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
            builder.videoContentDelegate = self.customEvent;
        }];
        
        _MRAIDContentController = [NSClassFromString(@"IAMRAIDContentController") build:^(id<IAMRAIDContentControllerBuilder>  _Nonnull builder) {
            builder.MRAIDContentDelegate = self.customEvent;
        }];
        
        _fullscreenUnitController = [NSClassFromString(@"IAFullscreenUnitController") build:^(id<IAFullscreenUnitControllerBuilder>  _Nonnull builder) {
            builder.unitDelegate = self.customEvent;
            [builder addSupportedContentController:self.videoContentController];
            [builder addSupportedContentController:self.MRAIDContentController];
        }];
        
        _adSpot = [NSClassFromString(@"IAAdSpot") build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
            builder.adRequest = request;
            [builder addSupportedUnitController:self.fullscreenUnitController];
        }];
        
        [_adSpot fetchAdWithCompletion:^(id<ATIAAdSpot>  _Nonnull adSpot, id  _Nullable adModel, NSError * _Nullable error) {
            if (error != nil) {
                [self->_customEvent handleLoadingFailure:error];
            } else {
                self->_customEvent.fullscreenUnitController = self->_fullscreenUnitController;
//                [self->_customEvent handleAssets:@{kInterstitialAssetsCustomEventKey:self->_customEvent, kInterstitialAssetsUnitIDKey:[serverInfo[@"spot_id"] length] > 0 ? serverInfo[@"spot_id"] : @"", kAdAssetsCustomObjectKey:self->_fullscreenUnitController}];
                [self->_customEvent trackInterstitialAdLoaded:self->_fullscreenUnitController adExtra:nil];
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Fyber"]}]);
    }
}

@end
