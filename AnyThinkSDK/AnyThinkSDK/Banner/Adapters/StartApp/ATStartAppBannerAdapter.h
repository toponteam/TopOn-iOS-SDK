//
//  ATStartAppBannerAdapter.h
//  AnyThinkStartAppBannerAdapter
//
//  Created by Martin Lau on 2020/5/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATStartAppBannerAdapter : NSObject

@end

@protocol ATSTAStartAppSDK<NSObject>
+(instancetype) sharedInstance;
-(void)setUserConsent:(BOOL)consent forConsentType:(NSString *)consentType withTimestamp:(long)ts;
@property (nonatomic, strong) NSString* appID;
@property (nonatomic, assign) BOOL testAdsEnabled; //Default is NO
@end

@protocol ATSTAAdPreferences<NSObject>
@property (nonatomic, assign) double minCPM;
@property (nonatomic, strong) NSString *adTag;
+ (instancetype)preferencesWithMinCPM:(double)minCPM;
@end

@protocol STABannerDelegateProtocol<NSObject>
@end

typedef struct ATSTABannerSizeEnum {
    CGSize size;
    BOOL isAuto;
} ATSTABannerSize;

@protocol ATSTABannerView<NSObject>
- (id)initWithSize:(ATSTABannerSize)size origin:(CGPoint)origin withDelegate:(id<STABannerDelegateProtocol>)bannerDelegate;
- (void)loadAd;
- (void)setSTABannerAdTag:(NSString *)adTag;
- (void)setOrigin:(CGPoint)origin;
@property(nonatomic) CGRect            frame;
@end
