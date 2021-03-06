//
//  ATStartAppBannerAdapter.m
//  AnyThinkStartAppBannerAdapter
//
//  Created by Martin Lau on 2020/5/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppBannerAdapter.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
#import "ATAdAdapter.h"
#import "ATStartAppBannerCustomEvent.h"

@interface ATStartAppBannerAdapter()
@property(nonatomic, readonly) id<ATSTABannerView> bannerView;
@property(nonatomic, readonly) ATStartAppBannerCustomEvent *customEvent;
@end
@implementation ATStartAppBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameStartApp]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameStartApp];
            dispatch_async(dispatch_get_main_queue(), ^{
                id<ATSTAStartAppSDK> sdk = [NSClassFromString(@"STAStartAppSDK") sharedInstance];
                sdk.testAdsEnabled = YES;
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [sdk setUserConsent:!limit forConsentType:@"pas" withTimestamp:[[NSDate date] timeIntervalSince1970]]; }
                sdk.appID = serverInfo[@"app_id"];
            });
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"STABannerView") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_customEvent = [[ATStartAppBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            self->_customEvent.requestCompletionBlock = completion;
            ATSTABannerSize size = {unitGroupModel.adSize, NO};
            self->_bannerView = [[NSClassFromString(@"STABannerView") alloc] initWithSize:size origin:CGPointZero withDelegate:self->_customEvent];
            [self->_bannerView setSTABannerAdTag:serverInfo[@"ad_tag"]];
            [self->_bannerView loadAd];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"StartApp"]}]);
    }
}
@end
