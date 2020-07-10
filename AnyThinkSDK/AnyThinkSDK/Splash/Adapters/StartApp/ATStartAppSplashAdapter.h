//
//  ATStartAppSplashAdapter.h
//  AnyThinkStartAppSplashAdapter
//
//  Created by Martin Lau on 2020/6/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ATStartAppSplashAdapter : NSObject
@end

@protocol STADelegateProtocol<NSObject>
@end

@protocol ATSTAAdPreferences<NSObject>
@property (nonatomic, strong) NSString *adTag;
@end

@protocol ATSTASplashPreferences<NSObject>
@property (nonatomic, assign) NSInteger splashMode;
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) NSInteger splashMinTime;//2, 3, 5
@property (nonatomic, assign) NSInteger splashAdDisplayTime;//5, 10, 86400
@end

@protocol ATSTAStartAppSDK<NSObject>
+(instancetype) sharedInstance;
-(void)setUserConsent:(BOOL)consent forConsentType:(NSString *)consentType withTimestamp:(long)ts;
@property (nonatomic, strong) NSString* appID;
@property (nonatomic, assign) BOOL testAdsEnabled; //Default is NO
- (void)showSplashAdWithDelegate:(id<STADelegateProtocol>)delegate withAdPreferences:(id<ATSTAAdPreferences>)adPrefs withPreferences:(id<ATSTASplashPreferences>)splashPreferences;
- (void)showSplashAdWithDelegate:(id<STADelegateProtocol>)delegate withPreferences:(id<ATSTASplashPreferences>)splashPreferences;
@end
