//
//  ATADXRewardedVideoManager.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXRewardedVideoAdManager.h"
#import "ATOfferVideoViewController.h"
#import "ATOfferFullScreenPictureViewController.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
#import "ATADXAdManager.h"
#import "ATADXLoader.h"
#import "ATADXTracker.h"

@interface ATADXRewardedVideoAdManager ()
@property (nonatomic) NSInteger currentTime;

@end

@implementation ATADXRewardedVideoAdManager

#pragma mark - init
+(instancetype) sharedManager {
    static ATADXRewardedVideoAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATADXRewardedVideoAdManager alloc] init];
    });
    return sharedManager;
}

-(void) showRewardedVideoWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel setting:(ATADXPlacementSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATADXRewardedVideoDelegate>)delegate {
   
    if([self readyForUnitGroupModel:unitGroupModel setting:setting]) {
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
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoStartPlayWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
    
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoStart offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didRewardedVideoShowOffer:)]) { [delegate didRewardedVideoShowOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(didRewardedVideoVideoStartOffer:)]) { [delegate didRewardedVideoVideoStartOffer:offerModel]; }

        [[ATADXTracker sharedTracker] preloadStorekitForOfferModel:offerModel setting:self.setting viewController:self.currentViewController circleId:lifeCircleID skDelegate:self];
        return nil;
    }];
}

-(void)offerVideoPlay25PercentWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoPlay25PercentWithOfferModel" type:ATLogTypeExternal];
    //Send 25% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideo25Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlay50PercentWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoPlay50PercentWithOfferModel" type:ATLogTypeExternal];
    //Send 50% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideo50Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlay75PercentWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoPlay75PercentWithOfferModel" type:ATLogTypeExternal];
    //Send 75% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideo75Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidEndPlayWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidEndPlayWithOfferModel" type:ATLogTypeExternal];
    //Send 100% tk
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoEnd offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didRewardedVideoVideoEndOffer:)]) { [delegate didRewardedVideoVideoEndOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(didRewardedVideoRewardOffer:)]) { [delegate didRewardedVideoRewardOffer:offerModel];
            [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoRewarded offerModel:offerModel extra:trackerExtra];
        }
        return nil;
    }];
}

-(void)offerVideoDidClickVideoWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidClickVideoWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [trackerExtra addEntriesFromDictionary:extra];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoClick offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidClickAdWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidClickAdWithOfferModel" type:ATLogTypeExternal];
   __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [trackerExtra addEntriesFromDictionary:extra];
        [[ATADXTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:weakSelf.setting extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:weakSelf viewController:weakSelf.currentViewController circleId:lifeCircleID clickCallbackHandler:^(BOOL success) {
            if ([delegate respondsToSelector:@selector(didRewardedVideoDeepLinkOrJumpResult:offer:)]) {
                [delegate didRewardedVideoDeepLinkOrJumpResult:success offer:offerModel];
            }
        }];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventClick offerModel:offerModel extra:trackerExtra];

        if ([delegate respondsToSelector:@selector(didRewardedVideoClickOffer:)]) { [delegate didRewardedVideoClickOffer:offerModel]; }
        return nil;
    }];
}

-(void)offerVideoDidVideoPausedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidVideoPausedWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoPaused offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidVideoMutedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidVideoMutedWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoMute offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidVideoUnMutedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidVideoUnMutedWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoUnMute offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidCloseWithOfferModel:(ATADXOfferModel*)offerModel extra:(NSDictionary*)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoDidCloseWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor writeWithBlock:^{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(didRewardedVideoCloseOffer:)]) { [delegate didRewardedVideoCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
    }];
}

-(void)offerVideoEndCardDidShowWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoEndCardDidShowWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventEndCardShow offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoEndCardDidCloseWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoEndCardDidCloseWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventEndCardClose offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoResumedWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoResumedWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoResumed offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoSkipWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoSkipWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoSkip offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlayFailWithOfferModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra{
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoPlayFailWithOfferModel" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [trackerExtra setValue: @(self.currentTime) forKey:kATOfferTrackerVideoTimePlayed];
        [trackerExtra setValue:@(self.currentTime * 1000) forKey:kATOfferTrackerVideoMilliTimePlayed];
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventVideoPlayFail offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

- (void)offerVideoPlayTime:(NSInteger)second offerModel:(ATADXOfferModel *)offerModel extra:(NSDictionary *)extra {
    self.currentTime = second;

    [offerModel.playingTKItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ATVideoPlayingTKItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (second == obj.triggerTime && obj.sent == NO) {
            NSDictionary *dic = @{kATOfferTrackerVideoTimePlayed: @(second),
                                  kATOfferTrackerVideoMilliTimePlayed: @(second * 1000)
            };
            [[ATADXTracker sharedTracker] trackWithUrls:obj.urls offerModel:offerModel extra:dic];
            obj.sent = YES;
            *stop = YES;
        }
    }];
}

- (void)offerVideoFeedbackViewDidSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offerModel:(ATOfferModel *)offerModel {
    [ATLogger logMessage:@"ATADXRewardedVideo::offerVideoFeedbackViewDidSelectItemAtIndex" type:ATLogTypeExternal];
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATADXRewardedVideoDelegate> delegate = [self.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        
        if ([delegate respondsToSelector:@selector(didFeedbackViewSelectItemAtIndex:extraMsg:offer:)]) {
            [delegate didRewardedVideoFeedbackViewSelectItemAtIndex:index extraMsg:msg offer:offerModel];
        }
        return nil;
    }];
}
- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

@end
