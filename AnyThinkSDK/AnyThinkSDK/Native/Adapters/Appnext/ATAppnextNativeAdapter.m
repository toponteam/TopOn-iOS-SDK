//
//  ATAppnextNativeAdapter.m
//  AnyThinkAppnextNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextNativeAdapter.h"
#import "ATAppnextNativeCustomEvent.h"
#import "ATAppnextNativeRenderer.h"
#import "ATAPI+Internal.h"
#import "ATAdCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATAdAdapter.h"

NSString *const kAppnextNativeAssetsAPIObjectKey = @"api_object";
@interface ATAppnextNativeAdapter()
@property(nonatomic, readonly) id<ATAppnextNativeAdsSDKApi> api;
@property(nonatomic, readonly) ATAppnextNativeCustomEvent *customEvent;
@end

@implementation ATAppnextNativeAdapter
+(Class) rendererClass {
    return [ATAppnextNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameAppnext]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameAppnext];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"AppnextNativeAdsSDKApi") getNativeAdsSDKVersion] forNetwork:kNetworkNameAppnext];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"AppnextNativeAdsSDKApi") != nil && NSClassFromString(@"AppnextNativeAdsRequest") != nil) {
        UIViewController *AppnextVc = [UIApplication sharedApplication].delegate.window.rootViewController;
        _api = [[NSClassFromString(@"AppnextNativeAdsSDKApi") alloc] initWithPlacementID:serverInfo[@"placement_id"] withViewController:AppnextVc];
//        [_api setViewController:AppnextVc];
        
        _customEvent = [[ATAppnextNativeCustomEvent alloc] init];
        _customEvent.unitID = serverInfo[@"placement_id"];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.api = _api;
        
        NSDictionary *extraInfo = localInfo;
        _customEvent.requestExtra = extraInfo;
        
        id<ATAppnextNativeAdsRequest> request = [[NSClassFromString(@"AppnextNativeAdsRequest") alloc] init];
        request.count = [serverInfo[@"request_num"] integerValue];
        [_api loadAds:request withRequestDelegate:_customEvent];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Appnext"]}]);
    }
}
@end
