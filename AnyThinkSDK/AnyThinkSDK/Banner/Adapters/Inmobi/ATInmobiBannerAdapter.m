//
//  ATInmobiBannerAdapter.m
//  AnyThinkInmobiBannerAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiBannerAdapter.h"
#import "ATInmobiBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
@interface ATInmobiBannerAdapter()
@property(nonatomic, readonly) id<ATIMBanner> banner;
@property(nonatomic, readonly) ATInmobiBannerCustomEvent *customEvent;
@end

static NSString *const kUnitIDKey = @"unit_id";
@implementation ATInmobiBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"IMSdk") getVersion] forNetwork:kNetworkNameInmobi];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameInmobi]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameInmobi];
                [NSClassFromString(@"IMSdk") initWithAccountID:info[@"app_id"]];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameInmobi]) {
                    [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":[ATAPI sharedInstance].networkConsentInfo[kNetworkNameInmobi][kInmobiConsentStringKey], @"gdpr":[ATAPI sharedInstance].networkConsentInfo[kNetworkNameInmobi][kInmobiGDPRStringKey]}];
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) {
                        [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":limit ? @"false" : @"true", @"gdpr":[[ATAPI sharedInstance] inDataProtectionArea] ? @"1" : @"0"}];
                }
            }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"IMBanner") != nil) {
        _customEvent = [[ATInmobiBannerCustomEvent alloc] initWithUnitID:info[kUnitIDKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_banner = [[NSClassFromString(@"IMBanner") alloc] initWithFrame:CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height) placementId:[info[kUnitIDKey] longLongValue] delegate:self->_customEvent];
            [self->_banner load];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Inmobi"]}]);
    }
}
@end
