//
//  ATMyOfferOfferManager.m
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferOfferManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATMyOfferResourceLoader.h"
#import "ATMyOfferCapsManager.h"
#import "ATMyOfferResourceManager.h"
#import "Utilities.h"
#import "ATMyOfferInterstitialSharedDelegate.h"
#import "ATMyOfferRewardedVideoSharedDelegate.h"
#import "ATMyOfferSplashSharedDelegate.h"
#import "ATMyOfferNativeSharedDelegate.h"

NSString *const kATMyOfferBannerSize320_50 = @"320x50";
NSString *const kATMyOfferBannerSize320_90 = @"320x90";
NSString *const kATMyOfferBannerSize300_250 = @"300x250";
NSString *const kATMyOfferBannerSize728_90 = @"728x90";

@interface ATMyOfferOfferManager()
@end
@implementation ATMyOfferOfferManager
+(instancetype) sharedManager {
    static ATMyOfferOfferManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATMyOfferOfferManager alloc] init];
    });
    return sharedManager;
}

-(BOOL) resourceReadyForOfferModel:(ATMyOfferOfferModel*)offerModel {
    return [[ATMyOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID] != nil;
}

-(BOOL) offerReadyForOfferModel:(ATMyOfferOfferModel*)offerModel {
    return [[ATMyOfferCapsManager shareManager] validateCapsForOfferModel:offerModel] && [[ATMyOfferCapsManager shareManager] validatePacingForOfferModel:offerModel] && [[ATMyOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID] != nil && [[ATMyOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.videoURL] != nil;
}

-(BOOL) offerReadyForInterstitialOfferModel:(ATMyOfferOfferModel*)offerModel {
    return [[ATMyOfferCapsManager shareManager] validateCapsForOfferModel:offerModel] && [[ATMyOfferCapsManager shareManager] validatePacingForOfferModel:offerModel] && [[ATMyOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID] != nil && [[ATMyOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.fullScreenImageURL] != nil;
}

-(ATMyOfferOfferModel*) defaultOfferInOfferModels:(NSArray<ATMyOfferOfferModel*>*)offerModels {
    __block ATMyOfferOfferModel *offer = [offerModels firstObject];
    __block NSInteger minCap = [[ATMyOfferCapsManager shareManager] capForOfferModel:[offerModels firstObject]];
    [offerModels enumerateObjectsUsingBlock:^(ATMyOfferOfferModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger curCap = [[ATMyOfferCapsManager shareManager] capForOfferModel:obj];
        offer = [[ATMyOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:obj.localResourceID] != nil && curCap < minCap ? obj : offer;
    }];
    return offer;
}

-(void) loadOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion {
    do {
        if (![[ATMyOfferCapsManager shareManager] validateCapsForOfferModel:offerModel]) {
            completion([NSError errorWithDomain:@"com.anythink.MyOfferLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to load ad", NSLocalizedFailureReasonErrorKey:@"Cap has been exeeded."}]);
            break;
        }
        if (![[ATMyOfferCapsManager shareManager] validatePacingForOfferModel:offerModel]) {
            completion([NSError errorWithDomain:@"com.anythink.MyOfferLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to load ad", NSLocalizedFailureReasonErrorKey:@"Within pacing limit"}]);
            break;
        }
        [[ATMyOfferResourceLoader sharedLoader] loadOfferWithOfferModel:offerModel setting:setting extra:extra completion:completion];
    } while (NO);
}

-(void) showInterstitialWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferInterstitialDelegate>)delegate {
    [[ATMyOfferInterstitialSharedDelegate sharedDelegate] showInterstitialWithOfferModel:offerModel setting:setting viewController:viewController delegate:delegate];
}

-(void) showRewardedVideoWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferRewardedVideoDelegate>)delegate {
    [[ATMyOfferRewardedVideoSharedDelegate sharedDelegate] showRewardedVideoWithOfferModel:offerModel setting:setting viewController:viewController delegate:delegate];
}

- (void)showSplashInKeyWindow:(UIWindow *)window containerView:(UIView *)containerView offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting  delegate:(id<ATMyOfferSplashDelegate>)delegate  {
    [[ATMyOfferSplashSharedDelegate sharedDelegate] showSplashInKeyWindow:window containerView:containerView offerModel:offerModel setting:setting delegate:delegate];
}

- (void)registerViewForInteraction:(UIViewController *)viewController clickableViews:(NSArray<UIView *> *)clickableViews offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting *)setting delegate:(id<ATMyOfferNativeDelegate>)delegate {
    [[ATMyOfferNativeSharedDelegate sharedDelegate] registerViewForInteraction:viewController clickableViews:clickableViews offerModel:offerModel setting:setting delegate:delegate];
}

@end
