//
//  ATGoogleAdManagerNativeAdapter.m
//  AnyThinkGoogleAdManagerNativeAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerNativeAdapter.h"
#import "ATGoogleAdManagerNativeCustomEvent.h"
#import "ATGoogleAdManagerNativeAdRenderer.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
//NSString *const kATGADAdLoaderAdTypeUnifiedNative = @"6";
//
//NSString * const ATGADUnifiedNativeHeadlineAsset = @"3001";
//NSString * const ATGADUnifiedNativeCallToActionAsset = @"3002";
//NSString * const ATGADUnifiedNativeIconAsset = @"3003";
//NSString * const ATGADUnifiedNativeBodyAsset = @"3004";
//NSString * const ATGADUnifiedNativeAdvertiserAsset = @"3005";
//NSString * const ATGADUnifiedNativeStoreAsset = @"3006";
//NSString * const ATGADUnifiedNativePriceAsset = @"3007";
//NSString * const ATGADUnifiedNativeImageAsset = @"3008";
//NSString * const ATGADUnifiedNativeStarRatingAsset = @"3009";
//NSString * const ATGADUnifiedNativeMediaViewAsset = @"3010";
//NSString * const ATGADUnifiedNativeAdChoicesViewAsset = @"3013";
@interface ATGoogleAdManagerNativeAdapter()
@property(nonatomic, readonly) id<ATDFPAdLoader> loader;
@property(nonatomic, readonly) ATGoogleAdManagerNativeCustomEvent *customEvent;
@end
@implementation ATGoogleAdManagerNativeAdapter
+(Class) rendererClass {
    return [ATGoogleAdManagerNativeAdRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ATAPI sharedInstance] setVersion:[[NSClassFromString(@"GADMobileAds") sharedInstance] sdkVersion] forNetwork:kNetworkNameGoogleAdManager];
//                [NSClassFromString(@"GADMobileAds") configureWithApplicationID:serverInfo[@"app_id"]];
                if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameGoogleAdManager]) {
                    [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameGoogleAdManager];
//                    id<ATPACConsentInformation> consentInfo = [NSClassFromString(@"PACConsentInformation") sharedInstance];
//                    if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameGoogleAdManager]) {
//                        consentInfo.consentStatus = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameGoogleAdManager][kGoogleAdManagerConsentStatusKey] integerValue];
//                        consentInfo.tagForUnderAgeOfConsent = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameGoogleAdManager][kGoogleAdManagerUnderAgeKey] boolValue];
//                    } else {
//                        BOOL set = NO;
//                        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
//                        if (set) { consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized; }
//                    }
                }
            });
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"GADAdLoader") != nil) {
        _customEvent = [ATGoogleAdManagerNativeCustomEvent new];
        _customEvent.unitID = serverInfo[@"unit_id"];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.requestNumber = [serverInfo[@"request_num"] longValue];
        NSDictionary *extraInfo = localInfo;
        _customEvent.requestExtra = extraInfo;
        
        NSMutableArray<id<ATGADAdLoaderOptions>>* options = [NSMutableArray<id<ATGADAdLoaderOptions>> array];
        
        id<ATGADNativeAdMediaAdLoaderOptions> mediaOption = [NSClassFromString(@"GADNativeAdMediaAdLoaderOptions") new];
        mediaOption.mediaAspectRatio = [serverInfo[@"media_ratio"] integerValue];
        if (mediaOption != nil) { [options addObject:mediaOption]; }
        
        _loader = [[NSClassFromString(@"GADAdLoader") alloc] initWithAdUnitID:serverInfo[@"unit_id"] rootViewController:nil adTypes:@[ kATGADAdLoaderAdTypeUnifiedNative ] options:options];
        _loader.delegate = _customEvent;
        id<ATDFPRequest> request = [NSClassFromString(@"DFPRequest") request];
//        id<ATPACConsentInformation> consentInfo = [NSClassFromString(@"PACConsentInformation") sharedInstance];
//        if (consentInfo.consentStatus == ATPACConsentStatusNonPersonalized) {
//            id<ATGADExtras> extras = [[NSClassFromString(@"GADExtras") alloc] init];
//            extras.additionalParameters = @{@"npa":@"1"};
//            [request registerAdNetworkExtras:extras];
//        }
        [_loader loadRequest:request];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GoogleAdManager"]}]);
    }
}
@end
