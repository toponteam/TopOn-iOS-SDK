//
//  ATKSNativeAdapter.m
//  AnyThinkKSNaitveAdapter
//
//  Created by Topon on 2020/2/5.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKSNativeAdapter.h"
#import "ATKSNativeCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATKSNativeRenderer.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Native.h"
#import "ATNativeAdView.h"
#import "ATKSBaseManager.h"

NSString *const kKSAdVideoSoundEnableFlag = @"ks_videoSoundEnable_flag";
NSString *const kKSNativeAdIsVideoFlag = @"ks_nativeAd_isVideo_flag";
@interface ATKSNativeAdapter ()
@property(nonatomic, readonly) id<ATKSFeedAd> nativeAd;
@property(nonatomic, readonly) id<ATKSNativeAd> adMgr;
@property(nonatomic, readonly) id<ATKSDrawAd> drawAd;
@property(nonatomic, readonly) id<ATKSFeedAdsManager> feedAdsManager;
@property(nonatomic, readonly) id<ATKSNativeAdsManager> nativeAdsManagger;
@property(nonatomic, readonly) id<ATKSDrawAdsManager> drawAdsManager;
@property(nonatomic, readonly) ATKSNativeCustomEvent *customEvent;

@end
@implementation ATKSNativeAdapter
+(Class) rendererClass {
    return [ATKSNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATKSBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    //暂时放这两个条件
    if (NSClassFromString(@"KSNativeAd") != nil && NSClassFromString(@"KSFeedAd") != nil) {
        _customEvent = [ATKSNativeCustomEvent new];
        _customEvent.unitID = serverInfo[@"position_id"];
        _customEvent.requestCompletionBlock = completion;
        NSDictionary *extraInfo = localInfo;
        _customEvent.requestExtra = extraInfo;
        _customEvent.videoSoundEnable = [serverInfo[@"video_sound"]boolValue];
        
        if ([serverInfo[@"layout_type"] integerValue] == 1) {
            CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
            if ([extraInfo[kExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) { size = [extraInfo[kExtraInfoNativeAdSizeKey] CGSizeValue]; }
            _feedAdsManager = [[NSClassFromString(@"KSFeedAdsManager") alloc]initWithPosId:serverInfo[@"position_id"] size:size];
            _feedAdsManager.delegate = _customEvent;
            [_feedAdsManager loadAdDataWithCount:[serverInfo[@"request_num"] integerValue]];
        } else if ([serverInfo[@"unit_type"] integerValue] == 1) {
            _drawAdsManager = [[NSClassFromString(@"KSDrawAdsManager") alloc]initWithPosId:serverInfo[@"position_id"]];
            _drawAdsManager.delegate = _customEvent;
            if ([serverInfo[@"request_num"]integerValue] > 5) {
                [_drawAdsManager loadAdDataWithCount:5];
            } else {
                [_drawAdsManager loadAdDataWithCount:[serverInfo[@"request_num"]integerValue]];
            }
        } else {
            _nativeAdsManagger = [[NSClassFromString(@"KSNativeAdsManager") alloc]initWithPosId:serverInfo[@"position_id"]];
            _nativeAdsManagger.delegate = _customEvent;
            [_nativeAdsManagger loadAdDataWithCount:[serverInfo[@"request_num"] integerValue]];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason,@"KS"]}]);
    }
}
@end
