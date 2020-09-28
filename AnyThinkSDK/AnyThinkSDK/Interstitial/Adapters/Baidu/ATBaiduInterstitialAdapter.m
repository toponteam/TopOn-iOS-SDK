//
//  ATBaiduInterstitialAdapter.m
//  AnyThinkBaiduInterstitialAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBaiduInterstitialAdapter.h"
#import "ATBaiduInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"

@interface ATBaiduInterstitialAdapter()
@property(nonatomic, readonly) ATBaiduInterstitialCustomEvent *customEvent;
@property(nonatomic) id<ATBaiduMobAdInterstitial> interstitial;
@end
@implementation ATBaiduInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATBaiduMobAdInterstitial>)customObject info:(NSDictionary*)info {
    return customObject.isReady;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        [interstitial.customObject presentFromRootViewController:viewController];
    });
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameBaidu];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameBaidu]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameBaidu];
                id<BaiduMobAdSetting> setting = [NSClassFromString(@"BaiduMobAdSetting") sharedInstance];
                setting.supportHttps = YES;
                [NSClassFromString(@"BaiduMobAdSetting") setMaxVideoCacheCapacityMb:30];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BaiduMobAdInterstitial") != nil) {
        _customEvent = [[ATBaiduInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.interstitial = [[NSClassFromString(@"BaiduMobAdInterstitial") alloc] init];
            weakSelf.interstitial.delegate = weakSelf.customEvent;
            weakSelf.interstitial.AdUnitTag = serverInfo[@"ad_place_id"];
            weakSelf.interstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;
            [weakSelf.interstitial load];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Baidu"]}]);
    }
}
@end
