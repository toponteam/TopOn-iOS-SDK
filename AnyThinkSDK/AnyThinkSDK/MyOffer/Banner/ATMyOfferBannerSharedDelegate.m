//
//  ATMyofferBannerSharedDelegate.m
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferBannerSharedDelegate.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATMyOfferOfferManager.h"
#import "ATMyOfferTracker.h"
#import "ATMyOfferCapsManager.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
#import "ATMyOfferBannerView.h"
#import "Utilities.h"

@interface ATMyOfferBannerSharedDelegate()
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
        _delegateStorageAccessor = [ATThreadSafeAccessor new];
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

-(BOOL) checkReadyForOfferModel:(ATMyOfferOfferModel *)offerModel setting:(ATMyOfferSetting *) setting{
    if([setting.bannerSize isEqualToString:kATMyOfferBannerSize320_50]){
        return offerModel.bannerImageUrl != nil && offerModel.bannerImageUrl.length>0 ? [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.bannerImageUrl] != nil:[[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil;
    }
    if([setting.bannerSize isEqualToString:kATMyOfferBannerSize320_90]){
        return offerModel.bannerBigImageUrl != nil && offerModel.bannerBigImageUrl.length>0 ? [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.bannerBigImageUrl] != nil:[[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil;
    }
    if([setting.bannerSize isEqualToString:kATMyOfferBannerSize300_250]){
        return offerModel.rectangleImageUrl != nil && offerModel.rectangleImageUrl.length>0 ? [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.rectangleImageUrl] != nil:[[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil;
    }
    //728*90
    return offerModel.homeImageUrl != nil && offerModel.homeImageUrl.length>0 ? [[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.homeImageUrl] != nil:[[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.iconURL] != nil;
}

-(ATMyOfferBannerView*)retrieveBannerViewWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting  extra:(NSDictionary *)extra delegate:(id<ATMyOfferBannerDelegate>) delegate{
    
    _setting = setting;
    _offerModel = offerModel;
    return [_delegateStorageAccessor readWithBlock:^id{
        if ([[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
            if ([self checkReadyForOfferModel:offerModel setting:setting]) {
                __weak typeof(self) weakSelf = self;
                
                CGSize adSize = [Utilities sizeFromString:setting.bannerSize];
                __block ATMyOfferBannerView* adView = nil;
                if([NSThread isMainThread]){
                    adView = [[ATMyOfferBannerView alloc] initWithFrame:CGRectMake(.0f, .0f, adSize.width, adSize.height) offerModel:offerModel setting:setting delegate:delegate viewController:[UIApplication sharedApplication].keyWindow.rootViewController];
                    [adView initMyOfferBannerView];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        adView = [[ATMyOfferBannerView alloc] initWithFrame:CGRectMake(.0f, .0f, adSize.width, adSize.height) offerModel:offerModel setting:setting delegate:delegate viewController:[UIApplication sharedApplication].keyWindow.rootViewController];
                        [adView initMyOfferBannerView];
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
@end
