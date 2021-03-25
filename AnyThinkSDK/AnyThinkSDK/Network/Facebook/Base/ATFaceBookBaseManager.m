//
//  ATFaceBookBaseManager.m
//  AnyThinkFacebookAdapter
//
//  Created by Topon on 11/14/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATFaceBookBaseManager.h"
#import "ATAppsettingManager.h"

@interface ATFaceBookBaseManager ()

@end

@implementation ATFaceBookBaseManager
+(void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFacebook]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFacebook];
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameFacebook];
        }
        
        Class tokenClass = NSClassFromString(@"FBAdSettings");
        if (tokenClass) {
            BOOL ccpaComply = [ATAppSettingManager sharedManager].complyWithCCPA;
            if (ccpaComply) {
                [tokenClass setDataProcessingOptions:@[@"LDU"] country:1 state:1];
            }
            
            BOOL coppaComply = [ATAppSettingManager sharedManager].complyWithCOPPA;
            if (coppaComply) {
                [tokenClass setIsChildDirected:YES];
            }
        }
    });
}

//+ (instancetype)sharedManager {
//    static ATFaceBookBaseManager *sharedManager = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedManager = [[ATFaceBookBaseManager alloc] init];
//    });
//    return sharedManager;
//}


@end

