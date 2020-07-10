//
//  ATStartAppRewardedVideoAdapter.h
//  AnyThinkStartAppRewardedVideoAdapter
//
//  Created by Martin Lau on 2020/3/18.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATStartAppRewardedVideoAdapter : NSObject

@end

@protocol ATSTAStartAppSDK<NSObject>
+(instancetype) sharedInstance;
-(void)setUserConsent:(BOOL)consent forConsentType:(NSString *)consentType withTimestamp:(long)ts;
@property (nonatomic, strong) NSString* appID;
@end

@protocol STADelegateProtocol<NSObject>
@end

@protocol ATSTAAdPreferences<NSObject>
@property (nonatomic, assign) double minCPM;
@property (nonatomic, strong) NSString *adTag;
+ (instancetype)preferencesWithMinCPM:(double)minCPM;
@end

@protocol ATSTAAbstractAd<NSObject>
@end
@protocol ATSTAStartAppAd<ATSTAAbstractAd>
- (void) loadRewardedVideoAdWithDelegate:(id<STADelegateProtocol>) delegate withAdPreferences:(id<ATSTAAdPreferences>) adPrefs;
- (void) showAdWithAdTag:(NSString *)adTag;
- (BOOL) isReady;
@end
