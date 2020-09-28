//
//  ATMyOfferNativeAdapter.m
//  AnyThinkMyOffer
//
//  Created by Topon on 8/11/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferNativeAdapter.h"
#import "ATMyOfferNativeCustomEvent.h"
#import "ATMyOfferNativeRenderer.h"
#import "NSObject+ExtraInfo.h"
#import "ATMyOfferUtilities.h"
#import "ATPlacementModel.h"
#import "ATMyOfferOfferModel.h"
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferManager.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"

@interface ATMyOfferNativeAdapter ()
@property(nonatomic, readonly) ATMyOfferNativeCustomEvent *customEvent;
@end

@implementation ATMyOfferNativeAdapter

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
    ATMyOfferOfferModel *offerModel = [ATMyOfferUtilities getMyOfferModelWithOfferId:placementModel.offers offerID:unitGroup.content[@"my_oid"]];
    if (offerModel != nil && [[ATMyOfferOfferManager sharedManager] resourceReadyForOfferModel:offerModel]) {
        ATMyOfferNativeCustomEvent *customEvent = [[ATMyOfferNativeCustomEvent alloc] initWithUnitID:nil serverInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
        customEvent.offerModel = offerModel;
        customEvent.setting = placementModel.myOfferSetting;
        ATNativeADCache *offerCache = [[ATNativeADCache alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:[self nativeAdLoaded:offerModel customEvent:customEvent] unitGroup:unitGroup finalWaterfall:finalWaterfall];
        return offerCache;
    } else {
        return nil;
    }
}

+(ATMyOfferOfferModel*) resourceReadyMyOfferForPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info {
    ATMyOfferOfferModel *offerModel = [ATMyOfferUtilities getMyOfferModelWithOfferId:placementModel.offers offerID:unitGroupModel.content[@"my_oid"]];
    return [[ATMyOfferOfferManager sharedManager] resourceReadyForOfferModel:offerModel] ? offerModel : nil;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return YES;
}

+(Class) rendererClass {
    return [ATMyOfferNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMyOffer]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMyOffer];
                [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameMyOffer];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATMyOfferNativeCustomEvent alloc] init];
    _customEvent.requestExtra = localInfo;
    _customEvent.unitID = serverInfo[@"unit_id"];
    _customEvent.requestCompletionBlock = completion;
    
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    ATMyOfferOfferModel *offerModel = [ATMyOfferUtilities getMyOfferModelWithOfferId:placementModel.offers offerID:serverInfo[@"my_oid"]];
    
    _customEvent.offerModel = offerModel;
    _customEvent.setting = placementModel.myOfferSetting;
    
    __weak typeof(self) weakSelf = self;
    [[ATMyOfferOfferManager sharedManager] loadOfferWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:nil completion:^(NSError *error) {
        if (error == nil) {
            if (offerModel != nil && offerModel.offerID != nil && weakSelf.customEvent != nil) {
                weakSelf.customEvent.requestCompletionBlock(@[[ATMyOfferNativeAdapter nativeAdLoaded:offerModel customEvent:weakSelf.customEvent]], nil);
            }
        }else{
            weakSelf.customEvent.requestCompletionBlock(nil, error);
        }
    }];
}

+ (NSDictionary *)nativeAdLoaded:(ATMyOfferOfferModel*)offerModel customEvent:(ATMyOfferNativeCustomEvent*)customEvent {
    NSMutableDictionary *assetInfo = [NSMutableDictionary dictionary];
    assetInfo[kAdAssetsCustomEventKey] = customEvent;
    assetInfo[kAdAssetsCustomObjectKey] = offerModel;
    if ([offerModel.title length] > 0) { assetInfo[kNativeADAssetsMainTitleKey] = offerModel.title; }
    if ([offerModel.text length] > 0) { assetInfo[kNativeADAssetsMainTextKey] = offerModel.text; }
    if ([offerModel.CTA length] > 0) { assetInfo[kNativeADAssetsCTATextKey] = offerModel.CTA; }
    
    dispatch_group_t img_group = dispatch_group_create();
    if ([offerModel.iconURL length] > 0) {
       assetInfo[kNativeADAssetsIconURLKey] = offerModel.iconURL;
       dispatch_group_enter(img_group);
       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:offerModel.iconURL] completion:^(UIImage *image, NSError *error) {
           if ([image isKindOfClass:[UIImage class]]) { assetInfo[kNativeADAssetsIconImageKey] = image; }
           dispatch_group_leave(img_group);
       }];
    }
    if ([offerModel.fullScreenImageURL length] > 0) {
       assetInfo[kNativeADAssetsImageURLKey] = offerModel.fullScreenImageURL;
       dispatch_group_enter(img_group);
       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:offerModel.fullScreenImageURL] completion:^(UIImage *image, NSError *error) {
           if ([image isKindOfClass:[UIImage class]]) { assetInfo[kNativeADAssetsMainImageKey] = image; }
           dispatch_group_leave(img_group);
       }];
    }
    if ([offerModel.logoURL length] > 0) {
       assetInfo[kNativeADAssetsLogoURLKey] = offerModel.logoURL;
       dispatch_group_enter(img_group);
       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:offerModel.logoURL] completion:^(UIImage *image, NSError *error) {
           if ([image isKindOfClass:[UIImage class]]) { assetInfo[kNativeADAssetsLogoImageKey] = image; }
           dispatch_group_leave(img_group);
       }];
    }
    
    dispatch_group_wait(img_group, DISPATCH_TIME_FOREVER);
    return assetInfo;
}

@end
