//
//  ATTapjoyBaseManager.h
//  AnyThinkTapjoyAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kTapjoyClassName;
@interface ATTapjoyBaseManager : ATNetworkBaseManager

@end

@protocol ATTJPrivacyPolicy <NSObject>

- (void)setUSPrivacy:(NSString*) privacyValue;
- (void)setBelowConsentAge:(BOOL) isBelowConsentAge;

@end

@protocol ATTapjoy<NSObject>
+ (NSString*)getVersion;
+ (BOOL)isConnected;
+ (void)connect:(NSString *)sdkKey;
+ (void)setUserConsent:(NSString*) value;
+ (void)subjectToGDPR:(BOOL) gdprApplicability;
+ (void)setUserID:(NSString*)theUserID;
+ (id<ATTJPrivacyPolicy>)getPrivacyPolicy;
@end

NS_ASSUME_NONNULL_END
