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
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMintegral]) {
                        NSDictionary *consent = [ATAPI sharedInstance].networkConsentInfo[kNetworkNameMintegral];
                        if ([consent isKindOfClass:[NSDictionary class]]) {
                            [consent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                [[NSClassFromString(@"MTGSDK") sharedInstance] setUserPrivateInfoType:[key integerValue] agree:[obj boolValue]];
                            }];
                        }
                    } else {
                        BOOL set = NO;
                        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                        if (set) {
                            /*
                             consentStatus: 1 Personalized, 0 Nonpersonalized
                             */
                            id<ATMTGSDK> mtgSDK = [NSClassFromString(@"MTGSDK") sharedInstance];
                            mtgSDK.consentStatus = !limit;
                        }
                    }
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
                };
                if ([NSThread mainThread]) blk();
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
                _bidInterstitialAdManager = [[NSClassFromString(@"MTGBidInterstitialVideoAdManager") alloc] initWithUnitID:info[@"unitid"] delegate:_customEvent];
                [_bidInterstitialAdManager loadAdWithBidToken:[unitGroupModel bidTokenWithRequestID:requestID]];
                [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
            } else {
                _videoAdManager = [[NSClassFromString(@"MTGInterstitialVideoAdManager") alloc] initWithUnitID:info[@"unitid"] delegate:_customEvent];
                _videoAdManager.delegate = _customEvent;
                [_videoAdManager loadAd];
            }
        } else {
            _interstitialAdManager = [[NSClassFromString(@"MTGInterstitialAdManager") alloc] initWithUnitID:info[@"unitid"] adCategory:0];
            [_interstitialAdManager loadWithDelegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"Mintegral has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"AT SDK has failed to get %@'s shared instance; this might be due to Mintegral SDK not being imported or it's imported but a unsupported version is being used.", [info[@"is_video"] boolValue] ? @"MTGInterstitialVideoAdManager" : @"MTGInterstitialAdManager"]}]);
    }
}

@end
