//
//  ATOlApiInterstitialAdManager.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiInterstitialAdManager.h"
#import "ATOfferVideoViewController.h"
#import "ATOfferFullScreenPictureViewController.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATOnlineApiLoader.h"
#import "ATOnlineApiOfferModel.h"
#import "ATThreadSafeAccessor.h"
#import "NSDictionary+KAKit.h"
#import "ATOfferVideoViewController.h"
#import "ATLogger.h"
#import "ATOnlineApiInterstitialDelegate.h"
#import "ATOnlineApiTracker.h"
#import "NSString+KAKit.h"
#import "Utilities.h"

struct Turple {
    NSDictionary * data;
    id<ATOnlineApiInterstitialDelegate> delegate;
    NSString *circleID;
};

@interface ATOnlineApiInterstitialAdManager ()<ATOfferVideoDelegate, ATOfferFullScreenPictureDelegate,SKStoreProductViewControllerDelegate>
@property (nonatomic) NSInteger currentTime;

@end

@implementation ATOnlineApiInterstitialAdManager

// MARK:- initialization
+ (instancetype)sharedManager {
    static ATOnlineApiInterstitialAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATOnlineApiInterstitialAdManager alloc] init];
    });
    return sharedManager;
}

// MARK:- functions claimed in .h
- (void)showInterstitialWithUnitGroupModelID:(NSString *)uid setting:(ATOnlineApiPlacementSetting *)setting viewController:(UIViewController *)viewController delegate:(id<ATOnlineApiInterstitialDelegate>)delegate {
    
    ATOnlineApiOfferModel *model = [self readyOnlineApiAdWithUnitGroupModelID:uid placementSetting:setting];
    
    if (model == nil) {
        
        NSError *error = [NSError errorWithDomain:@"com.anythink.OnlineApiInterstitialShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"TopOn OnlineApi has failed to show interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Interstitial's not ready for adsourceId:%@", uid]}];
        if ([delegate respondsToSelector:@selector(didInterstitialFailToShowOffer:error:)]) {
            [delegate didInterstitialFailToShowOffer:self.model error:error];
        }
        return;
    }
    
    //to do
    self.model = model;
    self.setting = setting;
    [self.delegateStorageAccessor writeWithBlock:^{
        
        [self.delegateStorage AT_setWeakObject:delegate forKey:model.offerID];
        
        AsyncInMain(^{
            [self presentVideoVCBy:viewController];
        })
    }];
}

// MARK:- ATOfferFullScreenPictureDelegate
- (void)offerFullScreenPictureEndCardDidShowWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitial::offerFullScreenPictureEndCardDidShowWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventEndCardShow offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didInterstitialShowOffer:)]) { [delegate didInterstitialShowOffer:offerModel]; }

        [[ATOnlineApiTracker sharedTracker] preloadStorekitForOfferModel:weakSelf.model setting:weakSelf.setting viewController:weakSelf.currentViewController circleId:lifeCircleID skDelegate:self];

        return nil;
    }];
}

- (void)offerFullScreenPictureDidClickAdWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitial::offerFullScreenPictureDidClickAdWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATOnlineApiTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:weakSelf.setting circleID:lifeCircleID delegate:weakSelf viewController:weakSelf.currentViewController extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} clickCallbackHandler:^(BOOL success) {
            if ([delegate respondsToSelector:@selector(didIntersititalDeepLinkOrJumpResult:offer:)]) {
                [delegate didIntersititalDeepLinkOrJumpResult:success offer:offerModel];
            }
        }];
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventClick offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didInterstitialClickOffer:)]) { [delegate didInterstitialClickOffer:offerModel]; }
        return nil;
    }];
}

- (void)offerFullScreenPictureEndCardDidCloseWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitial::offerFullScreenPictureEndCardDidCloseWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventEndCardClose offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didInterstitialCloseOffer:)]) { [delegate didInterstitialCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
        return nil;
    }];
}
// MARK:- video delegate
- (void)offerVideoPlayTime:(NSInteger)second offerModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    self.currentTime = second;
    [offerModel.playingTKItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ATVideoPlayingTKItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (second == obj.triggerTime && obj.sent == NO) {
            NSDictionary *dic = @{kATOfferTrackerVideoTimePlayed: @(second),
                                  kATOfferTrackerVideoMilliTimePlayed: @(second * 1000)
            };
            [[ATOnlineApiTracker sharedTracker] trackWithUrls:obj.urls offerModel:offerModel extra:dic];
            obj.sent = YES;
            *stop = YES;
        }
    }];
}

- (void)offerVideoStartPlayWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoStartPlayWithOfferModel" type:ATLogTypeExternal];
    
    [self.delegateStorageAccessor readWithBlock:^id{
        [self handleStartPlay:offerModel];
        return nil;
    }];
}

- (void)offerVideoPlay25PercentWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoPlay25PercentWithOfferModel" type:ATLogTypeExternal];

    [self sendTrackerEvent:ATOnlineApiTrackerEventVideo25Percent model:offerModel];

}

- (void)offerVideoPlay50PercentWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoPlay50PercentWithOfferModel" type:ATLogTypeExternal];
    
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideo50Percent model:offerModel];

}

- (void)offerVideoPlay75PercentWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoPlay75PercentWithOfferModel" type:ATLogTypeExternal];
    
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideo75Percent model:offerModel];

}

- (void)offerVideoDidEndPlayWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoDidEndPlayWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoEnd model:offerModel];
}

- (void)offerVideoDidClickVideoWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoDidClickVideoWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoClick model:offerModel];
}

- (void)offerVideoDidClickAdWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoDidClickAdWithOfferModel" type:ATLogTypeExternal];
    
    [self.delegateStorageAccessor readWithBlock:^id{
        [self handleClickAdWithModel:offerModel extra:offerModel.tapInfoDict];
        return nil;
    }];
    
}

- (void)offerVideoDidVideoPausedWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoDidVideoPausedWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoPaused model:offerModel];
}

- (void)offerVideoDidVideoMutedWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoDidVideoMutedWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoMute model:offerModel];
}

- (void)offerVideoDidVideoUnMutedWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoDidVideoUnMutedWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoUnMute model:offerModel];
}

- (void)offerVideoDidCloseWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoDidCloseWithOfferModel" type:ATLogTypeExternal];
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiInterstitialDelegate> delegate = [self.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        
        if ([delegate respondsToSelector:@selector(didInterstitialCloseOffer:)]) {
            [delegate didInterstitialCloseOffer:offerModel];
        }
        [self.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
        return nil;
    }];
}

- (void)offerVideoEndCardDidShowWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoEndCardDidShowWithOfferModel" type:ATLogTypeExternal];
    
    [self sendTrackerEvent:ATOnlineApiTrackerEventEndCardShow model:offerModel];
}

- (void)offerVideoEndCardDidCloseWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoEndCardDidCloseWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventEndCardClose model:offerModel];
}

-(void)offerVideoResumedWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoResumedWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoResumed model:offerModel];
}

-(void)offerVideoSkipWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoSkipWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoSkip model:offerModel];
}

-(void)offerVideoPlayFailWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra{
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoPlayFailWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoPlayFail model:offerModel];
}

- (void)offerFullScreenPictureFeedbackViewDidSelectItemAtIndex:(NSInteger)index
                                                    offerModel:(ATOfferModel *)offerModel extraMsg:(NSString *)msg {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerFullScreenPictureFeedbackViewDidSelectItemAtIndex" type:ATLogTypeExternal];

    [self offerVideoFeedbackViewDidSelectItemAtIndex:index extraMsg:msg offerModel:offerModel];
}

- (void)offerVideoFeedbackViewDidSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offerModel:(ATOfferModel *)offerModel {
    [ATLogger logMessage:@"ATOnlineApiInterstitialAdManager::offerVideoFeedbackViewDidSelectItemAtIndex" type:ATLogTypeExternal];
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiInterstitialDelegate> delegate = [self.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        
        if ([delegate respondsToSelector:@selector(didIntersititalFeedbackViewSelectItemAtIndex:extraMsg:offer:)]) {
            [delegate didIntersititalFeedbackViewSelectItemAtIndex:index extraMsg:msg offer:offerModel];
        }
        return nil;
    }];
}

// MARK:- SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
}

// MARK:- private methods
- (void)presentVideoVCBy:(UIViewController *)vc {
    if (self.model.interstitialType == ATInterstitialVideo &&
        [Utilities isEmpty:self.model.videoURL] == NO) {

        ATOfferVideoViewController *videoVC = [[ATOfferVideoViewController alloc]initWithOfferModel:self.model rewardedVideoSetting:self.setting];
        self.currentViewController = videoVC;
        videoVC.delegate = self;
        videoVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [vc presentViewController:videoVC animated:YES completion:nil];
        return;
    }
    
    ATOfferFullScreenPictureViewController *videoViewController = [[ATOfferFullScreenPictureViewController alloc] initWithOfferModel:self.model rewardedVideoSetting:self.setting];
    self.currentViewController = videoViewController;
    videoViewController.delegate = self;
    videoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [vc presentViewController:videoViewController animated:YES completion:nil];
}

- (void)sendTrackerEvent:(ATOnlineApiTrackerEvent)event model:(ATOnlineApiOfferModel *)model {
    
    [self.delegateStorageAccessor readWithBlock:^id{
        struct Turple turple = [self generateDataForTK:model extra:nil];
        [[ATOnlineApiTracker sharedTracker] trackEvent:event offerModel:model extra:turple.data];
        return nil;
    }];
}

- (void)handleClickAdWithModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    struct Turple turple = [self generateDataForTK:offerModel extra:extra];
    [[ATOnlineApiTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:self.setting circleID:turple.circleID delegate:self viewController:self.currentViewController extra:extra clickCallbackHandler:^(BOOL success) {
        if ([turple.delegate respondsToSelector:@selector(didIntersititalDeepLinkOrJumpResult:offer:)]) {
            [turple.delegate didIntersititalDeepLinkOrJumpResult:success offer:offerModel];
        }
    }];
    
    [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventClick offerModel:offerModel extra:turple.data];
    
    if ([turple.delegate respondsToSelector:@selector(didInterstitialClickOffer:)]) {
        [turple.delegate didInterstitialClickOffer:offerModel];
    }
}

- (void)handleStartPlay:(ATOnlineApiOfferModel *)model {
    
    struct Turple turple = [self generateDataForTK:model extra:nil];
    NSDictionary *trackerExtra = turple.data;
    
    [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventImpression offerModel:model extra:trackerExtra];
    [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventVideoStart offerModel:model extra:trackerExtra];

    if ([turple.delegate respondsToSelector:@selector(didInterstitialShowOffer:)]) {
        [turple.delegate didInterstitialShowOffer:model];
    }

    if ([turple.delegate respondsToSelector:@selector(didInterstitialVideoStartOffer:)]) {
        [turple.delegate didInterstitialVideoStartOffer:model];
    }

    [[ATOnlineApiTracker sharedTracker] preloadStorekitForOfferModel:model setting:self.setting viewController:self.currentViewController circleId:turple.circleID skDelegate:self];
}

- (struct Turple)generateDataForTK:(ATOnlineApiOfferModel *)model extra:(NSDictionary *)extra {

    id<ATOnlineApiInterstitialDelegate> kDelegate =  [self.delegateStorage AT_weakObjectForKey:model.offerID];

    NSString *lifeCircleID = @"";
    if ([kDelegate respondsToSelector:@selector(lifeCircleIDForOffer:)]) {
        lifeCircleID = [kDelegate lifeCircleIDForOffer:model];
    }

    NSString *scene = nil;
    if ([kDelegate respondsToSelector:@selector(sceneForOffer:)]) {
        scene = [kDelegate sceneForOffer:model];
    }

    NSMutableDictionary *trackerExtra = [NSMutableDictionary new];
    [trackerExtra setValue:lifeCircleID ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
    [trackerExtra setValue:scene forKey:kATOfferTrackerExtraScene];
    [trackerExtra addEntriesFromDictionary:model.tapInfoDict];
    [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
    [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
    if (extra) {
        [trackerExtra addEntriesFromDictionary:extra];
    }
    struct Turple turple = {trackerExtra, kDelegate, lifeCircleID};
    return turple;
}

@end
