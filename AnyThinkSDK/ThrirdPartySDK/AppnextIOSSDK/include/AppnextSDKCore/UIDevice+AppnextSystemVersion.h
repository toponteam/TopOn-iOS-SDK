//
//  UIDevice+AppnextSystemVersion.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 30/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kiPhone1G = @"iPhone 1G";
static NSString * const kiPhone3G = @"iPhone 3G";
static NSString * const kiPhone3GS = @"iPhone 3GS";
static NSString * const kiPhone4 = @"iPhone 4";
static NSString * const kVerizoniPhone4 = @"Verizon iPhone 4";
static NSString * const kiPhone4S = @"iPhone 4S";
static NSString * const kiPodTouch1G = @"iPod Touch 1G";
static NSString * const kiPodTouch2G = @"iPod Touch 2G";
static NSString * const kiPodTouch3G = @"iPod Touch 3G";
static NSString * const kiPodTouch4G = @"iPod Touch 4G";
static NSString * const kiPad = @"iPad";
static NSString * const kiPad2WiFi = @"iPad 2 (WiFi)";
static NSString * const kiPad2GSM = @"iPad 2 (GSM)";
static NSString * const kiPad2CDMA = @"iPad 2 (CDMA)";
static NSString * const kSimulator = @"Simulator";

@interface UIDevice (AppnextSystemVersion)

+ (float) iOSVersion;
+ (BOOL) isPad;
+ (CGFloat) getDeviceScreenScale;
+ (NSString *) getDeviceName;
+ (NSString *) getDeviceSystemName;
+ (NSString *) getDeviceOSVersion;
+ (NSString *) getDeviceModel;

+ (NSString *) platform;
+ (NSString *) platformString;

@end
