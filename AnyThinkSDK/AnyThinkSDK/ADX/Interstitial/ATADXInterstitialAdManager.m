//
//  ATADXInterstitialManager.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXInterstitialAdManager.h"
#import "ATOfferVideoViewController.h"
#import "ATOfferFullScreenPictureViewController.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
#import "ATADXAdManager.h"
#import "ATADXLoader.h"
#import "ATADXTracker.h"

@implementation ATADXInterstitialAdManager

#pragma mark - init
+(instancetype) sharedManager {
    static ATADXInterstitialAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATADXInterstitialAdManager alloc] init];
    });
    return sharedManager;
}


-(void) showInterstitialWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel setting:(ATADXPlacementSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATADXInterstitialDelegate>)delegate {

    if([self readyForUnitGroupModel:unitGroupModel setting:setting]) {
        self.offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:setting.placementID unitGroupModel:unitGroupModel];
        self.setting = self.offerModel.adxSetting!=nil?self.offerModel.adxSetting:setting;
        __weak typeof(self) weakSelf = self;
        [self.delegateStorageAccessor writeWithBlock:^{
            [weakSelf.delegateStorage AT_setWeakObject:delegate forKey:self.offerModel.offerID];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.offerModel.interstitalType == ATInterstitialVideo || self.offerModel.videoURL.length > 0) {
                    ATOfferVideoViewController *videoViewController = [[ATOfferVideoViewController alloc] initWithOfferModel:self.offerModel rewardedVideoSetting:self.setting];
                    weakSelf.currentViewController = videoViewController;
                    videoViewController.delegate = self;
                    videoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [viewController presentViewController:videoViewController animated:YES completion:nil];
                }else {
                    ATOfferFullScreenPictureViewController *videoViewController = [[ATOfferFullScreenPictureViewController alloc] initWithOfferModel:self.offerModel rewardedVideoSetting:self.setting];
                    weakSelf.currentViewController = videoViewController;
                    videoViewController.delegate = self;
                    videoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [viewController presentViewController:videoViewController animated:YES completion:nil];
                }
            });
        }];
        [[ATADXLoader sharedLoader] removeOfferModel:self.offerModel];
        [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:self.offerModel.localResourceID];
      
    }else {
        if ([delegate respondsToSelector:@selector(didInterstitialFailToShowOffer:error:)]) { [delegate didInterstitialFailToShowOffer:self.offerModel error:[NSError errorWithDomain:@"com.anythink.ADXInterstitialShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"TopOn ADX has failed to show interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Interstitial's not ready for adsourceId:%@", self.offerModel.unitID]}]]; }
    }
    
}

#pragma mark - video delegate
-(void)offerVideoStartPlayWithOfferModel:(ATADXOfferModel*)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoStartPlayWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoStart offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didInterstitialShowOffer:)]) { [delegate didInterstitialShowOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(didInterstitialVideoStartOffer:)]) { [delegate didInterstitialVideoStartOffer:offerModel]; }

        [[ATADXTracker sharedTracker] preloadStorekitForOfferModel:self.offerModel setting:self.setting viewController:self.currentViewController circleId:lifeCircleID skDelegate:self];

        return nil;
    }];
}

-(void)offerVideoPlay25PercentWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoPlay25PercentWithOfferModel" type:ATLogTypeExternal];
    //Send 25% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideo25Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlay50PercentWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoPlay50PercentWithOfferModel" type:ATLogTypeExternal];
    //Send 50% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideo50Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlay75PercentWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoPlay75PercentWithOfferModel" type:ATLogTypeExternal];
    //Send 75% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideo75Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidEndPlayWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoDidEndPlayWithOfferModel" type:ATLogTypeExternal];
    //Send 100% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoEnd offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didInterstitialVideoEndOffer:)]) { [delegate didInterstitialVideoEndOffer:offerModel]; }
        return nil;
    }];
}

-(void)offerVideoDidClickVideoWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoDidClickVideoWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }

        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoClick offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidClickAdWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoDidClickAdWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
      id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
      NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
      NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
      NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
      if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }

        [[ATADXTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:self.setting extra:@{kATADXTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:self.currentViewController circleId:lifeCircleID];
      [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventClick offerModel:offerModel extra:trackerExtra];

      if ([delegate respondsToSelector:@selector(didInterstitialClickOffer:)]) { [delegate didInterstitialClickOffer:offerModel]; }
      return nil;
    }];
}

-(void)offerVideoDidVideoPausedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoDidVideoPausedWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoPaused offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidVideoMutedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoDidVideoMutedWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoMute offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidVideoUnMutedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoDidVideoUnMutedWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoUnMute offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}


-(void)offerVideoDidCloseWithOfferModel:(ATADXOfferModel*)offerModel extra:(NSDictionary*)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoDidCloseWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor writeWithBlock:^{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(didInterstitialCloseOffer:)]) { [delegate didInterstitialCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
    }];
}

-(void)offerVideoEndCardDidShowWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoEndCardDidShowWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventEndCardShow offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoEndCardDidCloseWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerVideoEndCardDidCloseWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
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

-(void)offerFullScreenPictureEndCardDidShowWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerFullScreenPictureEndCardDidShowWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        [[ATADXTracker sharedTracker] impressionOfferWithOfferModel:offerModel extra:@{kATADXTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventImpression offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didInterstitialShowOffer:)]) { [delegate didInterstitialShowOffer:offerModel]; }

        [[ATADXTracker sharedTracker] preloadStorekitForOfferModel:weakSelf.offerModel setting:weakSelf.setting viewController:weakSelf.currentViewController circleId:lifeCircleID skDelegate:self];

        return nil;
    }];
}

-(void)offerFullScreenPictureDidClickAdWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerFullScreenPictureDidClickAdWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:weakSelf.setting extra:@{kATADXTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:weakSelf.currentViewController circleId:lifeCircleID];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventClick offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didInterstitialClickOffer:)]) { [delegate didInterstitialClickOffer:offerModel]; }
        return nil;
    }];
}

-(void)offerFullScreenPictureEndCardDidCloseWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXInterstitial::offerFullScreenPictureEndCardDidCloseWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATADXTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATADXTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventEndCardClose offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didInterstitialCloseOffer:)]) { [delegate didInterstitialCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
        return nil;
    }];
}

@end
