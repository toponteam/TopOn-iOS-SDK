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
#import "ATMyOfferVideoViewController.h"
#import "ATMyOfferTracker.h"
#import "ATMyOfferCapsManager.h"
#import "ATPlacementSettingManager.h"
#import "ATMyOfferResourceManager.h"
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
    if ([[ATMyOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
        if ([[ATMyOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.videoURL] != nil) {
            _offerModel = offerModel;
            _setting = setting;
            __weak typeof(self) weakSelf = self;
            [_delegateStorageAccessor writeWithBlock:^{
                [weakSelf.delegateStorage AT_setWeakObject:delegate forKey:offerModel.offerID];
                dispatch_async(dispatch_get_main_queue(), ^{
                    ATMyOfferVideoViewController *videoViewController = [[ATMyOfferVideoViewController alloc] initWithMyOfferModel:offerModel rewardedVideoSetting:setting];
                    _currentViewController = videoViewController;
                    videoViewController.delegate = self;
                    videoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [viewController presentViewController:videoViewController animated:YES completion:nil];
                    
                });
            }];
            
            [[ATMyOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
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

-(void)myOfferVideoStartPlayWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoStartPlayWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] impressionOfferWithOfferModel:offerModel extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideoStart offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoShowOffer:)]) { [delegate myOfferRewardedVideoShowOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoVideoStartOffer:)]) { [delegate myOfferRewardedVideoVideoStartOffer:offerModel]; }
        
        [[ATMyOfferTracker sharedTracker] preloadStorekitForOfferModel:_offerModel setting:_setting viewController:_currentViewController circleId:lifeCircleID skDelegate:self];
        
        return nil;
    }];
}

-(void)myOfferVideoPlay25PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoPlay25PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 25% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideo25Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)myOfferVideoPlay50PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoPlay50PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 50% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideo50Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)myOfferVideoPlay75PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoPlay75PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 75% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideo75Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)myOfferVideoDidEndPlayWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoDidEndPlayWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 100% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideoEnd offerModel:offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoVideoEndOffer:)]) { [delegate myOfferRewardedVideoVideoEndOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoRewardOffer:)]) { [delegate myOfferRewardedVideoRewardOffer:offerModel]; }
        return nil;
    }];
}

-(void)myOfferVideoDidClickVideoWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoDidClickVideoWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        
        BOOL openStorekit = _setting.storekitTime!=2;
        [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:_setting extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:_currentViewController circleId:lifeCircleID];
        
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventClick offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoClickOffer:)]) { [delegate myOfferRewardedVideoClickOffer:offerModel]; }
        return nil;
    }];
}

-(void)myOfferVideoDidCloseWithOfferModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor writeWithBlock:^{
        id<ATMyOfferRewardedVideoDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(myOfferRewardedVideoCloseOffer:)]) { [delegate myOfferRewardedVideoCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
    }];
}

-(void)myOfferVideoEndCardDidShowWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoEndCardDidShowWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventEndCardShow offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)myOfferVideoEndCardDidCloseWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferRewardedVideo::myOfferVideoEndCardDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventEndCardClose offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
    
   //TODO something when storeit is close
    
}

@end

