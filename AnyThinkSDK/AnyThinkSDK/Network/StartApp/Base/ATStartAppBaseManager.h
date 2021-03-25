//
//  ATStartAppBaseManager.h
//  AnyThinkStartAppAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATStartAppBaseManager : ATNetworkBaseManager

@end

@protocol ATSTAStartAppSDK<NSObject>
+(instancetype) sharedInstance;
-(void)setUserConsent:(BOOL)consent forConsentType:(NSString *)consentType withTimestamp:(long)ts;
@property (nonatomic, strong) NSString* appID;
@property (nonatomic, assign) BOOL testAdsEnabled; //Default is NO
@end

NS_ASSUME_NONNULL_END
