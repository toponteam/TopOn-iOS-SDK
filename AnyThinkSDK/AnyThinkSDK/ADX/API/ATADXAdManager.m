//
//  ATADXAdManager.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATADXAdManager.h"
#import "ATADXLoader.h"
#import "ATOfferResourceLoader.h"
#import "ATOfferResourceManager.h"
#import "ATBidInfoManager.h"

@implementation ATADXAdManager

-(instancetype) init {
    self = [super init];
    if(self != nil){
        self.delegateStorage = [NSMutableDictionary<NSString*, id> dictionary];
        self.delegateStorageAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

-(void) loadADWithUnitGroup:(ATUnitGroupModel*)unitGroupModel bidInfo:(ATBidInfo*) bidInfo setting:(ATADXPlacementSetting*)setting placementModel:(ATPlacementModel *)placementModel content:(NSDictionary *)content requestID:(NSString *)requestID delegate:(id<ATADXAdLoadingDelegate>)delegate {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        void (^loadOfferCompletion)(ATADXOfferModel *offerModel, NSError *error) = ^(ATADXOfferModel *offerModel, NSError *error) {
               //load res
               if ([delegate respondsToSelector:@selector(didLoadMetaDataSuccessWithPlacementID:)]) { [delegate didLoadMetaDataSuccessWithPlacementID:setting.placementID unitID:unitGroupModel.unitID]; }
               if(error != nil) {
                   if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { [delegate didFailToLoadADWithPlacementID:setting.placementID unitID:unitGroupModel.unitID error:error]; }
               }else{
                   __block ATADXPlacementSetting* adxSetting = offerModel.adxSetting != nil?offerModel.adxSetting:setting;
                   [[ATOfferResourceLoader sharedLoader] loadOfferWithOfferModel:offerModel placementID:adxSetting.placementID resourceDownloadTimeout:adxSetting.resourceDownloadTimeout extra:nil completion:^(NSError *error) {
                       if (error == nil) {
                           if ([delegate respondsToSelector:@selector(didLoadADSuccessWithPlacementID:unitID:)]) { [delegate didLoadADSuccessWithPlacementID:adxSetting.placementID unitID:unitGroupModel.unitID]; }
                       }else{
                           [[ATADXLoader sharedLoader] removeOfferModel:offerModel];
                           ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:setting.placementID unitGroupModel:unitGroupModel requestID:requestID];
                           [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:setting.placementID unitGroupModel:unitGroupModel requestID:requestID];
                           if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:unitID:error:)]) { [delegate didFailToLoadADWithPlacementID:adxSetting.placementID unitID:unitGroupModel.unitID error:error]; }
                       }
                   }];
               }
               
           };
           
           if([[ATADXLoader sharedLoader] readyADXAdWithUnitGroupModel:unitGroupModel placementID:setting.placementID]){
               ATADXOfferModel *offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:setting.placementID unitGroupModel:unitGroupModel];
               loadOfferCompletion(offerModel, nil);
           }else{
               [[ATADXLoader sharedLoader] requestADXAdsWithUnitGroupModel:unitGroupModel bidInfo:bidInfo requestID:requestID placementModel:placementModel content:content completion:loadOfferCompletion];
           }
    });
}

-(BOOL) readyForUnitGroupModel:(ATUnitGroupModel*)unitGroupModel setting:(ATADXPlacementSetting*)setting {
    if([[ATADXLoader sharedLoader] readyADXAdWithUnitGroupModel:unitGroupModel placementID:setting.placementID]){
        ATADXOfferModel *offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:setting.placementID unitGroupModel:unitGroupModel];
        
        if(setting.format == ATAdFormatInterstitial){
            return [[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID] != nil && ([[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.videoURL] != nil || [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.fullScreenImageURL] != nil);
        }else{
            return [[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID] != nil && [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.videoURL] != nil;
        }
        
    }
    return NO;
}

-(NSString *) priceForReadyUnitGroupModel:(ATUnitGroupModel*)unitGroupModel setting:(ATADXPlacementSetting*)setting {
    if([[ATADXLoader sharedLoader] readyADXAdWithUnitGroupModel:unitGroupModel placementID:setting.placementID]){
        ATADXOfferModel *offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:setting.placementID unitGroupModel:unitGroupModel];
        if(offerModel != nil){
            return offerModel.price;
        }
    }
    return @"0";
}

@end

