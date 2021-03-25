//
//  ATMyofferBannerSharedDelegate.m
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferBannerSharedDelegate.h"
#import <StoreKit/StoreKit.h>
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATMyOfferOfferManager.h"
#import "ATMyOfferTracker.h"
#import "ATMyOfferCapsManager.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
#import "ATAdManager+Banner.h"

@interface ATMyOfferBannerSharedDelegate()<ATOfferBannerDelegate,SKStoreProductViewControllerDelegate>
@property(nonatomic, readonly) NSMutableDictionary<NSString*, id<ATMyOfferBannerDelegate>> *delegateStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *delegateStorageAccessor;
@property (nonatomic , strong)ATMyOfferOfferModel *offerModel;
@property (nonatomic) ATMyOfferSetting *setting;
@property (nonatomic) dispatch_semaphore_t  semaphore;
@end

@implementation ATMyOfferBannerSharedDelegate
+(instancetype) sharedDelegate {
    static ATMyOfferBannerSharedDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATMyOfferBannerSharedDelegate alloc] init];
    });
    return sharedDelegate;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _delegateStorage = [NSMutableDictionary<NSString*, id<ATMyOfferBannerDelegate>> dictionary];
        _delegateStorageAccessor = [ATThreadSafeAccessor new];
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

-(BOOL) checkReadyForOfferModel:(ATMyOfferOfferModel *)offerModel setting:(ATMyOfferSetting *) setting{
    if([setting.bannerSize isEqualToString:kATOfferBannerSize320_50]){
        return offerModel.bannerImageUrl != nil && offerModel.bannerImageUrl.length>0 ? [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.bannerImageUrl] != nil:[[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil;
    }
    if([setting.bannerSize isEqualToString:kATOfferBannerSize320_90]){
        return offerModel.bannerBigImageUrl != nil && offerModel.bannerBigImageUrl.length>0 ? [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.bannerBigImageUrl] != nil:[[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil;
    }
    if([setting.bannerSize isEqualToString:kATOfferBannerSize300_250]){
        return offerModel.rectangleImageUrl != nil && offerModel.rectangleImageUrl.length>0 ? [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.rectangleImageUrl] != nil:[[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil;
    }
    //728*90
    return offerModel.homeImageUrl != nil && offerModel.homeImageUrl.length>0 ? [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.homeImageUrl] != nil:[[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil;
}

-(ATOfferBannerView *)retrieveBannerViewWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting  extra:(NSDictionary *)extra delegate:(id<ATMyOfferBannerDelegate>) delegate{
    _setting = setting;
    _offerModel = offerModel;
    
    __weak typeof(self) weakSelf = self;
    return [_delegateStorageAccessor readWithBlock:^id{
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
                [[ATMyOfferCapsManager shareManager] increaseCapForOfferModel:offerModel];
                if ([[ATMyOfferCapsManager shareManager] validateCapsForOfferModel:offerModel]) {
                    [[ATPlacementSettingManager sharedManager] removeCappedMyOfferID:offerModel.offerID];
                } else {
                    [[ATPlacementSettingManager sharedManager] addCappedMyOfferID:offerModel.offerID];
                }
                return adView;
            }else {
                return nil;
            }
        }else {
            return nil;
        }
    }];
}

- (void)offerBannerShowOffer:(ATMyOfferOfferModel *)offerModel {
    [ATLogger logMessage:@"ATMyOfferBanner::offerBannerShowOffer" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferBannerDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        [[ATMyOfferTracker sharedTracker] impressionOfferWithOfferModel:offerModel extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(myOfferBannerShowOffer:)]) {
            [delegate myOfferBannerShowOffer:offerModel];
        }
        [[ATMyOfferTracker sharedTracker] preloadStorekitForOfferModel:offerModel setting:weakSelf.setting viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID skDelegate:self];
        return nil;
    }];
}

- (void)offerBannerClickOffer:(ATMyOfferOfferModel *)offerModel {
    [ATLogger logMessage:@"ATMyOfferBanner::offerBannerClickOffer" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferBannerDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:weakSelf.setting extra:trackerExtra skDelegate:self viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventClick offerModel:offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(myOfferBannerClickOffer:)]) {
            [delegate myOfferBannerClickOffer:offerModel];
        }
        return nil;
    }];
}

- (void)offerBannerCloseOffer:(ATMyOfferOfferModel *)offerModel {
    [ATLogger logMessage:@"ATMyOfferBanner::offerBannerCloseOffer" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferBannerDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(myOfferBannerCloseOffer:)]) {
            [delegate myOfferBannerCloseOffer:offerModel];
        }
        return nil;
    }];
}

- (void)offerBannerFailToShowOffer:(ATMyOfferOfferModel *)offerModel error:(NSError *)error {
    [ATLogger logMessage:@"ATMyOfferBanner::offerBannerFailToShowOffer::error" type:ATLogTypeExternal];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

@end
