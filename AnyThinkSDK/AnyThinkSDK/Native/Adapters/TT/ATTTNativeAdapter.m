//
//  ATTTNativeAdapter.m
//  AnyThinkTTNativeAdapter
//
//  Created by Martin Lau on 2018/12/29.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTNativeAdapter.h"
#import "ATTTNativeCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATTTNativeRenderer.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Native.h"
#import "ATNativeAdView.h"
NSString *const kTTNativeExpressDrawAdViewKey = @"ttNativeExpress_ad_view";

@interface ATTTNativeAdapter()
@property(nonatomic, readonly) id<ATBUNativeAdsManager> adMgr;
@property(nonatomic, readonly) ATTTNativeCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATBUNativeAd> nativeAd;
@property(nonatomic, readonly) id<ATBUNativeExpressAdManager> nativeExpressAdMgr;
@end

/*
BATroposalSize_Feed228_150,9
BATroposalSize_Feed690_388,10
BATroposalSize_DrawFullScreen//14
 */
@implementation ATTTNativeAdapter
+(Class) rendererClass {
    return [ATTTNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameTT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameTT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"BUAdSDKManager") SDKVersion] forNetwork:kNetworkNameTT];
            [NSClassFromString(@"BUAdSDKManager") setAppID:info[@"app_id"]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BUNativeAdsManager") != nil && NSClassFromString(@"BUAdSlot") != nil && NSClassFromString(@"BUNativeAd") != nil) {
        _customEvent = [ATTTNativeCustomEvent new];
        _customEvent.unitID = info[@"unit_id"];
        _customEvent.isVideo = [info[@"is_video"] integerValue] == 1;
        _customEvent.requestCompletionBlock = completion;
        
        NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
        _customEvent.requestExtra = extraInfo;
        NSString *sizeKey = [info[@"media_size"] integerValue] > 0 ? @{@2:kATExtraNativeImageSize228_150, @1:kATExtraNativeImageSize690_388}[info[@"media_size"]] : extraInfo[kATExtraNativeImageSizeKey];
        NSInteger imgSize = [@{kATExtraNativeImageSize228_150:@9, kATExtraNativeImageSize690_388:@10}[sizeKey] integerValue];
        
        id<ATBUAdSlot> slot = [[NSClassFromString(@"BUAdSlot") alloc] init];
        slot.ID = info[@"slot_id"];
        slot.AdType = [@{@0:@(ATTTNativeAdTypeFeed), @1:@(ATTTNativeAdTypeDraw), @2:@(ATTTNativeAdTypeBanner), @3:@(ATTTNativeAdTypeInterstitial)}[@([info[@"is_video"] integerValue])] integerValue];
        slot.isOriginAd = YES;
        slot.position = 1;
        slot.imgSize = [NSClassFromString(@"BUSize") sizeBy:imgSize];
        slot.isSupportDeepLink = YES;
        
        CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
        if ([extraInfo[kExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) { size = [extraInfo[kExtraInfoNativeAdSizeKey] CGSizeValue]; }
        if ([info[@"is_video"] integerValue] == 1 || [info[@"is_video"] integerValue] == 0) {
            if ([info[@"layout_type"]integerValue] == 0 && [info[@"is_video"]integerValue] == 0) {
                _nativeExpressAdMgr = [[NSClassFromString(@"BUNativeExpressAdManager") alloc] initWithSlot:slot adSize:size];
                _nativeExpressAdMgr.adSize = size;
                _nativeExpressAdMgr.delegate = _customEvent;
                [_nativeExpressAdMgr loadAd:[info[@"request_num"] integerValue]];
            } else {
                _adMgr = [NSClassFromString(@"BUNativeAdsManager") new];
                _adMgr.delegate = _customEvent;
                _adMgr.adslot = slot;
                [_adMgr loadAdDataWithCount:[info[@"request_num"] integerValue]];
            }
        } else if ([info[@"is_video"] integerValue] == 2 || [info[@"is_video"] integerValue] == 3) { //native banner
            _nativeAd = [NSClassFromString(@"BUNativeAd") new];
            _nativeAd.adslot = slot;
            _nativeAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            _nativeAd.delegate = _customEvent;
            [_nativeAd loadAdData];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native ad.", NSLocalizedFailureReasonErrorKey:@"This might be due to TT SDK not being imported or it's imported but a unsupported version is being used."}]);
    }
}
@end
