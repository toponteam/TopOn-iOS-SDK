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
#import "ATPangleBaseManager.h"

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

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATPangleBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BUNativeAdsManager") != nil && NSClassFromString(@"BUAdSlot") != nil && NSClassFromString(@"BUNativeAd") != nil) {
        _customEvent = [ATTTNativeCustomEvent new];
        _customEvent.unitID = serverInfo[@"unit_id"];
        _customEvent.isVideo = [serverInfo[@"is_video"] integerValue] == 1;
        _customEvent.requestCompletionBlock = completion;
        
        NSDictionary *extraInfo = localInfo;
        _customEvent.requestExtra = extraInfo;
        NSString *sizeKey = [serverInfo[@"media_size"] integerValue] > 0 ? @{@2:kATExtraNativeImageSize228_150, @1:kATExtraNativeImageSize690_388}[serverInfo[@"media_size"]] : extraInfo[kATExtraNativeImageSizeKey];
        NSInteger imgSize = [@{kATExtraNativeImageSize228_150:@9, kATExtraNativeImageSize690_388:@10}[sizeKey] integerValue];
        
        id<ATBUAdSlot> slot = [[NSClassFromString(@"BUAdSlot") alloc] init];
        slot.ID = serverInfo[@"slot_id"];
        slot.AdType = [@{@0:@(ATTTNativeAdTypeFeed), @1:@(ATTTNativeAdTypeDraw), @2:@(ATTTNativeAdTypeBanner), @3:@(ATTTNativeAdTypeInterstitial)}[@([serverInfo[@"is_video"] integerValue])] integerValue];
        slot.isOriginAd = YES;
        slot.position = 1;
        slot.imgSize = [NSClassFromString(@"BUSize") sizeBy:imgSize];
        slot.isSupportDeepLink = YES;
        
        CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
        if ([extraInfo[kExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) { size = [extraInfo[kExtraInfoNativeAdSizeKey] CGSizeValue]; }
        if ([serverInfo[@"is_video"] integerValue] == 1 || [serverInfo[@"is_video"] integerValue] == 0) {
            if ([serverInfo[@"layout_type"]integerValue] == 0 && [serverInfo[@"is_video"]integerValue] == 0) {
                _nativeExpressAdMgr = [[NSClassFromString(@"BUNativeExpressAdManager") alloc] initWithSlot:slot adSize:size];
                _nativeExpressAdMgr.adSize = size;
                _nativeExpressAdMgr.delegate = _customEvent;
                [_nativeExpressAdMgr loadAd:[serverInfo[@"request_num"] integerValue]];
            } else if ([serverInfo[@"is_video"]integerValue] == 1 && [serverInfo[@"layout_type"] integerValue] == 0) {
                slot.imgSize = [NSClassFromString(@"BUSize") sizeBy:BUProposalSize_DrawFullScreen];
                _nativeExpressAdMgr = [[NSClassFromString(@"BUNativeExpressAdManager") alloc]initWithSlot:slot adSize:size];
                _nativeExpressAdMgr.adSize = size;
                _nativeExpressAdMgr.delegate = _customEvent;
                if ([serverInfo[@"request_num"] integerValue] > 3) {
                    [_nativeExpressAdMgr loadAd:3];
                }else {
                    [_nativeExpressAdMgr loadAd:[serverInfo[@"request_num"] integerValue]];
                }
            } else {
                _adMgr = [NSClassFromString(@"BUNativeAdsManager") new];
                _adMgr.delegate = _customEvent;
                _adMgr.adslot = slot;
                [_adMgr loadAdDataWithCount:[serverInfo[@"request_num"] integerValue]];
            }
        } else if ([serverInfo[@"is_video"] integerValue] == 2 || [serverInfo[@"is_video"] integerValue] == 3) { //native banner
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_nativeAd = [NSClassFromString(@"BUNativeAd") new];
                self->_nativeAd.adslot = slot;
                self->_nativeAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                self->_nativeAd.delegate = self->_customEvent;
                [self->_nativeAd loadAdData];
            });
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"TT"]}]);
    }
}
    
@end
