//
//  ALAdType.h
//  AppLovinSDK
//
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This class defines the possible types of an interstitial ad (i.e. regular or incentivized/rewarded).
 */
@interface ALAdType : NSObject

/**
 * Represents a regular fullscreen ad.
 */
@property (class, nonatomic, strong, readonly) ALAdType *regular;

/**
 * Represents a rewarded video where users will be rewarded for viewing this type of ad.
 */
@property (class, nonatomic, strong, readonly) ALAdType *incentivized;

@end

@interface ALAdType(ALDeprecated)
+ (ALAdType *)typeNative __deprecated;
+ (NSArray *)allTypes __deprecated_msg("Retrieval of all types is deprecated and will be removed in a future SDK version.");
@property (copy, nonatomic, readonly) NSString *label __deprecated_msg("Retrieval of underlying string is deprecated and will be removed in a future SDK version.");
+ (ALAdType *)typeRegular __deprecated_msg("Class method `typeRegular` is deprecated and will be removed in a future SDK version. Please use ALAdType.regular instead.");
+ (ALAdType *)typeIncentivized __deprecated_msg("Class method `typeIncentivized` is deprecated and will be removed in a future SDK version. Please use ALAdType.incentivized instead.");
@end

NS_ASSUME_NONNULL_END
