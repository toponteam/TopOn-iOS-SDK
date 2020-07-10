//
//  WindRewardVideoAdConnector.h
//  WindSDK
//
//  Created by happyelements on 2018/4/9.
//  Copyright © 2018 Codi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WindProtocol.h"

@class WindRewardInfo;
@class WindAdRequest;
@protocol WindRewardVideoAdAdapter;



@protocol WindRewardVideoAdConnector<WindAdRequestProtocol>

@optional

- (void)adapterDidSetUpRewardVideoAd:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter;

- (void)adapter:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter didFailToSetUpRewardVideoAd:(NSError *)error;

- (void)adapterDidAdClick:(id<WindRewardVideoAdAdapter>)adapter placementId:(NSString *)placementId strategy:(WADStrategy *)stragegy;

- (void)adapterDidReceiveRewardVideoAd:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter placementId:(NSString *)placementId strategy:(WADStrategy *)stragegy;

- (void)adapterDidStartPlayingRewardVideoAd:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter placementId:(NSString *)placementId strategy:(WADStrategy *)stragegy;

- (void)adapterDidCloseRewardVideoAd:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter rewardInfo:(WindRewardInfo *)info placementId:(NSString *)placementId strategy:(WADStrategy *)stragegy;

- (void)adapter:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter didFailToLoadRewardVideoAdwithError:(NSError *)error placementId:(NSString *)placementId strategy:(WADStrategy *)stragegy;

- (void)adapter:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter didPlayRewardVideoAdwithError:(NSError *)error placementId:(NSString *)placementId strategy:(WADStrategy *)stragegy;

- (void)adapterDidCompletePlayingRewardVideoAd:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter placementId:(NSString *)placementId strategy:(WADStrategy *)stragegy;

- (void)adapterRewardedVideoAdServerDidSucceed:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter placementId:(NSString *)placementId strategy:(WADStrategy *)stragegy;

- (void)adapterRewardedVideoAdServerDidFail:(id<WindRewardVideoAdAdapter>)rewardVideoAdAdapter placementId:(NSString *)placementId strategy:(WADStrategy *)stragegy;

@end


