//
//  ATADXNativeCustomEvent.m
//  AnyThinkSDK
//
//  Created by Topon on 10/20/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXNativeCustomEvent.h"
#import "Utilities.h"
#import "ATADXTracker.h"
#import "ATAdManagement.h"
#import "ATADXLoader.h"
#import "ATBidInfoManager.h"

@implementation ATADXNativeCustomEvent

-(void) didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXNative::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    ATADXOfferModel *offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:self.setting.placementID unitGroupModel:self.unitGroupModel];
    self.offerModel = offerModel;
    
    NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.offerModel, kAdAssetsCustomObjectKey, unitID, kNativeADAssetsUnitIDKey, self, kAdAssetsCustomEventKey, self.price, kAdAssetsPriceKey, self.bidId, kAdAssetsBidIDKey, nil];
    
    if ([self.offerModel.title length] > 0) { asset[kNativeADAssetsMainTitleKey] = self.offerModel.title; }
    if ([self.offerModel.text length] > 0) { asset[kNativeADAssetsMainTextKey] = self.offerModel.text; }
    if ([self.offerModel.CTA length] > 0) { asset[kNativeADAssetsCTATextKey] = self.offerModel.CTA; }
    
    dispatch_group_t img_group = dispatch_group_create();
    if ([self.offerModel.iconURL length] > 0) {
        asset[kNativeADAssetsIconURLKey] = self.offerModel.iconURL;
       dispatch_group_enter(img_group);
       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:self.offerModel.iconURL] completion:^(UIImage *image, NSError *error) {
           if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsIconImageKey] = image; }
           dispatch_group_leave(img_group);
       }];
    }
    if ([self.offerModel.fullScreenImageURL length] > 0) {
        asset[kNativeADAssetsImageURLKey] = self.offerModel.fullScreenImageURL;
       dispatch_group_enter(img_group);
       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:self.offerModel.fullScreenImageURL] completion:^(UIImage *image, NSError *error) {
           if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsMainImageKey] = image; }
           dispatch_group_leave(img_group);
       }];
    }
    if ([self.offerModel.logoURL length] > 0) {
        asset[kNativeADAssetsLogoURLKey] = self.offerModel.logoURL;
       dispatch_group_enter(img_group);
       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:self.offerModel.logoURL] completion:^(UIImage *image, NSError *error) {
           if ([image isKindOfClass:[UIImage class]]) { asset[kNativeADAssetsLogoImageKey] = image; }
           dispatch_group_leave(img_group);
       }];
    }
    
    dispatch_group_notify(img_group, dispatch_get_main_queue(), ^{
        self.requestCompletionBlock(@[asset], nil);
    });
}

-(void) didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXNative::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID unitID:(NSString *)unitID error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"ADXNative:didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error);
}
-(void) adxNativeFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error {
    [ATLogger logMessage:@"ADXNative::adxNativeFailToShowOffer:" type:ATLogTypeExternal];
}

- (void)adxNativeDeepLinkOrJumpResult:(BOOL)success offer:(ATADXOfferModel *)offer {
    [ATLogger logMessage:@"ADXNative::adxNativeDeepLinkOrJumpResult:" type:ATLogTypeExternal];
    [self trackNativeAdDeeplinkOrJumpResult:success];
}
-(void) adxNativeShowOffer:(ATADXOfferModel*)offer {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        if (self.adView == nil) {
            return;
        }
        CGRect adRect = self.adView.frame;
        CGRect windowRect = [UIApplication sharedApplication].keyWindow.frame;
        CGRect intersection = CGRectIntersection(adRect, windowRect);
        CGFloat interSize = intersection.size.width * intersection.size.height;
        CGFloat adSize = adRect.size.width * adRect.size.height;
        if (interSize > adSize/2) {
            [ATLogger logMessage:@"ADXNative::adxNativeShowOffer:" type:ATLogTypeExternal];
            [self trackNativeAdImpression];
        }
    });
    
    [[ATADXLoader sharedLoader] removeOfferModel:offer];
    [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:self.setting.placementID unitGroupModel:self.unitGroupModel requestID:self.requestID];
}

-(void) adxNativeClickOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXNative::adxNativeClickOffer:" type:ATLogTypeExternal];
    [self trackNativeAdClick];
}

- (NSString *)lifeCircleIDForOffer:(ATADXOfferModel *)offer {
    [ATLogger logMessage:@"ADXNative::lifeCircleIDForOffer:" type:ATLogTypeExternal];
    return self.serverInfo[kAdapterCustomInfoRequestIDKey];
}

- (void)trackNativeAdShow:(BOOL)refresh {
    [super trackNativeAdShow:refresh];
    [self didMoveToWindow];
//    [Utilities reportProfit:self.ad time:self.sdkTime];
}

//父视图已更改
- (void)didMoveToWindow {
    if(self.offerModel != nil && self.setting != nil){
        NSString *lifeCircleID = self.serverInfo[kAdapterCustomInfoRequestIDKey] != nil ? self.serverInfo[kAdapterCustomInfoRequestIDKey] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventImpression offerModel:self.offerModel extra:trackerExtra];
        [[ATADXTracker sharedTracker] preloadStorekitForOfferModel:self.offerModel setting:self.setting viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID skDelegate:self];
    }
}

- (NSString *)networkUnitId {
    return _unitGroupModel.unitID;
}

- (NSDictionary *)networkCustomInfo {
    if (self.offerModel != nil) {
        BOOL isDeepLink = NO;
        if ([Utilities isEmpty:self.offerModel.deeplinkUrl] == NO || [Utilities isEmpty:self.offerModel.jumpUrl] == NO) {
            isDeepLink = YES;
        }
        NSDictionary *extInfo = @{kATADDelegateExtraOfferIDKey:self.offerModel.offerID != nil ? self.offerModel.offerID : @"", kATADDelegateExtraCreativeIDKey:self.offerModel.resourceID != nil ? self.offerModel.resourceID : @"", kATADDelegateExtraIsDeeplinkKey:@(isDeepLink)};
        return extInfo;
    }else {
        return nil;
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

@end
