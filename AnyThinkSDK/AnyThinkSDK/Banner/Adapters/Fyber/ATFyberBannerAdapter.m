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

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFyber]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFyber];
                [[ATAPI sharedInstance] setVersion:((id<ATIASDKCore>)[NSClassFromString(@"IASDKCore") sharedInstance]).version forNetwork:kNetworkNameFyber];
                [[NSClassFromString(@"IASDKCore") sharedInstance] initWithAppID:info[@"app_id"]];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"IAAdRequest") != nil && NSClassFromString(@"IAAdSpot") != nil && NSClassFromString(@"IAViewUnitController") != nil) {
        _customEvent = [[ATFyberBannerCustomEvent alloc] initWithUnitID:info[@"spot_id"] customInfo:info];
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
            builder.spotID = info[@"spot_id"];
        }];
        
        _spot = [NSClassFromString(@"IAAdSpot") build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
            builder.adRequest = request;
            [builder addSupportedUnitController:self.viewUnitController];
        }];
        
        [_spot fetchAdWithCompletion:^(id<ATIAAdSpot>  _Nullable adSpot, id  _Nullable adModel, NSError * _Nullable error) {
            if (error != nil) {
                [self->_customEvent handleLoadingFailure:error];
            } else {
                self->_customEvent.spot = self->_spot;
                self->_customEvent.MRAIDContentController = self->_MRAIDContentController;
                self->_customEvent.viewUnitController = self->_viewUnitController;
                [self->_customEvent handleAssets:@{kBannerAssetsCustomEventKey:self->_customEvent, kBannerAssetsUnitIDKey:info[@"spot_id"]}];
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Fyber"]}]);
    }
}
@end
