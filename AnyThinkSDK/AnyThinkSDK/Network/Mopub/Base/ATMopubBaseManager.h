//
//  ATMopubBaseManager.h
//  AnyThinkMopubAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATMopubBaseManager : ATNetworkBaseManager

@end

@protocol ATMPMoPubConfiguration<NSObject>
- (instancetype)initWithAdUnitIdForAppInitialization:(NSString *)adUnitId;
@end

@protocol ATMoPub<NSObject>
+ (instancetype)sharedInstance;
- (NSString *)version;
- (void)grantConsent;
- (void)revokeConsent;
- (void)initializeSdkWithConfiguration:(id<ATMPMoPubConfiguration>)configuration
                            completion:(void(^_Nullable)(void))completionBlock;
@end

NS_ASSUME_NONNULL_END
