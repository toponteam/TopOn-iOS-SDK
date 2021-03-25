//
//  ATADXBannerAdManager.m
//  AnyThinkSDK
//
//  Created by Topon on 10/22/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXBannerAdManager.h"
#import <StoreKit/StoreKit.h>
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATADXTracker.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
#import "ATAdManager+Banner.h"

@interface ATADXBannerAdManager()<ATOfferBannerDelegate,SKStoreProductViewControllerDelegate>
@property (nonatomic) dispatch_semaphore_t  semaphore;
@end

@implementation ATADXBannerAdManager

+(instancetype) sharedManager {
    static ATADXBannerAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATADXBannerAdManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}
 
-(BOOL) checkReadyForOfferModel:(ATADXOfferModel *)offerModel setting:(ATADXPlacementSetting *) setting{
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

- (ATOfferBannerView *)retrieveBannerViewWithOfferModel:(ATADXOfferModel *)offerModel setting:(ATADXPlacementSetting *)setting  extra:(NSDictionary *)extra delegate:(id<ATADXBannerDelegate>) delegate {
    self.setting = setting;
    self.offerModel = offerModel;
    
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

- (void)offerBannerShowOffer:(ATADXOfferModel *)offerModel {
    [ATLogger logMessage:@"ATADXBanner::offerBannerShowOffer" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXBannerDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(adxBannerShowOffer:)]) {
            [delegate adxBannerShowOffer:offerModel];
        }
        [[ATADXTracker sharedTracker] preloadStorekitForOfferModel:offerModel setting:self.setting viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID skDelegate:self];
        return nil;
    }];
}

- (void)offerBannerClickOffer:(ATADXOfferModel *)offerModel {
    [ATLogger logMessage:@"ATADXBanner::offerBannerClickOffer" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXBannerDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        [trackerExtra addEntriesFromDictionary:offerModel.tapInfoDict];
        [[ATADXTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:self.setting extra:trackerExtra skDelegate:self viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID clickCallbackHandler:^(BOOL success) {
            if ([delegate respondsToSelector:@selector(adxBannerDeepLinkOrJumpResult:offer:)]) {
                [delegate adxBannerDeepLinkOrJumpResult:success offer:offerModel];
            }
        }];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventClick offerModel:offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(adxBannerClickOffer:)]) {
            [delegate adxBannerClickOffer:offerModel];
        }
        return nil;
    }];
}

- (void)offerBannerCloseOffer:(ATADXOfferModel *)offerModel {
    [ATLogger logMessage:@"ATADXBanner::offerBannerCloseOffer" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXBannerDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(adxBannerCloseOffer:)]) {
            [delegate adxBannerCloseOffer:offerModel];
        }
        return nil;
    }];
}

- (void)offerBannerFailToShowOffer:(ATADXOfferModel *)offerModel error:(NSError *)error {
    [ATLogger logMessage:@"ATADXBanner::offerBannerFailToShowOffer::error" type:ATLogTypeExternal];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}


@end
