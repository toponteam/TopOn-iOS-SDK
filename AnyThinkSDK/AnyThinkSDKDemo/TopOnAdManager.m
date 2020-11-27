//
//  TopOnAdManager.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2020/1/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "TopOnAdManager.h"
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
@interface TopOnAdManager()<ATRewardedVideoDelegate>
@end
@implementation TopOnAdManager
+(instancetype) sharedManager {
    static TopOnAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TopOnAdManager alloc] init];
        
    });
    return sharedManager;
}

-(BOOL) rewardedVideoReadyForPlacementID:(NSString*)placementID {
    return [[ATAdManager sharedManager] rewardedVideoReadyForPlacementID:placementID];
}

-(void) loadRewardedVideoForPlacementID:(NSString*)placementID {
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:@{kATAdLoadingExtraUserIDKey:[[[UIDevice currentDevice] identifierForVendor] UUIDString] != nil ? [[[UIDevice currentDevice] identifierForVendor] UUIDString] : @""} delegate:self];
}

-(void) showRewardedVideoForPlacementID:(NSString*)placementID inViewController:(UIViewController*)viewController {
    [[ATAdManager sharedManager] showRewardedVideoWithPlacementID:placementID inViewController:viewController delegate:self];
}

-(void) didFinishLoadingADWithPlacementID:(NSString *)placementID {
    NSLog(@"TopOnAdManager::didFinishLoadingADWithPlacementID");
    
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID error:(NSError*)error {
    NSLog(@"TopOnAdManager::didFailToLoadADWithPlacementID:%@ error:%@", placementID, error);
}
#pragma mark - showing delegate
-(void) rewardedVideoDidRewardSuccessForPlacemenID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSLog(@"TopOnAdManager::rewardedVideoDidRewardSuccessForPlacemenID:%@ extra:%@",placementID,extra);
}

-(void) rewardedVideoDidStartPlayingForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"TopOnAdManager::rewardedVideoDidStartPlayingForPlacementID:%@ extra:%@", placementID, extra);
   
}


-(void) rewardedVideoDidEndPlayingForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra {
    NSLog(@"TopOnAdManager::rewardedVideoDidEndPlayingForPlacementID:%@ extra:%@", placementID, extra);
}

-(void) rewardedVideoDidFailToPlayForPlacementID:(NSString*)placementID error:(NSError*)error extra:(NSDictionary *)extra {
    NSLog(@"TopOnAdManager::rewardedVideoDidFailToPlayForPlacementID:%@ error:%@ extra:%@", placementID, error, extra);
}

-(void) rewardedVideoDidCloseForPlacementID:(NSString*)placementID rewarded:(BOOL)rewarded extra:(NSDictionary *)extra {
    NSLog(@"TopOnAdManager::rewardedVideoDidCloseForPlacementID:%@, rewarded:%@ extra:%@", placementID, rewarded ? @"yes" : @"no", extra);
}


-(void) rewardedVideoDidClickForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra {
    NSLog(@"TopOnAdManager::rewardedVideoDidClickForPlacementID:%@ extra:%@", placementID, extra);
}
@end
