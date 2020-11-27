//
//  ATMyOfferInterstitialSharedDelegate.m
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/30.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferInterstitialSharedDelegate.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATMyOfferOfferManager.h"
#import "ATOfferVideoViewController.h"
#import "ATOfferFullScreenPictureViewController.h"
#import "ATMyOfferTracker.h"
#import "ATMyOfferCapsManager.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
@interface ATMyOfferInterstitialSharedDelegate()
@property(nonatomic, readonly) NSMutableDictionary<NSString*, id<ATMyOfferInterstitialDelegate>> *delegateStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *delegateStorageAccessor;

@property (nonatomic , strong) ATMyOfferOfferModel *offerModel;
@property (nonatomic) ATMyOfferSetting *setting;
@property (nonatomic , weak) UIViewController *currentViewController;

@end

@implementation ATMyOfferInterstitialSharedDelegate
+(instancetype) sharedDelegate {
    static ATMyOfferInterstitialSharedDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATMyOfferInterstitialSharedDelegate alloc] init];
    });
    return sharedDelegate;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _delegateStorage = [NSMutableDictionary<NSString*, id<ATMyOfferInterstitialDelegate>> dictionary];
        _delegateStorageAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

-(void) showInterstitialWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferInterstitialDelegate>)delegate {
    if ([[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
        if ([[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.fullScreenImageURL] != nil) {
            _offerModel = offerModel;
            _setting = setting;
            __weak typeof(self) weakSelf = self;
            [_delegateStorageAccessor writeWithBlock:^{
                [weakSelf.delegateStorage AT_setWeakObject:delegate forKey:offerModel.offerID];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (offerModel.interstitalType == ATInterstitialVideo) {
                        ATOfferVideoViewController *videoViewController = [[ATOfferVideoViewController alloc] initWithOfferModel:offerModel rewardedVideoSetting:setting];
                        weakSelf.currentViewController = videoViewController;
                        videoViewController.delegate = self;
                        videoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                        [viewController presentViewController:videoViewController animated:YES completion:nil];
                    }else {
                        ATOfferFullScreenPictureViewController *videoViewController = [[ATOfferFullScreenPictureViewController alloc] initWithOfferModel:offerModel rewardedVideoSetting:setting];
                        weakSelf.currentViewController = videoViewController;
                        videoViewController.delegate = self;
                        videoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                        [viewController presentViewController:videoViewController animated:YES completion:nil];
                    }
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
            if ([delegate respondsToSelector:@selector(myOfferIntersititalFailToShowOffer:error:)]) { [delegate myOfferIntersititalFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.MyOfferInterstitialShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to show interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Interstitial's not ready for video URL:%@", offerModel.videoURL]}]]; }
        }
    } else {
        if ([delegate respondsToSelector:@selector(myOfferIntersititalFailToShowOffer:error:)]) { [delegate myOfferIntersititalFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.MyOfferInterstitialShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to show interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Interstitial's not ready for offerID:%@", offerModel.offerID]}]]; }
    }
}

#pragma mark - video delegate
-(void)offerVideoStartPlayWithOfferModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoStartPlayWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        [[ATMyOfferTracker sharedTracker] impressionOfferWithOfferModel:offerModel extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideoStart offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferIntersititalShowOffer:)]) { [delegate myOfferIntersititalShowOffer:offerModel]; }
        if ([delegate respondsToSelector:@selector(myOfferInterstitialVideoStartOffer:)]) { [delegate myOfferInterstitialVideoStartOffer:offerModel]; }
        
        [[ATMyOfferTracker sharedTracker] preloadStorekitForOfferModel:self->_offerModel setting:_setting viewController:_currentViewController circleId:lifeCircleID skDelegate:self];
        
        return nil;
    }];
}

-(void)offerVideoPlay25PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoPlay25PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 25% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideo25Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoPlay50PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoPlay50PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 50% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideo50Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
    
}

-(void)offerVideoPlay75PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoPlay75PercentWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 75% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideo75Percent offerModel:offerModel extra:trackerExtra];
        return nil;
    }];
}

-(void)offerVideoDidEndPlayWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoDidEndPlayWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    //Send 100% tk
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventVideoEnd offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferInterstitialVideoEndOffer:)]) { [delegate myOfferInterstitialVideoEndOffer:offerModel]; }
        return nil;
    }];
}

-(void)offerVideoDidClickVideoWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoDidClickVideoWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
   
}

-(void)offerVideoDidClickAdWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::offerVideoDidClickAdWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
   __weak typeof(self) weakSelf = self;
      [_delegateStorageAccessor readWithBlock:^id{
          id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
          NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
          NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
          NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
          if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
         
          [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:_setting extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:_currentViewController circleId:lifeCircleID];
          [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventClick offerModel:offerModel extra:trackerExtra];
          
          if ([delegate respondsToSelector:@selector(myOfferInterstitialClickOffer:)]) { [delegate myOfferInterstitialClickOffer:offerModel]; }
          return nil;
      }];
}
-(void)offerVideoDidVideoPausedWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::offerVideoDidVideoPausedWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
}
-(void)offerVideoDidVideoMutedWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::offerVideoDidVideoMutedWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
}
-(void)offerVideoDidVideoUnMutedWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::offerVideoDidVideoUnMutedWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
}


-(void)offerVideoDidCloseWithOfferModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor writeWithBlock:^{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(myOfferInterstitialCloseOffer:)]) { [delegate myOfferInterstitialCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
    }];
}

-(void)offerVideoEndCardDidShowWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoEndCardDidShowWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
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

-(void)offerVideoEndCardDidCloseWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoEndCardDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
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
   //TODO something when storekit is close
}

-(void)offerFullScreenPictureEndCardDidShowWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferFullScreenPictureEndCardDidShowWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        [[ATMyOfferTracker sharedTracker] impressionOfferWithOfferModel:offerModel extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventImpression offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferIntersititalShowOffer:)]) { [delegate myOfferIntersititalShowOffer:offerModel]; }
        
        [[ATMyOfferTracker sharedTracker] preloadStorekitForOfferModel:weakSelf.offerModel setting:weakSelf.setting viewController:weakSelf.currentViewController circleId:lifeCircleID skDelegate:self];
        
        return nil;
    }];
}

-(void)offerFullScreenPictureDidClickAdWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::offerFullScreenPictureDidClickAdWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:weakSelf.setting extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:weakSelf.currentViewController circleId:lifeCircleID];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventClick offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferInterstitialClickOffer:)]) { [delegate myOfferInterstitialClickOffer:offerModel]; }
        return nil;
    }];
}

-(void)offerFullScreenPictureEndCardDidCloseWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferFullScreenPictureEndCardDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventEndCardClose offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferInterstitialCloseOffer:)]) { [delegate myOfferInterstitialCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
        return nil;
    }];
}

@end
