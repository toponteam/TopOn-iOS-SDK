//
//  ATADXNativeAdManager.m
//  AnyThinkSDK
//
//  Created by Topon on 10/21/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXNativeAdManager.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATADXAdManager.h"
#import "ATADXTracker.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"

@implementation ATADXNativeAdManager
+(instancetype) sharedManager {
    static ATADXNativeAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATADXNativeAdManager alloc] init];
    });
    return sharedManager;
}

- (void)adViewTapped:(UITapGestureRecognizer *)tap {
    [ATLogger logMessage:@"ATADXNative::adViewTapped" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        CGPoint relativePoint = [tap locationInView:self.adView];
        CGPoint point = [tap.view convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
        id<ATADXNativeDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:weakSelf.offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:weakSelf.offerModel] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        
        NSDictionary *dic = @{
            kATOfferTrackerGDTDownX: @(point.x),
                              kATOfferTrackerGDTDownY: @(point.y),
                              kATOfferTrackerGDTUpX:   @(point.x),
                              kATOfferTrackerGDTUpY:   @(point.y),
                              kATOfferTrackerGDTWidth: @([UIScreen mainScreen].nativeScale * tap.view.frame.size.width),
                              kATOfferTrackerGDTHeight:@([UIScreen mainScreen].nativeScale * tap.view.frame.size.height),
                              kATOfferTrackerGDTRequestWidth: @([UIScreen mainScreen].nativeScale * tap.view.frame.size.width),
                              kATOfferTrackerGDTRequestHeight:@([UIScreen mainScreen].nativeScale * tap.view.frame.size.height),
                              kATOfferTrackerRelativeDownX:   @(relativePoint.x),
                              kATOfferTrackerRelativeDownY:   @(relativePoint.y),
                              kATOfferTrackerRelativeUpX:     @(relativePoint.x),
                              kATOfferTrackerRelativeUpY:     @(relativePoint.y)
        };
        [trackerExtra addEntriesFromDictionary:dic];
        
        [[ATADXTracker sharedTracker] clickOfferWithOfferModel:weakSelf.offerModel setting:weakSelf.setting extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:weakSelf viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID ? lifeCircleID : @"" clickCallbackHandler:^(BOOL success) {
            if ([delegate respondsToSelector:@selector(adxNativeDeepLinkOrJumpResult:offer:)]) {
                [delegate adxNativeDeepLinkOrJumpResult:success offer:weakSelf.offerModel];
            }
        }];
        
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventClick offerModel:weakSelf.offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(adxNativeClickOffer:)]) { [delegate adxNativeClickOffer:weakSelf.offerModel]; }
        return nil;
    }];
}


- (void)registerViewForInteraction:(UIViewController *)viewController adView:(UIView *)adView clickableViews:(NSArray<UIView *> *)clickableViews offerModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting *)setting delegate:(id<ATADXNativeDelegate>)delegate {
    self.offerModel = offerModel;
    self.setting = setting;
    self.adView = adView;
    if ([[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
        __weak typeof(self) weakSelf = self;
        weakSelf.viewController = viewController;
        [self.delegateStorageAccessor writeWithBlock:^{
            [weakSelf.delegateStorage AT_setWeakObject:delegate forKey:offerModel.offerID];
        }];
        if (clickableViews.count > 0) {
            [clickableViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(setUserInteractionEnabled:)]) { [obj setUserInteractionEnabled:YES]; }
                if ([obj respondsToSelector:@selector(addGestureRecognizer:)]) {
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped:)];
                    [obj addGestureRecognizer:tap];
                }
            }];
        }
        
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:weakSelf.offerModel] : @"";
        [[ATADXTracker sharedTracker] preloadStorekitForOfferModel:self.offerModel setting:self.setting viewController:_viewController circleId:lifeCircleID skDelegate:self];
        
        [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
        
        [self.delegateStorageAccessor readWithBlock:^id{
            id<ATADXNativeDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:weakSelf.offerModel.offerID];
            if ([delegate respondsToSelector:@selector(adxNativeShowOffer:)]) {
                [delegate adxNativeShowOffer:offerModel];
            }
            return nil;
        }];
        
    } else {
        if ([delegate respondsToSelector:@selector(adxNativeFailToShowOffer:error:)]) { [delegate adxNativeFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.ADXNativeShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"ADX has failed to show Native", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Native's not ready for offerID:%@", offerModel.offerID]}]]; }
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}


@end
