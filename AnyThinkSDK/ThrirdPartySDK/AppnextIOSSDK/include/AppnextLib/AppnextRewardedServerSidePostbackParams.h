//
//  AppnextRewardedServerSidePostbackParams.h
//  AppnextLib
//
//  Created by Eran Mausner on 21/02/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

@interface AppnextRewardedServerSidePostbackParams : NSObject

@property (nonatomic, strong) NSString *rewardsTransactionId;
@property (nonatomic, strong) NSString *rewardsUserId;
@property (nonatomic, strong) NSString *rewardsRewardTypeCurrency;
@property (nonatomic, strong) NSString *rewardsAmountRewarded;
@property (nonatomic, strong) NSString *rewardsCustomParameter;

@end
