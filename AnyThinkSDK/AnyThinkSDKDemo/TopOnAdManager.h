//
//  TopOnAdManager.h
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2020/1/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopOnAdManager : NSObject
+(instancetype) sharedManager;
-(BOOL) rewardedVideoReadyForPlacementID:(NSString*)placementID;
-(void) loadRewardedVideoForPlacementID:(NSString*)placementID;
-(void) showRewardedVideoForPlacementID:(NSString*)placementID inViewController:(UIViewController*)viewController;
@end

NS_ASSUME_NONNULL_END
