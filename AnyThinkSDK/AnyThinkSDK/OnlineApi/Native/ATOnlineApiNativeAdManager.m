//
//  ATOnlineApiNativeAdManager.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiNativeAdManager.h"
#import "ATOfferResourceManager.h"
#import "ATOnlineApiOfferModel.h"
#import "ATThreadSafeAccessor.h"
#import "NSDictionary+KAKit.h"
#import "NSArray+KAKit.h"
#import "ATOnlineApiTracker.h"
#import <StoreKit/StoreKit.h>
#import "Utilities.h"

@interface ATOnlineApiNativeAdManager ()<SKStoreProductViewControllerDelegate>

@end
@implementation ATOnlineApiNativeAdManager

// MARK:- initialization

+(instancetype) sharedManager {
    static ATOnlineApiNativeAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATOnlineApiNativeAdManager alloc] init];
    });
    return sharedManager;
}

// MARK:- storeKit delegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

// MARK:- function claimed in .h

- (void)registerViewCtrlForInteraction:(UIViewController *)viewController adView:(UIView *)adView clickableViews:(NSArray<UIView *> *)clickableViews offerModel:(ATOnlineApiOfferModel *)offerModel setting:(ATOnlineApiPlacementSetting  *)setting delegate:(id<ATOnlineApiNativeDelegate>)delegate {

    self.model = offerModel;
    self.setting = setting;
    self.adView = adView;
    
    ATOfferResourceModel *model = [[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID];
    if (model == nil) {
        
        NSError *error = [NSError errorWithDomain:@"com.anythink.onlineApiNativeShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"onlineApi has failed to show Native", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Native's not ready for offerID:%@", offerModel.offerID]}];
        if ([delegate respondsToSelector:@selector(onlineApiNativeFailToShowOffer:error:)]) {
            [delegate onlineApiNativeFailToShowOffer:offerModel error:error];
        }
        
        return;
    }
    
    [self.delegateStorageAccessor writeWithBlock:^{
        [self.delegateStorage AT_setWeakObject:delegate forKey:offerModel.offerID];
    }];
    
    [self setTapGestureToViews:clickableViews];
    
    NSString *lifeCircleID = @"";
    if ([delegate respondsToSelector:@selector(lifeCircleIDForOffer:)]) {
        lifeCircleID = [delegate lifeCircleIDForOffer:offerModel];
    }
    
    [[ATOnlineApiTracker sharedTracker] preloadStorekitForOfferModel:offerModel setting:setting viewController:viewController circleId:lifeCircleID skDelegate:self];
    
    [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
    
    [self.delegateStorageAccessor readWithBlock:^id{
        
        id<ATOnlineApiNativeDelegate> kdelegate = [self.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([kdelegate respondsToSelector:@selector(onlineApiNativeShowOffer:)]) {
            [kdelegate onlineApiNativeShowOffer:offerModel];
        }
        return nil;
    }];
}

// MARK:- private methods
- (void)setTapGestureToViews:(NSArray<UIView *> *)views {
    for (UIView *subview in views) {
        if ([subview respondsToSelector:@selector(setUserInteractionEnabled:)]) {
            [subview setUserInteractionEnabled:YES];
        }
        if ([subview respondsToSelector:@selector(addGestureRecognizer:)]) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped:)];
            [subview addGestureRecognizer:tap];
        }
    }
}

- (void)adViewTapped:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:tap.view];
    point = [tap.view convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
    CGPoint relativePoint = [tap locationInView:self.adView];

    [ATLogger logMessage:@"ATOnlineApiNative::adViewTapped" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiNativeDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:weakSelf.model.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:weakSelf.model] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        NSDictionary *dic = @{kATOfferTrackerGDTDownX: @(point.x),
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
        weakSelf.model.tapInfoDict = dic;
        [[ATOnlineApiTracker sharedTracker] clickOfferWithOfferModel:weakSelf.model setting:self.setting circleID:lifeCircleID delegate:self viewController:[UIApplication sharedApplication].keyWindow.rootViewController extra:trackerExtra clickCallbackHandler:^(BOOL success) {
            if ([delegate respondsToSelector:@selector(onlineApiNativeDeepLinkOrJumpResult:offer:)]) {
                [delegate onlineApiNativeDeepLinkOrJumpResult:success offer:weakSelf.model];
            }
        }];
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventClick offerModel:weakSelf.model extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(onlineApiNativeClickOffer:)]) { [delegate onlineApiNativeClickOffer:weakSelf.model]; }
        return nil;
    }];
}

@end
