//
//  AppnextNetworkUtils.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 13/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAFNetworking.h>

@interface AppnextNetworkUtils : NSObject

+ (AppnextAFNetworkReachabilityStatus) networkReachabilityStatus;
+ (BOOL) networkReachable;
+ (BOOL) networkReachabilityKnown;
+ (BOOL) wifiReachable;
+ (BOOL) wWANReachable;
+ (NSString *) getConnectionType;
+ (NSString *) getMobileNetworkConnectionType;
+ (NSHTTPCookie *) getCookieNamed:(NSString *)cookieName fromDomain:(NSString *)cookieDomain;
+ (NSString *) getCarrierName;
@end
