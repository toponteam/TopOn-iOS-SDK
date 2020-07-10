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

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameKS]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameKS];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"KSAdSDKManager") SDKVersion] forNetwork:kNetworkNameKS];
            [NSClassFromString(@"KSAdSDKManager") setAppId:info[@"app_id"]];

        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    //暂时放这两个条件
    if (NSClassFromString(@"KSNativeAd") != nil && NSClassFromString(@"KSFeedAd") != nil) {
        _customEvent = [ATKSNativeCustomEvent new];
        _customEvent.unitID = info[@"position_id"];
        _customEvent.requestCompletionBlock = completion;
        NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
        _customEvent.requestExtra = extraInfo;
        _customEvent.videoSoundEnable = [info[@"video_sound"]boolValue];
        
        if ([info[@"layout_type"] integerValue] == 1) {
            CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
            if ([extraInfo[kExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) { size = [extraInfo[kExtraInfoNativeAdSizeKey] CGSizeValue]; }
            _feedAdsManager = [[NSClassFromString(@"KSFeedAdsManager") alloc]initWithPosId:info[@"position_id"] size:size];
            _feedAdsManager.delegate = _customEvent;
            [_feedAdsManager loadAdDataWithCount:[info[@"request_num"] integerValue]];
        } else if ([info[@"unit_type"] integerValue] == 1) {
            _drawAdsManager = [[NSClassFromString(@"KSDrawAdsManager") alloc]initWithPosId:info[@"position_id"]];
            _drawAdsManager.delegate = _customEvent;
            if ([info[@"request_num"]integerValue] > 5) {
                [_drawAdsManager loadAdDataWithCount:5];
            } else {
                [_drawAdsManager loadAdDataWithCount:[info[@"request_num"]integerValue]];
            }
        } else {
            _nativeAdsManagger = [[NSClassFromString(@"KSNativeAdsManager") alloc]initWithPosId:info[@"position_id"]];
            _nativeAdsManagger.delegate = _customEvent;
            _customEvent.isVideo = [info[@"is_video"] boolValue];
            [_nativeAdsManagger loadAdDataWithCount:[info[@"request_num"] integerValue]];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native ad.", NSLocalizedFailureReasonErrorKey:@"This might be due to KS SDK not being imported or it's imported but a unsupported version is being used."}]);
    }
}
@end
