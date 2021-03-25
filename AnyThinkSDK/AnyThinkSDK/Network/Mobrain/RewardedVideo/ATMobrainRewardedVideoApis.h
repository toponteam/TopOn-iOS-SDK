//
//  ATMobrainRewardedVideoApis.h
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ATMobrainBaseManager.h"

#ifndef ATMobrainRewardedVideoApis_h
#define ATMobrainRewardedVideoApis_h

@protocol ABURewardedVideoAdDelegate <NSObject>

@end

@protocol ATABURewardedVideoModel <NSObject>

/**
   required.
   Third-party game user_id identity.
   Mainly used in the reward issuance, it is the callback pass-through parameter from server-to-server.
   It is the unique identifier of each user.
   In the non-server callback mode, it will also be pass-through when the video is finished playing.
   Only the string can be passed in this case, not nil.
 */
@property (nonatomic, copy) NSString * _Nonnull userId;

//optional. reward name.
@property (nonatomic, copy) NSString * _Nullable rewardName;

//optional. number of rewards.
@property (nonatomic, assign) NSInteger rewardAmount;

//optional. serialized string.
@property (nonatomic, copy) NSString * _Nullable extra;


@end

@protocol ATABURewardedVideoAd <NSObject>

@property (nonatomic, strong) id<ATABURewardedVideoModel> rewardedVideoModel;
@property (nonatomic, weak, nullable) id<ABURewardedVideoAdDelegate> delegate;

/**
 返回广告是否可用
 Whether material is effective.
 Setted to YES when data is not empty and has not been displayed.
 Repeated display is not billed.Only check when you call API "show".
 */
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;


/**
 Required
 Get a express Ad if SDK can.Default is NO.
 必须设置且只对支持模板广告的第三方SDK有效,默认为NO.
 */
@property (nonatomic, assign, readwrite) BOOL getExpressAdIfCan;

/**
 Is a express Ad
 返回是否为模板广告，一般如果有返回值在收到visiable方法可用
 Generally if there is a return value available in the receive method "AdDidVisible"
 */
@property (nonatomic, assign, readonly) BOOL hasExpressAdGot;

/**
返回是否包含点击回调,hasClickCallback == YES时，才会有rewardedVideoAdDidClick回调； 在收到rewardedVideoAdDidVisible回调后有效
*/
@property (nonatomic, assign,readonly) BOOL hasClickCallback;


/// Configure whether the request is successful
@property (nonatomic, assign, readonly) BOOL hasAdConfig;

/*
Initializes reward video ad.
@param adUnitID : The unique identifier of reward ad.
@param model : The model of reward ad for pangle Ads.
 */
- (instancetype _Nonnull )initWithAdUnitID:(NSString *_Nonnull)adUnitID rewardedVideoModel:(_Nullable id<ATABURewardedVideoModel>)model;

- (void)loadAdData;


- (void)setConfigSuccessCallback:(void(^_Nullable)(void))callback;


- (ATABUAdnType)getAdNetworkPlaformId;
- (NSString *_Nullable)getAdNetworkRitId;
- (NSString *_Nullable)getPreEcpm;

/**
 Display video ad.
 @param rootViewController : root view controller for displaying ad.
 @return : whether it is successfully displayed.
 */
- (BOOL)showAdFromRootViewController:(UIViewController *_Nonnull)rootViewController;

@end

#endif /* ATMobrainRewardedVideoApis_h */
