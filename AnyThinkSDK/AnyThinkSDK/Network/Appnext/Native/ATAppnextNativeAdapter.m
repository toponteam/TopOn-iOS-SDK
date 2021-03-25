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
#import "ATAppnextBaseManager.h"

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
        [ATAppnextBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"AppnextNativeAdsSDKApi") != nil && NSClassFromString(@"AppnextNativeAdsRequest") != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *AppnextVc = [UIApplication sharedApplication].delegate.window.rootViewController;
            self->_api = [[NSClassFromString(@"AppnextNativeAdsSDKApi") alloc] initWithPlacementID:serverInfo[@"placement_id"] withViewController:AppnextVc];
            
            self->_customEvent = [[ATAppnextNativeCustomEvent alloc] init];
            self->_customEvent.unitID = serverInfo[@"placement_id"];
            self->_customEvent.requestCompletionBlock = completion;
            self->_customEvent.api = self->_api;
            
            NSDictionary *extraInfo = localInfo;
            self->_customEvent.requestExtra = extraInfo;
            
            id<ATAppnextNativeAdsRequest> request = [[NSClassFromString(@"AppnextNativeAdsRequest") alloc] init];
            request.count = [serverInfo[@"request_num"] integerValue];
            [self->_api loadAds:request withRequestDelegate:self->_customEvent];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Appnext"]}]);
    }
}
@end
