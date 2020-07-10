//
//  ATChartboostBannerAdapter.m
//  AnyThinkChartboostBannerAdapter
//
//  Created by Martin Lau on 2020/6/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATChartboostBannerAdapter.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATChartboostBannerCustomEvent.h"

@interface ATChartboostBannerAdapter()
@property(nonatomic, readonly) id<ATCHBBanner> bannerAd;
@property(nonatomic, readonly) ATChartboostBannerCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *info;
@property(nonatomic, readonly) void (^LoadCompletionBlock)(NSArray<NSDictionary *> *, NSError *);
@end
static NSString *const kChartboostClassName = @"Chartboost";
static NSString *const kLocationKey = @"location";
static NSString *const kATChartboostInitNotification = @"com.anythink.ChartboostInitNotification";
@implementation ATChartboostBannerAdapter
+(void) showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    id<ATCHBBanner> bannerAd = ((id<ATCHBCacheEvent>)(banner.customObject)).ad;
    bannerAd.frame = CGRectMake(CGRectGetMidX(view.bounds) - banner.unitGroup.adSize.width / 2.0f, CGRectGetMidY(view.bounds) - banner.unitGroup.adSize.height / 2.0f, banner.unitGroup.adSize.width, banner.unitGroup.adSize.height);
    [view addSubview:(UIView*)bannerAd];
    [(id<ATCHBBanner>)(((id<ATCHBCacheEvent>)(banner.customObject)).ad) showFromViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:banner.placementModel.placementID requestID:banner.requestID]];
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
    if (NSClassFromString(@"CHBBanner") != nil && NSClassFromString(@"Chartboost") != nil) {
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
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Chartboost"]}]);
    }
}

-(void) loadAdUsingInfo:(NSDictionary*)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATChartboostBannerCustomEvent alloc] initWithUnitID:info[kLocationKey] customInfo:info];
    _customEvent.requestCompletionBlock = completion;
    ATUnitGroupModel *ug = info[kAdapterCustomInfoUnitGroupModelKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_bannerAd = [[NSClassFromString(@"CHBBanner") alloc] initWithSize:ug.adSize location:info[kLocationKey] != nil ? info[kLocationKey] : @"Main Menu" delegate:self->_customEvent];
        if ([info[@"nw_rft"] integerValue] == 0) { self->_bannerAd.automaticallyRefreshesContent = NO; }
        [self->_bannerAd cache];
    });
}

-(void) handleInitNotification:(NSNotification*)notification { [self loadAdUsingInfo:_info completion:_LoadCompletionBlock]; }
@end
