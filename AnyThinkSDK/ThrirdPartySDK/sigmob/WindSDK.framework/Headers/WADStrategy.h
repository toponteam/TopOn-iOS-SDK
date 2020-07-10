//
//  WADStrategyOptions.h
//  WindSDK
//
//  Created by happyelements on 2018/4/9.
//  Copyright © 2018 Codi. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const WindAdsSDKChannelSigmob = @"sigmob";


@interface WADOptions : NSObject
@property (nonatomic,copy) NSString *appId;
@property (nonatomic,copy) NSString *apiKey;
@property (nonatomic,copy) NSString *placementId;
@property (nonatomic,copy) NSString *repApiKey;
@property (nonatomic,copy) NSString *repApiSecret;
@end


@interface WADStrategy : NSObject
@property (nonatomic,strong) NSError *error;
@property (nonatomic,copy) NSString *placementId;
@property (nonatomic,copy) NSString *adapterClass;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) WADOptions *options;
@property (nonatomic,copy) NSString *loadId;
@property (nonatomic,copy) NSString *channelId;
@property (nonatomic, strong) NSTimer *timeoutTimer;




@end
