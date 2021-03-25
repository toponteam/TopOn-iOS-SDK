//
//  ATOnlineApiRewardedVideoManager.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiRewardedVideoManager.h"
#import "ATUnitGroupModel.h"
#import "ATOnlineApiRewardedVideoDelegate.h"
#import "ATOnlineApiLoader.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATThreadSafeAccessor.h"
#import "NSDictionary+KAKit.h"
#import "ATOnlineApiOfferModel.h"
#import "ATOnlineApiTracker.h"
#import "ATOfferVideoViewController.h"
#import "ATLogger.h"
#import "NSString+KAKit.h"
#import "ATOfferResourceManager.h"

static NSString *kVideoDataDownloadedKeyForRuiShi = @"vd_succ";
static NSString *kVideoRewardedKeyForWangMai = @"vrewarded";
static NSString *kVideoPlayingTrackingUrlsKeyForRuiShi = @"v_p_tracking";

struct Turple {
    NSDictionary * data;
    id<ATOnlineApiRewardedVideoDelegate> delegate;
    NSString *circleID;
};

@interface ATOnlineApiRewardedVideoManager ()<SKStoreProductViewControllerDelegate, ATOfferVideoDelegate>
@property (nonatomic) NSInteger currentTime;

@end
@implementation ATOnlineApiRewardedVideoManager

// MARK:- initialization

+ (instancetype)sharedManager {
    static ATOnlineApiRewardedVideoManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATOnlineApiRewardedVideoManager alloc] init];
    });
    return sharedManager;
}

// MARK:- functions claimed in .h
- (void)showRewardedVideoWithUnitGroupModelID:(NSString *)uid setting:(ATOnlineApiPlacementSetting *)setting viewController:(UIViewController *)viewController delegate:(id<ATOnlineApiRewardedVideoDelegate >)delegate {
    
    ATOnlineApiOfferModel *model = [self readyOnlineApiAdWithUnitGroupModelID:uid placementSetting:setting];
    if (model == nil) {
        NSError *err = [NSError errorWithDomain:@"com.anythink.ADXInterstitialShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"TopOn OnlineApi has failed to show rv", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"rv's not ready for adsourceId:%@", uid]}];
        if ([delegate respondsToSelector:@selector(didRewardedVideoFailToShowOffer:error:)]) {
            [delegate didRewardedVideoFailToShowOffer:self.model error:err];
        }
        return;
    }

    //to do
    self.setting = setting;
    self.model = model;
    [self.delegateStorageAccessor writeWithBlock:^{
        
        [self.delegateStorage AT_setWeakObject:delegate forKey:self.model.offerID];
        
        AsyncInMain(^{
            [self presentVideoVCBy:viewController];
        })
    }];
    
    [[ATOnlineApiLoader sharedLoader] removeOfferModel:self.model];
    [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:self.model.localResourceID];
}

// MARK:- ATOfferVideoDelegate
- (void)offerVideoStartPlayWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoStartPlayWithOfferModel" type:ATLogTypeExternal];
    [self.delegateStorageAccessor readWithBlock:^id{
        [self handleStartPlay:offerModel];
        return nil;
    }];
}

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

- (void)offerVideoPlay25PercentWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoPlay25PercentWithOfferModel" type:ATLogTypeExternal];
    
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideo25Percent model:offerModel];
    
}

- (void)offerVideoPlay50PercentWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoPlay50PercentWithOfferModel" type:ATLogTypeExternal];
    
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideo50Percent model:offerModel];
}

- (void)offerVideoPlay75PercentWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoPlay75PercentWithOfferModel" type:ATLogTypeExternal];
    
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideo75Percent model:offerModel];
}

- (void)offerVideoDidEndPlayWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoDidEndPlayWithOfferModel" type:ATLogTypeExternal];
    
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoEnd model:offerModel];
    
}

- (void)offerVideoDidClickVideoWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoDidClickVideoWithOfferModel" type:ATLogTypeExternal];

    [self.delegateStorageAccessor readWithBlock:^id{
        struct Turple turple = [self generateDataForTK:offerModel extra:extra];
//        NSMutableDictionary *_extra = turple.data.mutableCopy;
//        id pointValue = extra[@"point"];
//        if (pointValue) {
//            CGPoint point = [pointValue CGPointValue];
//            NSDictionary *dic = @{kATOfferTrackerGDTDownX: @(point.x),
//                                  kATOfferTrackerGDTDownY: @(point.y),
//                                  kATOfferTrackerGDTUpX:   @(point.x),
//                                  kATOfferTrackerGDTUpY:   @(point.y),
//                                  kATOfferTrackerGDTWidth: @([UIScreen mainScreen].nativeScale * [UIScreen mainScreen].bounds.size.width),
//                                  kATOfferTrackerGDTHeight:@([UIScreen mainScreen].nativeScale * [UIScreen mainScreen].bounds.size.height),
//                                  kATOfferTrackerGDTRequestWidth: @([UIScreen mainScreen].nativeScale * [[UIScreen mainScreen]bounds].size.width),
//                                  kATOfferTrackerGDTRequestHeight:@([UIScreen mainScreen].nativeScale * [[UIScreen mainScreen]bounds].size.height)
//            };
//            [_extra addEntriesFromDictionary:dic];
//        }
                
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventVideoClick offerModel:offerModel extra:turple.data];

        return nil;
    }];
}

- (void)offerVideoDidClickAdWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoDidClickAdWithOfferModel" type:ATLogTypeExternal];

    [self.delegateStorageAccessor readWithBlock:^id{
        [self handleClickAdWithModel:offerModel extra:extra];
        return nil;
    }];
    
}

- (void)offerVideoDidVideoPausedWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoDidVideoPausedWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoPaused model:offerModel];
}

- (void)offerVideoDidVideoMutedWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoDidVideoMutedWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoMute model:offerModel];
}

- (void)offerVideoDidVideoUnMutedWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoDidVideoUnMutedWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoUnMute model:offerModel];
}

- (void)offerVideoDidCloseWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoDidCloseWithOfferModel" type:ATLogTypeExternal];
    
    [self.delegateStorageAccessor writeWithBlock:^{
        id<ATOnlineApiRewardedVideoDelegate> delegate = [self.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        
        if ([delegate respondsToSelector:@selector(didRewardedVideoCloseOffer:)]) {
            [delegate didRewardedVideoCloseOffer:offerModel];
        }
        [self.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
    }];
}

- (void)offerVideoEndCardDidShowWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoEndCardDidShowWithOfferModel" type:ATLogTypeExternal];
    
    [self sendTrackerEvent:ATOnlineApiTrackerEventEndCardShow model:offerModel];

}

- (void)offerVideoEndCardDidCloseWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoEndCardDidCloseWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventEndCardClose model:offerModel];
}

-(void)offerVideoResumedWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoResumedWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoResumed model:offerModel];
}

-(void)offerVideoSkipWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoSkipWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoSkip model:offerModel];
}

-(void)offerVideoPlayFailWithOfferModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra{
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoPlayFailWithOfferModel" type:ATLogTypeExternal];
    [self sendTrackerEvent:ATOnlineApiTrackerEventVideoPlayFail model:offerModel];
}

- (void)offerVideoFeedbackViewDidSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offerModel:(ATOfferModel *)offerModel {
    [ATLogger logMessage:@"ATOnlineApiRewardedVideo::offerVideoFeedbackViewDidSelectItemAtIndex" type:ATLogTypeExternal];
    [self.delegateStorageAccessor readWithBlock:^id{
        id<ATOnlineApiRewardedVideoDelegate> delegate = [self.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        
        if ([delegate respondsToSelector:@selector(didFeedbackViewSelectItemAtIndex:extraMsg:offer:)]) {
            [delegate didRewardedVideoFeedbackViewSelectItemAtIndex:index extraMsg:msg offer:offerModel];
        }
        return nil;
    }];
}
// MARK:- SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
}

// MARK:- private method

- (void)sendTrackerEvent:(ATOnlineApiTrackerEvent)event model:(ATOnlineApiOfferModel *)model {
    
    [self.delegateStorageAccessor readWithBlock:^id{
        struct Turple turple = [self generateDataForTK:model extra:nil];
        [[ATOnlineApiTracker sharedTracker] trackEvent:event offerModel:model extra:turple.data];
        
        if (event == ATOnlineApiTrackerEventVideoEnd) {
            if ([turple.delegate respondsToSelector:@selector(didRewardedVideoVideoEndOffer:)]) {
                [turple.delegate didRewardedVideoVideoEndOffer:model];
            }
            if ([turple.delegate respondsToSelector:@selector(didRewardedVideoRewardOffer:)]) {
                [turple.delegate didRewardedVideoRewardOffer:model];
                [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventVideoRewarded offerModel:model extra:turple.data];
            }
        }
        return nil;
    }];
}

- (void)handleClickAdWithModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra {
    struct Turple turple = [self generateDataForTK:offerModel extra:extra];

    [[ATOnlineApiTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:self.setting circleID:turple.circleID delegate:self viewController:self.currentViewController extra:turple.data clickCallbackHandler:^(BOOL success) {
        if ([turple.delegate respondsToSelector:@selector(didRewardedVideoDeepLinkOrJumpResult:offer:)]) {
            [turple.delegate didRewardedVideoDeepLinkOrJumpResult:success offer:offerModel];
        }
    }];
    
    [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventClick offerModel:offerModel extra:turple.data];
    
    if ([turple.delegate respondsToSelector:@selector(didRewardedVideoClickOffer:)]) {
        [turple.delegate didRewardedVideoClickOffer:offerModel];
    }
}

- (void)handleStartPlay:(ATOnlineApiOfferModel *)model {
    
    struct Turple turple = [self generateDataForTK:model extra:nil];
    NSDictionary *trackerExtra = turple.data;
    
    [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventImpression offerModel:model extra:trackerExtra];
    [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventVideoStart offerModel:model extra:trackerExtra];

    if ([turple.delegate respondsToSelector:@selector(didRewardedVideoShowOffer:)]) {
        [turple.delegate didRewardedVideoShowOffer:model];
    }

    if ([turple.delegate respondsToSelector:@selector(didRewardedVideoVideoStartOffer:)]) {
        [turple.delegate didRewardedVideoVideoStartOffer:model];
    }

    [[ATOnlineApiTracker sharedTracker] preloadStorekitForOfferModel:model setting:self.setting viewController:self.currentViewController circleId:turple.circleID skDelegate:self];
}

- (struct Turple)generateDataForTK:(ATOnlineApiOfferModel *)model extra:(NSDictionary *)extra {

    id<ATOnlineApiRewardedVideoDelegate> kDelegate = [self.delegateStorage AT_weakObjectForKey:model.offerID];

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

- (void)presentVideoVCBy:(UIViewController *)vc {
    ATOfferVideoViewController *videoVC = [[ATOfferVideoViewController alloc]initWithOfferModel:self.model rewardedVideoSetting:self.setting];
    self.currentViewController = videoVC;
    videoVC.delegate = self;
    videoVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [vc presentViewController:videoVC animated:YES completion:nil];
}

@end
