//
//  ATOnlineApiBannerAdManager.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiBannerAdManager.h"
#import <StoreKit/StoreKit.h>
#import "Utilities.h"
#import "ATADXAdManager.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATOnlineApiOfferModel.h"
#import "ATOfferResourceManager.h"
#import "ATOnlineApiBannerDelegate.h"
#import "ATOnlineApiTracker.h"
#import <UIKit/UIKit.h>
#import "ATAdManager+Banner.h"

@interface ATOnlineApiBannerAdManager ()<ATOfferBannerDelegate,SKStoreProductViewControllerDelegate>
@property (nonatomic) dispatch_semaphore_t semaphore;
@end

@implementation ATOnlineApiBannerAdManager

// MARK:- initializaiton

+ (instancetype)sharedManager {
    static ATOnlineApiBannerAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATOnlineApiBannerAdManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (BOOL)checkReadyForOfferModel:(ATOnlineApiOfferModel *)offerModel setting:(ATOnlineApiPlacementSetting *) setting{
    if (offerModel.crtType == ATOfferCrtTypeOneImage) {
        return [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.fullScreenImageURL] != nil;
    } else {
        if([setting.bannerSize isEqualToString:kATOfferBannerSize320_50]){
            return [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil;
        }else {
            return [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil && [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.fullScreenImageURL] != nil;
        }
    }
}

- (ATOfferBannerView  *)retrieveBannerViewWithOfferModel:(ATOnlineApiOfferModel  *)offerModel setting:(ATOnlineApiPlacementSetting  *)setting extra:(NSDictionary  *)extra delegate:(id<ATOnlineApiBannerDelegate>) delegate {
    self.setting = setting;
    self.model = offerModel;
    
    __weak typeof(self) weakSelf = self;
    return [self.delegateStorageAccessor readWithBlock:^id{
        if ([[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
            if ([self checkReadyForOfferModel:offerModel setting:setting]) {
                [weakSelf.delegateStorage AT_setWeakObject:delegate forKey:offerModel.offerID];
                
                CGSize adSize = [Utilities sizeFromString:setting.bannerSize];
                if (offerModel.crtType == ATOfferCrtTypeOneImage && [extra[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
                    adSize = [extra[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue];
                }
                __block ATOfferBannerView* adView = nil;
                if([NSThread isMainThread]){
                    adView = [[ATOfferBannerView alloc] initWithFrame:CGRectMake(.0f, .0f, adSize.width, adSize.height) offerModel:offerModel setting:setting];
                    adView.delegate = weakSelf;
                    [adView initOfferBannerView];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        adView = [[ATOfferBannerView alloc] initWithFrame:CGRectMake(.0f, .0f, adSize.width, adSize.height) offerModel:offerModel setting:setting];
                        adView.delegate = weakSelf;
                        [adView initOfferBannerView];
                        dispatch_semaphore_signal(weakSelf.semaphore);
                    });
                    dispatch_semaphore_wait(weakSelf.semaphore, DISPATCH_TIME_FOREVER);
                }
                
                [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
                return adView;
            }else {
                return nil;
            }
        }else {
            return nil;
        }
    }];
}

- (void)offerBannerShowOffer:(ATOnlineApiOfferModel *)offerModel {
    [ATLogger logMessage:@"ATOnlineApiBanner::offerBannerShowOffer" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiBannerDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(onlineApiBannerShowOffer:)]) {
            [delegate onlineApiBannerShowOffer:offerModel];
        }
        [[ATOnlineApiTracker sharedTracker] preloadStorekitForOfferModel:offerModel setting:self.setting viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID skDelegate:self];
        return nil;
    }];
}

- (void)offerBannerClickOffer:(ATOnlineApiOfferModel *)offerModel {
    [ATLogger logMessage:@"ATOnlineApiBanner::offerBannerClickOffer" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiBannerDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        [trackerExtra addEntriesFromDictionary:offerModel.tapInfoDict];
        [[ATOnlineApiTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:self.setting circleID:lifeCircleID delegate:self viewController:[UIApplication sharedApplication].keyWindow.rootViewController extra:trackerExtra clickCallbackHandler:^(BOOL success) {
            if ([delegate respondsToSelector:@selector(onlineApiBannerDeepLinkOrJumpResult:offer:)]) {
                [delegate onlineApiBannerDeepLinkOrJumpResult:success offer:offerModel];
            }
        }];
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventClick offerModel:offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(onlineApiBannerClickOffer:)]) {
            [delegate onlineApiBannerClickOffer:offerModel];
        }
        return nil;
    }];
}

- (void)offerBannerCloseOffer:(ATOnlineApiOfferModel *)offerModel {
    [ATLogger logMessage:@"ATOnlineApiBanner::offerBannerCloseOffer" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiBannerDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(onlineApiBannerCloseOffer:)]) {
            [delegate onlineApiBannerCloseOffer:offerModel];
        }
        return nil;
    }];
}

- (void)offerBannerFailToShowOffer:(ATOnlineApiOfferModel *)offerModel error:(NSError *)error {
    [ATLogger logMessage:@"ATOnlineApiBanner::offerBannerFailToShowOffer::error" type:ATLogTypeExternal];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

@end
