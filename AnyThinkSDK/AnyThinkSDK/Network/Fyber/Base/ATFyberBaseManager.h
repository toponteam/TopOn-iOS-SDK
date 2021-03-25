//
//  ATFyberBaseManager.h
//  AnyThinkFyberAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATFyberBaseManager : ATNetworkBaseManager

@end

typedef NS_ENUM(NSInteger, IAGDPRConsentType) {
    IAGDPRConsentTypeUnknown = -1,
    IAGDPRConsentTypeDenied = 0,
    IAGDPRConsentTypeGiven = 1
};

@protocol ATIASDKCore <NSObject>
@property (atomic, strong, nullable, readonly) NSString *appID;
@property (atomic) IAGDPRConsentType GDPRConsent;
@property (atomic, nullable) NSString *GDPRConsentString;
@property (atomic, nullable) NSString *CCPAString;
+ (instancetype _Null_unspecified)sharedInstance;
- (void)initWithAppID:(NSString * _Nonnull)appID;
- (NSString * _Null_unspecified)version;
- (void)clearGDPRConsentData;
@end

NS_ASSUME_NONNULL_END
