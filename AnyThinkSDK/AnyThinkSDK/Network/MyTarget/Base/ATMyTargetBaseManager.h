//
//  ATMyTargetBaseManager.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ATMTRGPrivacy <NSObject>

@property(nonatomic, readonly) BOOL isConsent;
@property(nonatomic, readonly) BOOL userAgeRestricted;
@property(nonatomic, readonly, nullable) NSNumber *userConsent;
@property(nonatomic, readonly, nullable) NSNumber *ccpaUserConsent;
@property(nonatomic, readonly, nullable) NSNumber *iABUserConsent;

+ (instancetype)currentPrivacy;

+ (void)setUserConsent:(BOOL)isConsent;

+ (void)setCcpaUserConsent:(BOOL)isConsent;

+ (void)setIABUserConsent:(BOOL)isConsent;

+ (void)setUserAgeRestricted:(BOOL)isAgeRestricted;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;


@end

@protocol ATMTRGVersion <NSObject>

+ (NSString *)currentVersion;

@end

@protocol ATMTRGManager <NSObject>

+ (NSString *)getBidderToken; // this method should be called on background thread

@end

@interface ATMyTargetBaseManager : ATNetworkBaseManager

@end

NS_ASSUME_NONNULL_END
