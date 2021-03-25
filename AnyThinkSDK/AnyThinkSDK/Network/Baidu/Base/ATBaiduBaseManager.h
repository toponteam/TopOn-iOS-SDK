//
//  ATBaiduBaseManager.h
//  AnyThinkBaiduAdapter
//
//  Created by Topon on 11/15/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATBaiduBaseManager : ATNetworkBaseManager

@end

@protocol ATBaiduMobAdSetting<NSObject>
@property BOOL supportHttps;
@property BOOL trackCrash;
+ (void)setLpStyle:(NSInteger)style;
+ (instancetype)sharedInstance;
+ (void)setMaxVideoCacheCapacityMb:(NSInteger)capacity;
@end

NS_ASSUME_NONNULL_END
