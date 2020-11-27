//
//  ATADXRewardedVideoManager.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXAdManager+RewardedVideo.h"
#import "ATOfferVideoViewController.h"
#import "ATOfferFullScreenPictureViewController.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
#import "ATADXAdManager.h"
#import "ATADXLoader.h"
#import "ATADXTracker.h"

@implementation  ATADXAdManager(RewardedVideo)

-(void) showRewardedVideoWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel setting:(ATADXPlacementSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATADXRewardedVideoDelegate>)delegate {
   
    if([[ATADXAdManager sharedManager] readyForUnitGroupModel:unitGroupModel setting:setting]) {
        self.offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:setting.placementID unitGroupModel:unitGroupModel];
        self.setting = self.offerModel.adxSetting!=nil?self.offerModel.adxSetting:setting;
        __weak typeof(self) weakSelf = self;
        [self.delegateStorageAccessor writeWithBlock:^{
            [weakSelf.delegateStorage AT_setWeakObject:delegate forKey:self.offerModel.offerID];
            dispatch_async(dispatch_get_main_queue(), ^{
                ATOfferVideoViewController *videoViewController = [[ATOfferVideoViewController alloc] initWithOfferModel:self.offerModel rewardedVideoSetting:self.setting];
                weakSelf.currentViewController = videoViewController;
                videoViewController.delegate = self;
                videoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                [viewController presentViewController:videoViewController animated:YES completion:nil];
            });
        }];
        [[ATADXLoader sharedLoader] removeOfferModel:self.offerModel];
        [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:self.offerModel.localResourceID];
      
    }else {
        if ([delegate respondsToSelector:@selector(didRewardedVideoFailToShowOffer:error:)]) { [delegate didRewardedVideoFailToShowOffer:self.offerModel error:[NSError errorWithDomain:@"com.anythink.ADXInterstitialShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"TopOn ADX has failed to show interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Interstitial's not ready for adsourceId:%@", self.offerModel.unitID]}]]; }
    }
    
}

#pragma mark - video delegate
-(void)offerVideoStartPlayWithOfferModel:(ATADXOfferModel*)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoStartPlayWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoStart offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didRewardedVideoShowOffer:)]) { [delegate didRewardedVideoShowOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(didRewardedVideoVideoStartOffer:)]) { [delegate didRewardedVideoVideoStartOffer:offerModel]; }

        [[ATADXTracker sharedTracker] preloadStorekitForOfferModel:offerModel setting:self.setting viewController:self.currentViewController circleId:lifeCircleID skDelegate:self];
        return nil;
    }];
}

-(void)offerVideoPlay25PercentWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoPlay25PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 25% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideo25Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlay50PercentWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoPlay50PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 50% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideo50Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlay75PercentWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoPlay75PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 75% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideo75Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidEndPlayWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidEndPlayWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 100% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoEnd offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didRewardedVideoVideoEndOffer:)]) { [delegate didRewardedVideoVideoEndOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(didRewardedVideoRewardOffer:)]) { [delegate didRewardedVideoRewardOffer:offerModel]; }
        return nil;
    }];
}

-(void)offerVideoDidClickVideoWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidClickVideoWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }

        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoClick offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didRewardedVideoClickOffer:)]) { [delegate didRewardedVideoClickOffer:offerModel]; }
        return nil;
    }];
}

-(void)offerVideoDidClickAdWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidClickAdWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
   __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }

        [[ATADXTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:weakSelf.setting extra:@{kATADXTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:weakSelf viewController:weakSelf.currentViewController circleId:lifeCircleID];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventClick offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didRewardedVideoClickOffer:)]) { [delegate didRewardedVideoClickOffer:offerModel]; }
        return nil;
    }];
}

-(void)offerVideoDidVideoPausedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidVideoPausedWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoPaused offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidVideoMutedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidVideoMutedWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoMute offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidVideoUnMutedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidVideoUnMutedWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoUnMute offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidCloseWithOfferModel:(ATADXOfferModel*)offerModel extra:(NSDictionary*)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor writeWithBlock:^{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(didRewardedVideoCloseOffer:)]) { [delegate didRewardedVideoCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
    }];
}

-(void)offerVideoEndCardDidShowWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoEndCardDidShowWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventEndCardShow offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoEndCardDidCloseWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoEndCardDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventEndCardClose offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

@end
