//
//  ATApplovinBaseManager.h
//  AnyThinkApplovinAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATApplovinBaseManager : ATNetworkBaseManager

@end

@protocol ATBaseALSdk<NSObject>
@property (nonatomic, copy, nullable) NSString *userIdentifier;
- (void)initializeSdk;
+ (NSString *)version;
+(NSUInteger)versionCode;
+ (instancetype)sharedWithKey:(NSString *)sdkKey;
@end

@protocol ATBaseALPrivacySettings<NSObject>
+ (void)setHasUserConsent:(BOOL)hasUserConsent;
+ (void)setIsAgeRestrictedUser:(BOOL)isAgeRestrictedUser;
@end

NS_ASSUME_NONNULL_END
