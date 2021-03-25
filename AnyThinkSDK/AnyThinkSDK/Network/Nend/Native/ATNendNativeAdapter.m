//
//  ATNendNativeAdapter.m
//  AnyThinkNendNativeAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendNativeAdapter.h"
#import "ATNendNativeCustomEvent.h"
#import "ATNendNativeRenderer.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Native.h"
#import "ATNativeAdView.h"
#import "ATNendBaseManager.h"

const NSInteger kATNADVideoOrientationVertical = 1;
const NSInteger kATNADVideoOrientationHorizontal = 2;

@interface ATNendNativeAdapter()
@property(nonatomic, readonly) NSMutableArray<id<ATNADNativeClient>> *clients;
@property(nonatomic, readonly) NSMutableArray<id<ATNADNativeVideoLoader>> *loaders;
@property(nonatomic, readonly) ATNendNativeCustomEvent *customEvent;
@property(nonatomic, readonly) NSMutableArray *ads;
@end
@implementation ATNendNativeAdapter
+(Class) rendererClass {
    return [ATNendNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATNendBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"NADNative") != nil && NSClassFromString(@"NADNativeClient") != nil && NSClassFromString(@"NADNativeVideo") != nil && NSClassFromString(@"NADNativeVideoLoader") != nil) {
        _ads = [NSMutableArray array];
        _customEvent = [[ATNendNativeCustomEvent alloc] init];
        _customEvent.unitID = serverInfo[@"spot_id"];
        _customEvent.video = [serverInfo[@"is_video"] boolValue];
        _customEvent.requestCompletionBlock = completion;
        __weak typeof(self) weakSelf = self;
        if ([serverInfo[@"is_video"] boolValue]) {//Video
            _loaders = [NSMutableArray<id<ATNADNativeVideoLoader>> arrayWithCapacity:1];
            id<ATNADNativeVideoLoader> loader = [[NSClassFromString(@"NADNativeVideoLoader") alloc] initWithSpotId:serverInfo[@"spot_id"] apiKey:serverInfo[@"api_key"] clickAction:[serverInfo[@"click_action"] respondsToSelector:@selector(integerValue)] ? [serverInfo[@"click_action"] integerValue] : ATNADNativeVideoClickActionLP];
            NSDictionary *extra = localInfo;
            if ([extra isKindOfClass:[NSDictionary class]]) {
                if ([extra[kExtraInfoNativeAdUserIDKey] isKindOfClass:[NSString class]]) { loader.userId = extra[kExtraInfoNativeAdUserIDKey]; }
                if ([extra[kExtraInfoNativeAdMediationNameKey] isKindOfClass:[NSString class]]) { loader.mediationName = extra[kExtraInfoNativeAdMediationNameKey]; }
                if ([extra[kExtraInfoNativeAdLocationEnabledFlagKey] respondsToSelector:@selector(boolValue)]) { loader.isLocationEnabled = [extra[kExtraInfoNativeAdLocationEnabledFlagKey] boolValue]; }
                if ([extra[kExtraInfoNaitveAdUserFeatureKey] isKindOfClass:NSClassFromString(@"NADUserFeature")]) { loader.userFeature = extra[kExtraInfoNaitveAdUserFeatureKey]; }
            }
            if (loader != nil) {
                [_loaders addObject:loader];
                [loader loadAdWithCompletionHandler:^(id<ATNADNativeVideo> ad, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf handleAdRequestResultWithAd:ad error:error loadingInfo:serverInfo];
                    });
                }];
            }
        } else {//Non-video
            _clients = [NSMutableArray<id<ATNADNativeClient>> arrayWithCapacity:1];
            id<ATNADNativeClient> client = [[NSClassFromString(@"NADNativeClient") alloc] initWithSpotId:serverInfo[@"spot_id"] apiKey:serverInfo[@"api_key"]];
            if (client != nil) {
                [_clients addObject:client];
                [client loadWithCompletionBlock:^(id<ATNADNative> ad, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf handleAdRequestResultWithAd:ad error:error loadingInfo:serverInfo];
                    });
                }];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Nend"]}]);
    }
}

-(void) handleAdRequestResultWithAd:(id)ad error:(NSError*)error loadingInfo:(NSDictionary*)info {
    NSError *requestError = nil;
    if (error != nil) { requestError = error; }
    if (ad != nil) { [_ads addObject:ad]; }
    if ([_ads count] == 0) {
        requestError = requestError != nil ? requestError : [NSError errorWithDomain:@"com.anythink.NendNativeAdLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load native ad", NSLocalizedFailureReasonErrorKey:@"Nend has failed to load native ad"}];
        [_customEvent handleNativeAds:nil error:requestError];
    } else {
        [_customEvent handleNativeAds:_ads error:requestError];
    }
}
@end
