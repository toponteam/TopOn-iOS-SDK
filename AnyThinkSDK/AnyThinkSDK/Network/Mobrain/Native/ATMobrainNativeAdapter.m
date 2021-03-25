//
//  ATMobrainNativeAdapter.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainNativeAdapter.h"
#import "ATMobrainNativeCustomEvent.h"
#import "ATMobrainNativeRenderer.h"
#import "ATMobrainBaseManager.h"
#import "ATMobrainNativeApis.h"
#import "Utilities.h"

@interface ATMobrainNativeAdapter ()
@property (nonatomic, strong) id<ATABUNativeAdsManager> adManager;
@property(nonatomic, readonly) ATMobrainNativeCustomEvent *customEvent;

@end

@implementation ATMobrainNativeAdapter

+(Class) rendererClass {
    return [ATMobrainNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMobrainBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"ABUNativeAdsManager") != nil && NSClassFromString(@"ABUAdUnit") != nil && NSClassFromString(@"ABUSize") != nil) {
        _customEvent = [[ATMobrainNativeCustomEvent alloc] initWithUnitID:serverInfo[@"unit_id"] serverInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        
        NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[serverInfo[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        CGSize adSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 400.0f);
        if ([localInfo[kExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
            adSize = [localInfo[kExtraInfoNativeAdSizeKey] CGSizeValue];
        }
        
        CGSize imgSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 400.0f);
        if ([localInfo[kATExtraNativeImageSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
            imgSize = [localInfo[kATExtraNativeImageSizeKey] CGSizeValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // ABUAdUnit相当于穿山甲的BUAdSlot类。聚合sdk为了和平台统一口径，统一对外主rit描述有slotID-->unitID  add in 2200 by wangchao
            id<ATABUAdUnit> slot = [[NSClassFromString(@"ABUAdUnit") alloc] init];
            id<ATABUSize> imgBUSize = [[NSClassFromString(@"ABUSize") alloc] init];
            imgBUSize.width = imgSize.width;
            imgBUSize.height = imgSize.height;
            slot.AdType = ABUAdSlotAdTypeFeed;
            slot.position = ABUAdSlotPositionFeed;
            slot.imgSize = imgBUSize;
            slot.ID = serverInfo[@"slot_id"];
            slot.adSize = adSize;
            slot.getExpressAdIfCan = [slotInfo[@"common"][@"ad_style_type"] boolValue];
            slot.isSupportDeepLink = [slotInfo[@"common"][@"support_deeplink"] boolValue];
            self.adManager = [[NSClassFromString(@"ABUNativeAdsManager") alloc] initWithSlot:slot];
            self.adManager.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            self.adManager.startMutedIfCan = [slotInfo[@"common"][@"video_muted"] boolValue];
            self.adManager.delegate = self->_customEvent;

            __weak typeof(self) weakself = self;
            //该逻辑用于判断配置是否拉取成功。如果拉取成功，可直接加载广告，否则需要调用setConfigSuccessCallback，传入block并在block中调用加载广告。SDK内部会在配置拉取成功后调用传入的block
            //当前配置拉取成功，直接loadAdData
            if (self.adManager.hasAdConfig) {
                [self.adManager loadAdDataWithCount:[Utilities isEmpty:serverInfo[@"request_num"]] == NO ? [serverInfo[@"request_num"] integerValue] : 1];
            } else {
                //当前配置未拉取成功，在成功之后会调用该callback
                [self.adManager setConfigSuccessCallback:^{
                    [weakself.adManager loadAdDataWithCount:[Utilities isEmpty:serverInfo[@"request_num"]] == NO ? [serverInfo[@"request_num"] integerValue] : 1];
                }];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mobrain"]}]);
    }
}
    

@end
