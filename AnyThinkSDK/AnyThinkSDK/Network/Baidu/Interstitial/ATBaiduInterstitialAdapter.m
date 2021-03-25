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
#import "ATBaiduBaseManager.h"

@interface ATBaiduInterstitialAdapter()
@property(nonatomic, readonly) ATBaiduInterstitialCustomEvent *customEvent;
@property(nonatomic) id<ATBaiduMobAdInterstitial> interstitial;
@property (nonatomic) id<ATBaiduMobAdExpressFullScreenVideo> fullVideo;
@end
@implementation ATBaiduInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATBaiduMobAdInterstitial>)customObject info:(NSDictionary*)info {
    return customObject.isReady;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([interstitial.unitGroup.content[@"unit_type"] integerValue] == 1) {
            [interstitial.customObject showFromViewController:viewController];
        } else {
            [interstitial.customObject presentFromRootViewController:viewController];
        }
    });
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATBaiduBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BaiduMobAdInterstitial") != nil && NSClassFromString(@"BaiduMobAdExpressFullScreenVideo") != nil) {
        _customEvent = [[ATBaiduInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([serverInfo[@"unit_type"] integerValue] == 1) {
                weakSelf.fullVideo = [[NSClassFromString(@"BaiduMobAdExpressFullScreenVideo") alloc] init];
                weakSelf.fullVideo.delegate = weakSelf.customEvent;
                weakSelf.fullVideo.AdUnitTag = serverInfo[@"ad_place_id"];
                weakSelf.fullVideo.publisherId = serverInfo[@"app_id"];
                weakSelf.fullVideo.adType = BaiduMobAdTypeFullScreenVideo;
                [weakSelf.fullVideo load];
            } else {
                weakSelf.interstitial = [[NSClassFromString(@"BaiduMobAdInterstitial") alloc] init];
                weakSelf.interstitial.delegate = weakSelf.customEvent;
                weakSelf.interstitial.AdUnitTag = serverInfo[@"ad_place_id"];
                weakSelf.interstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;
                [weakSelf.interstitial load];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Baidu"]}]);
    }
}
@end
