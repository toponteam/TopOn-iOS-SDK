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
@import AnyThinkSDK;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [ATAPI setLogEnabled:YES];
    [ATAPI integrationChecking];
    
    //channel&subchannle -> customData.channel&subchannel
    [ATAPI sharedInstance].channel = @"test_channel";
    [ATAPI sharedInstance].subchannel = @"test_subchannel";
    [ATAPI sharedInstance].customData = @{kATCustomDataChannelKey:@"custom_data_channel",
                                          kATCustomDataSubchannelKey:@"custom_data_subchannel",
                                          kATCustomDataAgeKey:@18,
                                          kATCustomDataGenderKey:@1,
                                          kATCustomDataNumberOfIAPKey:@19,
                                          kATCustomDataIAPAmountKey:@20.0f,
                                          kATCustomDataIAPCurrencyKey:@"usd",
                                          kATCustomDataSegmentIDKey:@16382351
    };
    
    //customData.channel&subchannel -> channel&subchannle
//    [ATAPI sharedInstance].customData = @{kATCustomDataChannelKey:@"custom_data_channel",
//                                          kATCustomDataSubchannelKey:@"custom_data_subchannel"
//    };
//    [ATAPI sharedInstance].channel = @"test_channel";
//    [ATAPI sharedInstance].subchannel = @"test_subchannel";
    
    //setting custom data for placement, channel&subchannel will be ignored
    [[ATAPI sharedInstance] setCustomData:@{kATCustomDataChannelKey:@"placement_custom_data_channel",
                                          kATCustomDataSubchannelKey:@"placement_custom_data_subchannel"
    } forPlacementID:@"b5c1b048c498b9"];
    
    
    
    [[ATAPI sharedInstance] getUserLocationWithCallback:^(ATUserLocation location) {
        if (location == ATUserLocationInEU) {
            NSLog(@"----------ATUserLocationInEU");
            if ([ATAPI sharedInstance].dataConsentSet == ATDataConsentSetUnknown) {
                NSLog(@"----------ATDataConsentSetUnknown");
            }
        }else if (location == ATUserLocationOutOfEU){
            NSLog(@"----------ATUserLocationOutOfEU");
        }else{
            NSLog(@"----------ATUserLocationUnknown");
        }
    }];
    
    [[ATAPI sharedInstance] startWithAppID:@"a5b0e8491845b3" appKey:@"7eae0567827cfe2b22874061763f30c9" error:nil];
    
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
