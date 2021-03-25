//
//  TopOnAdManager.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2020/1/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "TopOnAdManager.h"
//iOS 14
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@import AnyThinkSDK;

NSInteger const TopOnAPITypeTopOn = 1;


@implementation TopOnAdManager
+(instancetype) sharedManager {
    static TopOnAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TopOnAdManager alloc] init];
        
    });
    return sharedManager;
}

-(void) initSDKAPIWithAPIType:(NSInteger)apiType {
    self.currentAPIType = apiType;

        [ATAPI setLogEnabled:YES];
        [ATAPI integrationChecking];
        
        //channel&subchannle -> customData.channel&subchannel
        [ATAPI sharedInstance].channel = @"test_channel";
        [ATAPI sharedInstance].subchannel = @"test_subchannel";
        [ATAPI sharedInstance].customData = @{kATCustomDataUserIDKey:@"test_custom_user_id",
                                              kATCustomDataChannelKey:@"custom_data_channel",
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
        
        [[ATAPI sharedInstance] setExludeAppleIdArray:@[@"id529479190"]];
        
    //    [[ATAPI sharedInstance] setDeniedUploadInfoArray:@[kATDeviceDataInfoOSVersionNameKey,
    //                                                       kATDeviceDataInfoOSVersionCodeKey,
    //                                                       kATDeviceDataInfoPackageNameKey,
    //                                                       kATDeviceDataInfoAppVersionCodeKey,
    //                                                       kATDeviceDataInfoAppVersionNameKey,
    //                                                       kATDeviceDataInfoBrandKey,
    //                                                       kATDeviceDataInfoModelKey,
    //                                                       kATDeviceDataInfoScreenKey,
    //                                                       kATDeviceDataInfoNetworkTypeKey,
    //                                                       kATDeviceDataInfoMNCKey,
    //                                                       kATDeviceDataInfoMCCKey,
    //                                                       kATDeviceDataInfoLanguageKey,
    //                                                       kATDeviceDataInfoTimeZoneKey,
    //                                                       kATDeviceDataInfoUserAgentKey,
    //                                                       kATDeviceDataInfoOrientKey,
    //                                                       kATDeviceDataInfoIDFAKey,
    //                                                       kATDeviceDataInfoIDFVKey]];
        
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
        
    //    [ATAPI setAdLogoVisible:YES];
        
        if (@available(iOS 14, *)) {
            //iOS 14
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                [[ATAPI sharedInstance] startWithAppID:@"a5b0e8491845b3" appKey:@"7eae0567827cfe2b22874061763f30c9" error:nil];
            }];
        } else {
            // Fallback on earlier versions
            [[ATAPI sharedInstance] startWithAppID:@"a5b0e8491845b3" appKey:@"7eae0567827cfe2b22874061763f30c9" error:nil];
        }
        

}
-(void) initSDKAPIWithAppID:(NSString*)appID appKey:(NSString*)appKey {
    
}

@end
