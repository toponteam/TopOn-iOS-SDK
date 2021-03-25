//
//  ATMyOfferRewardedVideoSharedDelegate.m
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/30.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferRewardedVideoSharedDelegate.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATMyOfferOfferManager.h"
#import "ATOfferVideoViewController.h"
#import "ATMyOfferTracker.h"
#import "ATMyOfferCapsManager.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
#import "ATModel.h"
@interface ATMyOfferRewardedVideoSharedDelegate()
@property(nonatomic, readonly) NSMutableDictionary<NSString*, id<ATMyOfferRewardedVideoDelegate>> *delegateStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *delegateStorageAccessor;
@property (nonatomic , strong) ATMyOfferOfferModel *offerModel;
@property (nonatomic) ATMyOfferSetting *setting;
@property (nonatomic , weak) UIViewController *currentViewController;

@end
@implementation ATMyOfferRewardedVideoSharedDelegate
+(instancetype) sharedDelegate {
    static ATMyOfferRewardedVideoSharedDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATMyOfferRewardedVideoSharedDelegate alloc] init];
    });
    return sharedDelegate;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _delegateStorage = [NSMutableDictionary<NSString*, id<ATMyOfferRewardedVideoDelegate>> dictionary];
        _delegateStorageAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

-(void) showRewardedVideoWithOfferModel:(ATMyOfferOfferModel *)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferRewardedVideoDelegate>)delegate {
    if ([[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
        if ([[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.videoURL] != nil) {
            _offerModel = offerModel;
            _setting = setting;
            __weak typeof(self) weakSelf = self;
            [_delegateStorageAccessor writeWithBlock:^{
                [weakSelf.delegateStorage AT_setWeakObject:delegate forKey:offerModel.offerID];
                dispatch_async(dispatch_get_main_queue(), ^{
                    ATOfferVideoViewController *videoViewController = [[ATOfferVideoViewController alloc] initWithOfferModel:offerModel rewardedVideoSetting:setting];
                    self->_currentViewController = videoViewController;
                    videoViewController.delegate = self;
                    videoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [viewController presentViewController:videoViewController animated:YES completion:nil];
                    
                });
            }];
            
            [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
            [[ATMyOfferCapsManager shareManager] increaseCapForOfferModel:offerModel];
            if ([[ATMyOfferCapsManager shareManager] validateCapsForOfferModel:offerModel]) {
                [[ATPlacementSettingManager sharedManager] removeCappedMyOfferID:offerModel.offerID];
            } else {
                [[ATPlacementSettingManager sharedManager] addCappedMyOfferID:offerModel.offerID];
            }
        } else {
            if ([delegate respondsToSelector:@selector(myOfferRewardedVideoFailToShowOffer:error:)]) { [delegate myOfferRewardedVideoFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.MyOfferRewardedVideoShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to show rewarded video", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Rewarded video's not ready for video URL:%@", offerModel.videoURL]}]]; }
        }
    } else {
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoFailToShowOffer:error:)]) { [delegate myOfferRewardedVideoFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.MyOfferRewardedVideoShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to show rewarded video", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Rewarded video's not ready for offerID:%@", offerModel.offerID]}]]; }
    }
}

- (void)offerVideoPlayTime:(NSInteger)second offerModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra {
    
}

- (void)offerVideoStartPlayWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoStartPlayWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] impressionOfferWithOfferModel:offerModel extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideoStart offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoShowOffer:)]) { [delegate myOfferRewardedVideoShowOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoVideoStartOffer:)]) { [delegate myOfferRewardedVideoVideoStartOffer:offerModel]; }
        
        [[ATMyOfferTracker sharedTracker] preloadStorekitForOfferModel:_offerModel setting:_setting viewController:_currentViewController circleId:lifeCircleID skDelegate:self];
        
        return nil;
    }];
}

-(void)offerVideoPlay25PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoPlay25PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 25% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideo25Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlay50PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoPlay50PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 50% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideo50Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlay75PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoPlay75PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 75% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideo75Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidEndPlayWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoDidEndPlayWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 100% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideoEnd offerModel:offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoVideoEndOffer:)]) { [delegate myOfferRewardedVideoVideoEndOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoRewardOffer:)]) { [delegate myOfferRewardedVideoRewardOffer:offerModel]; }
        return nil;
    }];
}

-(void)offerVideoDidClickVideoWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoDidClickVideoWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
   
}

-(void)offerVideoDidClickAdWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::offerVideoDidClickAdWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        
        BOOL openStorekit = weakSelf.setting.storekitTime != ATATLoadStorekitTimeNone;
        [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:weakSelf.setting extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:_currentViewController circleId:lifeCircleID];
        
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventClick offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoClickOffer:)]) { [delegate myOfferRewardedVideoClickOffer:offerModel]; }
        return nil;
    }];
}
-(void)offerVideoDidVideoPausedWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::offerVideoDidVideoPausedWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
}
-(void)offerVideoDidVideoMutedWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::offerVideoDidVideoMutedWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
}
-(void)offerVideoDidVideoUnMutedWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::offerVideoDidVideoUnMutedWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
}


-(void)offerVideoDidCloseWithOfferModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor writeWithBlock:^{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoCloseOffer:)]) { [delegate myOfferRewardedVideoCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
    }];
}

-(void)offerVideoEndCardDidShowWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoEndCardDidShowWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventEndCardShow offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoEndCardDidCloseWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoEndCardDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventEndCardClose offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

- (void)offerVideoFeedbackViewDidSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offerModel:(ATOfferModel *)offerModel{
    [ATLogger logMessage:@"MyOfferRewardedVideo::offerVideoFeedbackViewDidSelectItemAtIndex:" type:ATLogTypeExternal];
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [self.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoFeedbackViewDidSelectItemAtIndex:extraMsg:offer:)]) {
            [delegate myOfferRewardedVideoFeedbackViewDidSelectItemAtIndex:index extraMsg:msg offer:offerModel];
        }
        return nil;
    }];
}
- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
    
   //TODO something when storeit is close
    
}

@end

