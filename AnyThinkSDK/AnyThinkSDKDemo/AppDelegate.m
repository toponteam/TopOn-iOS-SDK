//
//  AppDelegate.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2019/10/31.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+KAKit.h"
#import "Utilities.h"
#import <AppTrackingTransparency/ATTrackingManager.h>
#import "Adjust.h"
#import "TopOnAdManager.h"

@interface AppDelegate ()< AdjustDelegate>

@end

@implementation AppDelegate

//AdjustDelegate
- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    
}

- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
    
}

- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
    
}

- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    
}

// AppsFlyerLibDelegate
- (void)onConversionDataFail:(NSError *)error {
    
}

- (void)onConversionDataSuccess:(NSDictionary *)conversionInfo {
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    Class class = NSClassFromString(@"AppsFlyerLib");
//    SEL selector = NSSelectorFromString(@"shared");
//    if (class && selector) {
//        NSObject *object = [class performSelector:selector];
//        BOOL hasDevKey = NO;
//        @try {
//            hasDevKey = [object valueForKey:@"appsFlyerDevKey"];
//        } @catch (NSException *exception) {
//
//        } @finally {
//
//        }
//        if (hasDevKey) {
//            [object setValue:@"ReCBbbrTheTUi5DUFJtkHR" forKey:@"appsFlyerDevKey"];
//        }
//    }

    [[TopOnAdManager sharedManager] initSDKAPIWithAPIType:TopOnAPITypeTopOn];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
