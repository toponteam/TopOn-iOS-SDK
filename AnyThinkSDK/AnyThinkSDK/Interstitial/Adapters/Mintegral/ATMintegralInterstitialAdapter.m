//
//  ATMintegralInterstitialAdapter.m
//  AnyThinkMintegralInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralInterstitialAdapter.h"
#import "ATMintegralInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAdLoader+HeaderBidding.h"
#import "ATAppSettingManager.h"
#import "ATCapsManager.h"
#import <objc/runtime.h>

@interface ATMintegralInterstitialAdapter()
@property(nonatomic, readonly) id<ATMTGInterstitialVideoAdManager> videoAdManager;
@property(nonatomic, readonly) id<ATMTGInterstitialAdManager> interstitialAdManager;
@property(nonatomic, readonly) id<ATMTGBidInterstitialVideoAdManager> bidInterstitialAdManager;
@property(nonatomic, readonly) ATMintegralInterstitialCustomEvent *customEvent;
@end
@implementation ATMintegralInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    if ([customObject respondsToSelector:@selector(isVideoReadyToPlay:)]) {
        return [customObject isVideoReadyToPlay:info[@"unitid"]];
    } else {
        return customObject != nil;
    }
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    id mtgInterstitial = interstitial.customObject;
    
    if ([mtgInterstitial respondsToSelector:@selector(showWithDelegate:presentingViewController:)]) {
        [mtgInterstitial showWithDelegate:(ATMintegralInterstitialCustomEvent*)interstitial.customEvent presentingViewController:viewController];
    } else if ([mtgInterstitial respondsToSelector:@selector(showFromViewController:)]) {
        [mtgInterstitial showFromViewController:viewController];
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
                };
                if ([NSThread currentThread].isMainThread) blk();
                else dispatch_sync(dispatch_get_main_queue(), blk);
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"MTGInterstitialVideoAdManager") != nil && NSClassFromString(@"MTGInterstitialAdManager") != nil) {
        _customEvent = [[ATMintegralInterstitialCustomEvent alloc] initWithUnitID:info[@"unitid"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if ([info[@"is_video"] boolValue]) {
            _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
            ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
            NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
             if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
                 if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                     [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:info[@"unitid"]];
                 }
                _bidInterstitialAdManager = [[NSClassFromString(@"MTGBidInterstitialVideoAdManager") alloc] initWithPlacementId:info[@"placement_id"] unitId:info[@"unitid"] delegate:_customEvent];
                [_bidInterstitialAdManager loadAdWithBidToken:[unitGroupModel bidTokenWithRequestID:requestID]];
                [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
            } else {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                    [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:info[@"unitid"]];
                }
                _videoAdManager = [[NSClassFromString(@"MTGInterstitialVideoAdManager") alloc] initWithPlacementId:info[@"placement_id"] unitId:info[@"unitid"] delegate:_customEvent];
                [_videoAdManager loadAd];
            }
        } else {
            if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:info[@"unitid"]];
            }
            _interstitialAdManager = [[NSClassFromString(@"MTGInterstitialAdManager") alloc] initWithPlacementId:info[@"placement_id"] unitId:info[@"unitid"] adCategory:0];
            [_interstitialAdManager loadWithDelegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"Mintegral has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"AT SDK has failed to get %@'s shared instance; this might be due to Mintegral SDK not being imported or it's imported but a unsupported version is being used.", [info[@"is_video"] boolValue] ? @"MTGInterstitialVideoAdManager" : @"MTGInterstitialAdManager"]}]);
    }
}

@end
