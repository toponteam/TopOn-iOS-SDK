//
//  ATAdmobNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 26/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobNativeAdapter.h"
#import "ATAdMobCustomEvent.h"
#import "ATAdMobNativeADRenderer.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATAdmobBaseManager.h"

@interface ATAdmobNativeAdapter()
@property(nonatomic, readonly) id<ATGADAdLoader> loader;
@property(nonatomic, readonly) ATAdMobCustomEvent *customEvent;
@end
@implementation ATAdmobNativeAdapter
+(Class) rendererClass {
    return [ATAdMobNativeADRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAdmobBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"GADAdLoader") != nil) {
        _customEvent = [ATAdMobCustomEvent new];
        _customEvent.unitID = serverInfo[@"unit_id"];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.requestNumber = [serverInfo[@"request_num"] longValue];
        NSDictionary *extraInfo = localInfo;
        _customEvent.requestExtra = extraInfo;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray<id<ATGADAdLoaderOptions>>* options = [NSMutableArray<id<ATGADAdLoaderOptions>> array];
            id<ATGADMultipleAdsAdLoaderOptions> option = [NSClassFromString(@"GADMultipleAdsAdLoaderOptions") new];
            option.numberOfAds = [serverInfo[@"request_num"] longValue];
            if (option != nil) { [options addObject:option]; }
            
            id<ATGADNativeAdMediaAdLoaderOptions> mediaOption = [NSClassFromString(@"GADNativeAdMediaAdLoaderOptions") new];
            mediaOption.mediaAspectRatio = [serverInfo[@"media_ratio"] integerValue];
            if (mediaOption != nil) { [options addObject:mediaOption]; }
            
            self->_loader = [[NSClassFromString(@"GADAdLoader") alloc] initWithAdUnitID:serverInfo[@"unit_id"] rootViewController:nil adTypes:@[ kATGADAdLoaderAdTypeUnifiedNative ] options:options];
            self->_loader.delegate = self->_customEvent;
            id<ATGADRequest> request = [NSClassFromString(@"GADRequest") request];
            id<ATPACConsentInformation> consentInfo = [NSClassFromString(@"PACConsentInformation") sharedInstance];
            if (consentInfo.consentStatus == ATPACConsentStatusNonPersonalized) {
                id<ATGADExtras> extras = [[NSClassFromString(@"GADExtras") alloc] init];
                extras.additionalParameters = @{@"npa":@"1"};
                [request registerAdNetworkExtras:extras];
            }
            [self->_loader loadRequest:request];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}
@end
