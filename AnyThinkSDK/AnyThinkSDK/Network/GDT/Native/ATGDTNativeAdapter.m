//
//  ATGDTNativeAdapter.m
//  AnyThinkGDTNativeAdapter
//
//  Created by Martin Lau on 26/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTNativeAdapter.h"
#import "ATGDTNativeCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATGDTNativeRenderer.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Native.h"
#import "ATGDTBaseManager.h"

NSString *const kGDTNativeAssetsExpressAdKey = @"express_ad";
NSString *const kGDTNativeAssetsExpressAdViewKey = @"express_ad_view";
NSString *const kGDTNativeAssetsCustomEventKey = @"custom_event";

NSString *const kGDTNativeAssetsNativeAdDataKey = @"native_ad_data";
NSString *const kGDTNativeAssetsTitleKey = @"title";
NSString *const kGDTNativeAssetsDescKey = @"desc";
NSString *const kGDTNativeAssetsIconUrl = @"icon";
NSString *const kGDTNativeAssetsImageUrl = @"img";
NSString *const kGDTNativeAssetsAppRating = @"rating";
NSString *const kGDTNativeAssetsAppPrice = @"price";
NSString *const kGDTNativeAssetsImgList = @"img_list";
@interface ATGDTNativeAdapter()
@property(nonatomic, readonly) id<ATGDTNativeExpressAd> expressAd;
@property(nonatomic, readonly) ATGDTNativeCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGDTUnifiedNativeAd> unifiedNativeAd;
@property(nonatomic, readonly) id<ATGDTVideoConfig> videoConfig;
@property(nonatomic, readonly) id<ATGDTNativeExpressProAdManager> adManager;
@end
@implementation ATGDTNativeAdapter
+(Class) rendererClass {
    return [ATGDTNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATGDTBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSDictionary *extraInfo = localInfo;
    NSInteger adType = [serverInfo[@"unit_type"] integerValue] > 0 ? [serverInfo[@"unit_type"] integerValue] : [extraInfo[kExtraInfoNativeAdTypeKey] integerValue];
    if (NSClassFromString(@"GDTNativeExpressAd") != nil && NSClassFromString(@"GDTUnifiedNativeAd") != nil) {
        _customEvent = [ATGDTNativeCustomEvent new];
        _customEvent.requestExtra = extraInfo;
        _customEvent.unitID = serverInfo[@"unit_id"];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (adType == 1) {//template
                CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
                if ([extraInfo[kExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) { size = [extraInfo[kExtraInfoNativeAdSizeKey] CGSizeValue]; }
                if ([serverInfo[@"unit_version"] integerValue] == 2) {
                    id<ATGDTAdParams> adParams = [[NSClassFromString(@"GDTAdParams") alloc] init];
                    adParams.adSize = size;
                    if (serverInfo[@"video_duration"] != nil) { adParams.maxVideoDuration = [serverInfo[@"video_duration"] integerValue]; }
                    adParams.detailPageVideoMuted = [serverInfo[@"video_muted"] boolValue];
                    adParams.videoMuted = [serverInfo[@"video_muted"] boolValue];
                    adParams.videoAutoPlayOnWWAN = [serverInfo[@"video_autoplay"] integerValue] == 1 ? YES : NO ;
                    self->_adManager = [[NSClassFromString(@"GDTNativeExpressProAdManager") alloc] initWithPlacementId:serverInfo[@"unit_id"] adPrams:adParams];
                    self->_adManager.delegate = self->_customEvent;
                    [self->_adManager loadAd:[serverInfo[@"request_num"] integerValue]];
                }else {
                    self->_expressAd = [[NSClassFromString(@"GDTNativeExpressAd") alloc] initWithAppId:serverInfo[@"app_id"] placementId:serverInfo[@"unit_id"] adSize:size];
                    self->_expressAd.videoMuted = [serverInfo[@"video_muted"] boolValue];
                    self->_expressAd.videoAutoPlayOnWWAN = [serverInfo[@"video_autoplay"] integerValue] == 1 ? YES : NO ;
                    if (serverInfo[@"video_duration"] != nil) { self->_expressAd.maxVideoDuration = [serverInfo[@"video_duration"] integerValue]; }
                    self->_expressAd.delegate = self->_customEvent;
                    [self->_expressAd loadAd:[serverInfo[@"request_num"] integerValue]];
                }
            } else if (adType == 2) {//self rendering
                if ([serverInfo[@"unit_version"] integerValue] == 2) {
                    self->_videoConfig = [[NSClassFromString(@"GDTVideoConfig") alloc] init];
                    self->_videoConfig.videoMuted = [serverInfo[@"video_muted"] boolValue];
                    self->_videoConfig.autoPlayPolicy = [@{@0:@(GDTVideoAutoPlayPolicyWIFI), @1:@(GDTVideoAutoPlayPolicyAlways), @2:@(GDTVideoAutoPlayPolicyNever)}[@([serverInfo[@"video_autoplay"] integerValue])] integerValue];
                    self->_customEvent.videoConfig = self->_videoConfig;
                    
                    self->_unifiedNativeAd = [[NSClassFromString(@"GDTUnifiedNativeAd") alloc] initWithPlacementId:serverInfo[@"unit_id"]];
                    if (serverInfo[@"video_duration"] != nil) { self->_unifiedNativeAd.maxVideoDuration = [serverInfo[@"video_duration"] integerValue]; }
                    self->_unifiedNativeAd.delegate = self->_customEvent;
                    [self->_unifiedNativeAd loadAdWithAdCount:[serverInfo[@"request_num"] intValue]];
                }
            } else {
                completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:@"Extra parameter does not contain object for key:kExtraInfoNativeAdTypeKey or the associated value is invalid; for GDT native ads, you have to specify the ad type(which is ATGDTNativeAdTypeTemplate(1) or ATGDTNativeAdTypeSelfRendering(2))."}]);
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GDT"]}]);
    }
}
@end
