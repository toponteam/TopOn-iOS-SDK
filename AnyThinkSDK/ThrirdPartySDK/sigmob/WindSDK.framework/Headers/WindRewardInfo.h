//
//  WindRewardInfo.h
//  HeMobTest
//
//  Created by zhou.ding on 2017/5/3.
//  Copyright © 2017年 happyelements. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WindRewardInfo : NSObject
/**
 *  The ID of the reward as defind on Self Service
 */
@property (nonatomic, copy  ) NSString  *rewardId;

/**
 *  The reward name as defined on Self Service
 */
@property (nonatomic, copy  ) NSString  *rewardName;

/**
 *  Amount of reward type given to the user
 */
@property (nonatomic, assign) NSInteger rewardAmount;


/**
 The isCompeltedView is Tell you if you've finished watching video.
 */
@property (nonatomic,assign) BOOL isCompeltedView;

@end
