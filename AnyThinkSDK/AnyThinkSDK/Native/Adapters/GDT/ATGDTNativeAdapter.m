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
@property(nonatomic, readonly) id<ATGDTNativeAd> nativeAd;
@property(nonatomic, readonly) id<ATGDTUnifiedNativeAd> unifiedNativeAd;
@end
@implementation ATGDTNativeAdapter
+(Class) rendererClass {
    return [ATGDTNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameGDT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameGDT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"GDTSDKConfig") sdkVersion] forNetwork:kNetworkNameGDT];
            [NSClassFromString(@"GDTSDKConfig") registerAppId:info[@"app_id"]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
    NSInteger adType = [info[@"unit_type"] integerValue] > 0 ? [info[@"unit_type"] integerValue] : [extraInfo[kExtraInfoNativeAdTypeKey] integerValue];
    if (NSClassFromString(@"GDTNativeExpressAd") != nil && NSClassFromString(@"GDTNativeAd") != nil && NSClassFromString(@"GDTUnifiedNativeAd") != nil) {
        _customEvent = [ATGDTNativeCustomEvent new];
        _customEvent.requestExtra = extraInfo;
        _customEvent.unitID = info[@"unit_id"];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (adType == 1) {//template
                CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
                if ([extraInfo[kExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) { size = [extraInfo[kExtraInfoNativeAdSizeKey] CGSizeValue]; }
                self->_expressAd = [[NSClassFromString(@"GDTNativeExpressAd") alloc] initWithAppId:info[@"app_id"] placementId:info[@"unit_id"] adSize:size];
                self->_expressAd.delegate = self->_customEvent;
                [self->_expressAd loadAd:[info[@"request_num"] integerValue]];
            } else if (adType == 2) {//self rendering
                if ([info[@"unit_version"] integerValue] == 2) {
                    self->_unifiedNativeAd = [[NSClassFromString(@"GDTUnifiedNativeAd") alloc] initWithPlacementId:info[@"unit_id"]];
                    self->_unifiedNativeAd.delegate = self->_customEvent;
                    [self->_unifiedNativeAd loadAdWithAdCount:[info[@"request_num"] intValue]];
                } else {
                    self->_nativeAd = [[NSClassFromString(@"GDTNativeAd") alloc] initWithAppId:info[@"app_id"] placementId:info[@"unit_id"]];
                    self->_nativeAd.controller = UIApplication.sharedApplication.keyWindow.rootViewController;
                    self->_nativeAd.delegate = self->_customEvent;
                    self->_customEvent.gdtNativeAd = self->_nativeAd;
                    [self->_nativeAd loadAd:[info[@"request_num"] intValue]];
                }
            } else {
                completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native ad.", NSLocalizedFailureReasonErrorKey:@"Extra parameter does not contain object for key:kExtraInfoNativeAdTypeKey or the associated value is invalid; for GDT native ads, you have to specify the ad type(which is ATGDTNativeAdTypeTemplate(1) or ATGDTNativeAdTypeSelfRendering(2))."}]);
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native ad.", NSLocalizedFailureReasonErrorKey:@"This might be due to GDT SDK not being imported or it's imported but a unsupported version is being used."}]);
    }
}
@end
