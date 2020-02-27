//
//  AppnextSDKCoreApi.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 14/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

@interface AppnextSDKCoreApi : NSObject

/**
 *  Get the version of this library/framework
 *
 *  @return
 */
+ (NSString *) getCoreVersion;

/**
 *  Helper functions for plugins to turn creative type strings to ANCreativeType and back
 *
 *  @return
 */
+ (NSString *) getCreativeTypeString:(ANCreativeType)type;
+ (ANCreativeType) getCreativeTypeFromString:(NSString *)creativeTypeString;

/**
 *  Helper functions for plugins to turn progress type strings to ANProgressType and back
 *
 *  @return
 */
+ (NSString *) getProgressTypeString:(ANProgressType)progressType;
+ (ANProgressType) getANProgressTypeFromString:(NSString *)progressTypeString;

/**
 *  Helper functions for plugins to turn Video Length strings to ANVideoLength and back
 *
 *  @return
 */
+ (NSString *) getVideoLengthString:(ANVideoLength)videoLengthType;
+ (ANVideoLength) getANVideoLengthFromString:(NSString *)videoLengthString;

@end
