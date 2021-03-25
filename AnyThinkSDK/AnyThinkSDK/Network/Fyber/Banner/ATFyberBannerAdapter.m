//
//  ATFyberBannerAdapter.m
//  AnyThinkFyberBannerAdapter
//
//  Created by Martin Lau on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATFyberBannerAdapter.h"
#import "ATAPI+Internal.h"
#import "ATAdCustomEvent.h"
#import "ATFyberBannerCustomEvent.h"
#import "ATBannerManager.h"
#import "ATFyberBaseManager.h"

@interface ATFyberBannerAdapter()
@property(nonatomic, readonly) id<ATIAViewUnitController> viewUnitController;
@property(nonatomic, readonly) id<ATIAMRAIDContentController> MRAIDContentController;
@property(nonatomic, readonly) ATFyberBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATIAAdSpot> spot;
@end
@implementation ATFyberBannerAdapter
+(void) showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    ATFyberBannerCustomEvent *customEvent = (ATFyberBannerCustomEvent*)banner.customEvent;
    [customEvent.viewUnitController showAdInParentView:view];
    customEvent.viewUnitController.adView.center = view.center;
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATFyberBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"IAAdRequest") != nil && NSClassFromString(@"IAAdSpot") != nil && NSClassFromString(@"IAViewUnitController") != nil) {
        _customEvent = [[ATFyberBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        
        
        _MRAIDContentController = [NSClassFromString(@"IAMRAIDContentController") build:^(id<IAMRAIDContentControllerBuilder>  _Nonnull builder) {
            builder.MRAIDContentDelegate = self->_customEvent;
        }];
        
        _viewUnitController = [NSClassFromString(@"IAViewUnitController") build:^(id<IAViewUnitControllerBuilder>  _Nonnull builder) {
            builder.unitDelegate = self->_customEvent;
            [builder addSupportedContentController:self.MRAIDContentController];
        }];
        
        id<ATIAAdRequest> request = [NSClassFromString(@"IAAdRequest") build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
            builder.useSecureConnections = NO;
            builder.spotID = serverInfo[@"spot_id"];
        }];
        
        _spot = [NSClassFromString(@"IAAdSpot") build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
            builder.adRequest = request;
            [builder addSupportedUnitController:self.viewUnitController];
        }];
        
        [_spot fetchAdWithCompletion:^(id<ATIAAdSpot>  _Nullable adSpot, id  _Nullable adModel, NSError * _Nullable error) {
            if (error != nil) {
                [self->_customEvent trackBannerAdLoadFailed:error];
            } else {
                self->_customEvent.spot = self->_spot;
                self->_customEvent.MRAIDContentController = self->_MRAIDContentController;
                self->_customEvent.viewUnitController = self->_viewUnitController;
                [self->_customEvent trackBannerAdLoaded:nil adExtra:nil];
//                [self->_customEvent handleAssets:@{kBannerAssetsCustomEventKey:self->_customEvent, kBannerAssetsUnitIDKey:serverInfo[@"spot_id"]}];
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Fyber"]}]);
    }
}
@end
