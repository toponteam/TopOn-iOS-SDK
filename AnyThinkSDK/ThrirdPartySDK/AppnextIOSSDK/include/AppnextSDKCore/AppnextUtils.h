//
//  AppnextUtils.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 13/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdData.h>

@interface AppnextUtils : NSObject

+ (BOOL) isUrlEncoded:(NSString *)str;
+ (NSString *) urlEncode:(NSString *)str;
+ (NSString *) urlEncodeIfNeeded:(NSString *)str;
+ (NSString *) urlDecode:(NSString *)str;
+ (NSString *) htmlDecode:(NSString *)str;
+ (NSString *) jsonToJSLiteral:(NSString *)jsonString;
+ (NSInteger) getRandomBetween:(u_int32_t)min and:(u_int32_t)max;
+ (NSString *) hexStringForColor:(UIColor *)color;
+ (UIColor *) colorFromHexString:(NSString *)hexString;
+ (NSString *) getAdvertiserID;
+ (NSString *) getDeviceID;
+ (NSString *) getApplicationIdentifier;
+ (BOOL) isAdvertisingTrackingEnabled;
+ (time_t) timeSinceUptime;
+ (NSString *) getResourcePathNamed:(NSString *)resourceName resourceType:(NSString *)resourceType fromBundle:(NSString *)bundleName;
+ (NSData *) getResourceNamed:(NSString *)resourceName resourceType:(NSString *)resourceType fromBundle:(NSString *)bundleName;
+ (NSDictionary *) getDictionaryFromResourceNamed:(NSString *)resourceName resourceType:(NSString *)resourceType fromBundle:(NSString *)bundleName;
+ (NSString *) adjustImageToScreenScale:(NSString *)imageName;

+ (NSString *) convertArrayToString:(NSArray *) array;
+ (BOOL) createDirectoryInDocumentsIfNotExistsAtPath:(NSString *)dirPath;
+ (void) deleteFileIfExists:(NSString *)filePath;
+ (BOOL) fileExistsAtPath:(NSString *)filePath;
+ (BOOL) changeFile:(NSString *)filePath lastModificationDateAttribute:(NSDate *)date;
+ (void) deleteObseleteFilesFromFolderPath:(NSString *)directory leaveFiles:(NSUInteger)leave;

+ (BOOL) runningInBackground;
+ (BOOL) runningInForeground;

+ (NSString *) getPrivacyLink:(AppnextAdData *)adData;
+ (NSString *) getActiveLanguage;
+ (NSString *) getDevicePreferredLanguageFullCode;

@end
