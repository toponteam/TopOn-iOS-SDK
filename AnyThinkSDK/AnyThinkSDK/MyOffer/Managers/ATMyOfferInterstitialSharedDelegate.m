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
#import "ATMyOfferVideoViewController.h"
#import "ATMyOfferTracker.h"
#import "ATMyOfferCapsManager.h"
#import "ATPlacementSettingManager.h"
#import "ATMyOfferResourceManager.h"
@interface ATMyOfferInterstitialSharedDelegate()
@property(nonatomic, readonly) NSMutableDictionary<NSString*, id<ATMyOfferInterstitialDelegate>> *delegateStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *delegateStorageAccessor;
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
    if ([[ATMyOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.resourceID]) {
        if ([[ATMyOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.videoURL] != nil) {
            __weak typeof(self) weakSelf = self;
            [_delegateStorageAccessor writeWithBlock:^{
                [weakSelf.delegateStorage AT_setWeakObject:delegate forKey:offerModel.offerID];
                dispatch_async(dispatch_get_main_queue(), ^{
                    ATMyOfferVideoViewController *videoViewController = [[ATMyOfferVideoViewController alloc] initWithMyOfferModel:offerModel rewardedVideoSetting:setting];
                    videoViewController.delegate = self;
                    videoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [viewController presentViewController:videoViewController animated:YES completion:nil];
                });
            }];
            [[ATMyOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.resourceID];
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
-(void)myOfferVideoStartPlayWithOfferModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary *)extra {
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
        return nil;
    }];
}

-(void)myOfferVideoPlay25PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
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

-(void)myOfferVideoPlay50PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
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

-(void)myOfferVideoPlay75PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
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

-(void)myOfferVideoDidEndPlayWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
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

-(void)myOfferVideoDidClickVideoWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoDidClickVideoWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:offerModel] : @"";
        NSString *scene = [delegate respondsToSelector:@selector(sceneForOffer:)] ? [delegate sceneForOffer:offerModel] : nil;
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        if (scene != nil) { trackerExtra[kATMyOfferTrackerExtraScene] = scene; }
        [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:offerModel extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventClick offerModel:offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferInterstitialClickOffer:)]) { [delegate myOfferInterstitialClickOffer:offerModel]; }
        return nil;
    }];
}

-(void)myOfferVideoDidCloseWithOfferModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra {
    [ATLogger logMessage:@"MyOfferInterstitial::myOfferVideoDidCloseWithOfferModel:%@ extra:%@" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor writeWithBlock:^{
        id<ATMyOfferInterstitialDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(myOfferInterstitialCloseOffer:)]) { [delegate myOfferInterstitialCloseOffer:offerModel]; }
        [weakSelf.delegateStorage AT_removeWeakObjectForKey:offerModel.offerID];
    }];
}

-(void)myOfferVideoEndCardDidShowWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
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

-(void)myOfferVideoEndCardDidCloseWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra {
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
@end
