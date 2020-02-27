//
//  ATMintegralNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 18/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralNativeAdapter.h"
#import "ATAPI+Internal.h"
#import "ATMintegralNativeADRenderer.h"
#import "NSObject+ExtraInfo.h"
#import "ATMintegralNativeCustomEvent.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAdLoader+HeaderBidding.h"
#import "ATAppSettingManager.h"
//@import AnyThinkNative;

NSString *const kATMintegralNativeAssetCustomEvent = @"assets_mintegral_custom_event_key";
@interface ATMintegralNativeAdapter()
@property(nonatomic, readonly) ATMintegralNativeCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATMTGBidNativeAdManager> bidAdManager;
@end
@implementation ATMintegralNativeAdapter
+(Class) rendererClass {
    return [ATMintegralNativeADRenderer class];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NSClassFromString(@"MTGNativeAdManager") != nil && NSClassFromString(@"MTGBidNativeAdManager") != nil) {
            _customEvent = [ATMintegralNativeCustomEvent new];
            _customEvent.requestCompletionBlock = completion;
            _customEvent.unitID = info[@"unitid"];
            NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
            _customEvent.requestExtra = extraInfo;
            
            ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
            NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
            if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
                _bidAdManager = [[NSClassFromString(@"MTGBidNativeAdManager") alloc] initWithUnitID:info[@"unitid"] presentingViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
                _customEvent.bidNativeAdManager = _bidAdManager;
                _bidAdManager.delegate = _customEvent;
                [_bidAdManager loadWithBidToken:[unitGroupModel bidTokenWithRequestID:requestID]];
                [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
            } else {
                id<ATMTGTemplate> template = [NSClassFromString(@"MTGTemplate") templateWithType:AT_MTGAD_TEMPLATE_BIG_IMAGE adsNum:[info[@"request_num"] integerValue]];
                id<ATMTGNativeAdManager> adManager = [[NSClassFromString(@"MTGNativeAdManager") alloc] initWithUnitID:info[@"unitid"] fbPlacementId:nil supportedTemplates:@[template] autoCacheImage:YES adCategory:0 presentingViewController:nil];
                adManager.delegate = _customEvent;
                _customEvent.nativeAdManager = adManager;
                [adManager loadAds];
            }
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"Mintegral has failed to load native.", NSLocalizedFailureReasonErrorKey:@"AT SDK has failed to get MTGNativeAdManager's shared instance; this might be due to Mintegral SDK not being imported or it's imported but a unsupported version is being used."}]);
        }
    });
}
@end
