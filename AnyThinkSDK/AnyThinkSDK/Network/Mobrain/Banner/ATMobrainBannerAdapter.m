//
//  ATMobrainBannerAdapter.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainBannerAdapter.h"
#import "ATMobrainBaseManager.h"
#import "ATMobrainBannerCustomEvent.h"
#import "ATMobrainBannerApis.h"

@interface ATMobrainBannerAdapter ()

@property(nonatomic, strong) ATMobrainBannerCustomEvent *customEvent;
@property(nonatomic, strong) id<ATABUBannerAd> bannerAd;

@end
@implementation ATMobrainBannerAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMobrainBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    Class adClass = NSClassFromString(@"ABUBannerAd");
    if (adClass == nil) {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mobrain"]}]);
        return;
    }
    
    NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[serverInfo[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    CGSize size = CGSizeZero;
    //TODO get size from local
    NSString* sizeStr = slotInfo[@"common"][@"size"];
    if(localInfo[@"banner_ad_size"] != nil){
        size = [localInfo[@"banner_ad_size"] CGSizeValue];
    }else{
        NSArray<NSString*>* comp = [sizeStr componentsSeparatedByString:@"x"];
        if ([comp count] == 2 && [comp[0] respondsToSelector:@selector(doubleValue)] && [comp[1] respondsToSelector:@selector(doubleValue)]) { size = CGSizeMake([comp[0] doubleValue], [comp[1] doubleValue]); }
    }

    self.customEvent = [[ATMobrainBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    self.customEvent.requestCompletionBlock = completion;

    dispatch_async(dispatch_get_main_queue(), ^{
        self->_bannerAd = [[adClass alloc] initWithAdUnitID:serverInfo[@"slot_id"] rootViewController:[UIApplication sharedApplication].keyWindow.rootViewController adSize:size autoRefreshTime:0];
        self->_bannerAd.delegate = self.customEvent;
        if(self->_bannerAd.hasAdConfig){
            [self->_bannerAd loadAdData];
        }else{
            __weak typeof(self) weakself = self;
            [self->_bannerAd setConfigSuccessCallback:^{
                [weakself.bannerAd loadAdData];
            }];
        }
    });
}

@end
