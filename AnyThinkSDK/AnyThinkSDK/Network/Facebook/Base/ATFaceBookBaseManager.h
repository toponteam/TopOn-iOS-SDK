//
//  ATFaceBookBaseManager.h
//  AnyThinkFacebookAdapter
//
//  Created by Topon on 11/14/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ATFBAdSettings <NSObject>

@property (class, nonatomic, copy, readonly) NSString *bidderToken;

+ (void)setAdvertiserTrackingEnabled:(BOOL)advertiserTrackingEnabled;
+ (void)setDataProcessingOptions:(NSArray *)ops;
+ (void)setDataProcessingOptions:(NSArray *)ops country:(NSInteger)country state:(NSInteger)state;
+ (void) setIsChildDirected:(BOOL)isChildDirected;

@end

@interface ATFaceBookBaseManager : ATNetworkBaseManager

//+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
