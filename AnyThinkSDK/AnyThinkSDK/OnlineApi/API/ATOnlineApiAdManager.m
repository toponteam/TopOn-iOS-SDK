//
//  ATOnlineApiAdManager.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiAdManager.h"
#import "ATRequestConfiguration.h"
#import "ATOnlineApiLoader.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATOfferResourceManager.h"
#import "ATOnlineApiOfferModel.h"
#import "ATOnlineApiLoadingDelegate.h"
#import "ATOfferResourceLoader.h"
#import "ATBidInfoManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATOnlineApiTracker.h"

@interface ATOnlineApiAdManager()

@end
@implementation ATOnlineApiAdManager

-(instancetype) init {
    self = [super init];
    if(self != nil){
        self.delegateStorage = [NSMutableDictionary<NSString*, id> dictionary];
        self.delegateStorageAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

// MARK:- functions claimed in .h
- (void)requestOnlineApiAdsWithConfiguration:(ATRequestConfiguration *)config {
    
//    ATOnlineApiOfferModel *model = [self modelWithPlacementID:config.placementID unitGroupID:config.unitGroupID];
//    if (model) {
//        [self handleRequestCompletion:model configuration:config error:nil];
//        return;
//    }
    
    __weak typeof(config) weakConfig = config;
    config.callback = ^(ATOnlineApiOfferModel *  _Nonnull
                        _model, NSError * _Nonnull error) {
        [self handleRequestCompletion:_model configuration:weakConfig error:error];
    };
    
    [[ATOnlineApiLoader sharedLoader] requestOnlineApiAdsWithConfiguration:config];
}

- (ATOnlineApiOfferModel *)readyOnlineApiAdWithUnitGroupModelID:(NSString *)unitGroupModelID placementSetting:(ATOnlineApiPlacementSetting *)placementSetting {
    
    ATOnlineApiOfferModel *model = [self modelWithPlacementID:placementSetting.placementID unitGroupID:unitGroupModelID];
    if (model) {
        
        ATOfferResourceManager *manager = [ATOfferResourceManager sharedManager];
        id resource = [manager retrieveResourceModelWithResourceID:model.localResourceID];
        NSString *videoPath = [manager resourcePathForOfferModel:model resourceURL:model.videoURL];
        
        id value = placementSetting.format == ATAdFormatInterstitial ? [manager resourcePathForOfferModel:model resourceURL:model.fullScreenImageURL] : 0;
        return (resource && (videoPath || value)) ? model : nil;
    }
    return nil;
}

- (NSString *)priceForReadyUnitGroupModelID:(NSString *)uid placementID:(NSString *)pid {
    
    return @"0";
    //to do
//    NSString *price = [self modelWithPlacementID:pid unitGroupID:uid].price;
//    return price ? price : @"0";
}

// MARK:- private methods
- (ATOnlineApiOfferModel *)modelWithPlacementID:(NSString *)pid unitGroupID:(NSString *)uid {
    ATOnlineApiLoader *loader = [ATOnlineApiLoader sharedLoader];
    ATOnlineApiOfferModel *model = [loader readyOnlineApiAdWithUnitGroupModelID:uid placementID:pid];
    return model;
}

- (void)handleRequestCompletion_impl: (ATOnlineApiOfferModel *)model configuration:(ATRequestConfiguration *)config error:(NSError *)error {
    
    if (error) {
        if ([config.delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:unitID:error:)]) {
            [config.delegate didFailToLoadADWithPlacementID:config.setting.placementID unitID:config.unitID error:error];
        }
        return;
    }
    
    if ([config.delegate respondsToSelector:@selector(didLoadMetaDataSuccessWithPlacementID:unitID:)]) {
        [config.delegate didLoadMetaDataSuccessWithPlacementID:config.setting.placementID unitID:config.unitID];
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventVideoLoaded offerModel:model extra:config.extraInfo];
        
    }
    
    [[ATOfferResourceLoader sharedLoader] loadOfferWithOfferModel:model placementID:config.setting.placementID resourceDownloadTimeout:998 extra:nil completion:^(NSError *_error) {
        
        if (_error == nil) {
            
            if ([config.delegate respondsToSelector:@selector(didLoadADSuccessWithPlacementID:unitID:)]) {
                [config.delegate didLoadADSuccessWithPlacementID:config.setting.placementID unitID:config.unitID];
            }
            return;
        }
        
        [[ATOnlineApiLoader sharedLoader] removeOfferModel:model];
        if ([config.delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:unitID:error:)]) {
            [config.delegate didFailToLoadADWithPlacementID:config.setting.placementID unitID:config.unitID error:error];
        }
    }];
}

- (void)handleRequestCompletion:(ATOnlineApiOfferModel *)model configuration:(ATRequestConfiguration *)config error:(NSError *)error {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self handleRequestCompletion_impl:model configuration:config error:error];
    });
}

@end
