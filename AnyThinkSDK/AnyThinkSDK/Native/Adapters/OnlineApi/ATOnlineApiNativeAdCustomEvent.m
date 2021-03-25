//
//  ATOnlineApiNativeAdCustomEvent.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiNativeAdCustomEvent.h"
#import "ATOnlineApiTracker.h"
#import "ATOnlineApiLoadingDelegate.h"
#import "ATLogger.h"
#import "ATNativeADOfferManager.h"
#import "ATOnlineApiOfferModel.h"
#import "ATAPI.h"
#import "NSString+KAKit.h"
#import <StoreKit/StoreKit.h>
#import "ATOnlineApiLoader.h"
#import "Utilities.h"

@interface ATOnlineApiNativeAdCustomEvent ()<ATOnlineApiLoadingDelegate, SKStoreProductViewControllerDelegate>

@end
@implementation ATOnlineApiNativeAdCustomEvent

// MARK:- ATOnlineApiLoadingDelegate
- (void)didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiNativeAdCustomEvent::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    ATOnlineApiOfferModel *offerModel = [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:self.unitGroupModel.unitID placementID:self.setting.placementID];
    self.offerModel = offerModel;
    
    NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.offerModel, kAdAssetsCustomObjectKey, unitID, kNativeADAssetsUnitIDKey, self, kAdAssetsCustomEventKey, nil];
    
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

- (void)didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiNativeAdCustomEvent::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
}

- (void)didFailToLoadADWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID error:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"ATOnlineApiNativeAdCustomEvent:didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    self.requestCompletionBlock(nil, error);
}

// MARK:- ATOnlineApiNativeDelegate
- (void)onlineApiNativeFailToShowOffer:(ATOnlineApiOfferModel *)offer error:(NSError *)error {
    [ATLogger logMessage:@"ATOnlineApiNativeAdCustomEvent::onlineApiNativeFailToShowOffer:" type:ATLogTypeExternal];
}

- (void)onlineApiNativeShowOffer:(ATOnlineApiOfferModel *)offer {

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
            [ATLogger logMessage:@"ATOnlineApiNativeAdCustomEvent::onlineApiNativeShowOffer:" type:ATLogTypeExternal];
            [[ATOnlineApiLoader sharedLoader] recordShownAdWithOfferID:offer.offerID unitID:offer.unitID];
            [self trackNativeAdImpression];
            
            NSString *lifeCircleID = self.serverInfo[kAdapterCustomInfoRequestIDKey] != nil ? self.serverInfo[kAdapterCustomInfoRequestIDKey] : @"";
            NSDictionary *trackerExtra = @{kATOfferTrackerExtraLifeCircleID: lifeCircleID ? lifeCircleID : @""};
            [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventImpression offerModel:self.offerModel extra:trackerExtra];
        }
    });
    [[ATOnlineApiLoader sharedLoader] removeOfferModel:offer];
}

- (void)onlineApiNativeDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiNativeAdCustomEvent::onlineApiNativeDeepLinkOrJumpResult:" type:ATLogTypeExternal];
    [self trackNativeAdDeeplinkOrJumpResult:success];

}
- (void)onlineApiNativeClickOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiNativeAdCustomEvent::onlineApiNativeClickOffer:" type:ATLogTypeExternal];
    [self trackNativeAdClick];
}

- (NSString *)lifeCircleIDForOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiNativeAdCustomEvent::lifeCircleIDForOffer:" type:ATLogTypeExternal];
    return self.serverInfo[kAdapterCustomInfoRequestIDKey];
}

- (void)trackNativeAdShow:(BOOL)refresh {
    [super trackNativeAdShow:refresh];
    if (self.offerModel.displayDuration) {
        [self checkSizeAfterOneSecond];
        return;
    }
    [self didMoveToWindow];
}
//to do
- (NSString *)networkUnitId {
    return self.serverInfo[@"my_oid"];
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

// MARK:- store kit delegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

// MARK:- private methods
- (void)didMoveToWindow {
    if(_offerModel != nil && _setting != nil){
        NSString *lifeCircleID = self.serverInfo[kAdapterCustomInfoRequestIDKey] != nil ? self.serverInfo[kAdapterCustomInfoRequestIDKey] : @"";
//        NSDictionary *trackerExtra = @{kATOfferTrackerExtraLifeCircleID: lifeCircleID ? lifeCircleID : @""};
//        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventImpression offerModel:_offerModel extra:trackerExtra];
        [[ATOnlineApiTracker sharedTracker] preloadStorekitForOfferModel:_offerModel setting:_setting viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID skDelegate:self];
    }
}

- (void)checkSizeAfterOneSecond {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.offerModel.displayDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        if (self.adView == nil) {
            return;
        }
        CGRect adRect = self.adView.frame;
        CGRect windowRect = [UIApplication sharedApplication].keyWindow.frame;
        CGRect intersection = CGRectIntersection(adRect, windowRect);
        CGFloat interSize = intersection.size.width * intersection.size.height;
        CGFloat adSize = adRect.size.width * adRect.size.height;
        if (interSize > adSize/2) {
            [self didMoveToWindow];
        }
    });
}
@end
