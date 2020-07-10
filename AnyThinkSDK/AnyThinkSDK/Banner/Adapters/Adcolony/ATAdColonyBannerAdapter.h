//
//  ATAdColonyBannerAdapter.h
//  AnyThinkAdColonyBannerAdapter
//
//  Created by Martin Lau on 2020/6/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATAdColonyBannerAdapter : NSObject

@end

typedef NS_ENUM(NSUInteger, ATAdColonyIAPEngagement) {
    
    /** IAP was enabled for the ad, and the user engaged via a dynamic end card (DEC). */
    ATAdColonyIAPEngagementEndCard = 0,
    
    /** IAP was enabled for the ad, and the user engaged via an in-vdeo engagement (Overlay). */
    ATAdColonyIAPEngagementOverlay
};

typedef NS_ENUM(NSUInteger, ATAdColonyZoneType) {
    
    /** Interstitial zone type */
    ATAdColonyZoneTypeInterstitial = 0,
    
    /** Native zone type */
    ATAdColonyZoneTypeNative
};

@protocol ATAdColonyZone<NSObject>
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) ATAdColonyZoneType type;
@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) BOOL rewarded;
@property (nonatomic, readonly) NSUInteger viewsPerReward;
@property (nonatomic, readonly) NSUInteger viewsUntilReward;
@property (nonatomic, readonly) NSUInteger rewardAmount;
@property (nonatomic, readonly) NSString *rewardName;
-(void)setReward:(nullable void (^)(BOOL success, NSString *name, int amount))reward;
@end

@protocol ATAdColonyAppOptions<NSObject>
@property (nonatomic, strong) NSString *userID;
@property (nonatomic) BOOL gdprRequired;
@property (nonatomic) NSString *gdprConsentString;
@end

@protocol AdColonyAdViewDelegate<NSObject>
@end

@protocol ATAdColonyAdView<NSObject>
@end

typedef struct AdColonyAdSize {
    CGFloat width;
    CGFloat height;
} AdColonyAdSize;

@protocol ATAdColony<NSObject>
+ (NSString *)getSDKVersion;
+ (void)configureWithAppID:(NSString *)appID zoneIDs:(NSArray<NSString *> *)zoneIDs options:(id)options completion:(void (^)(NSArray<id<ATAdColonyZone>> *zones))completion;
+ (void)requestAdViewInZone:(NSString *)zoneID withSize:(AdColonyAdSize)size viewController:(UIViewController *)viewController andDelegate:(id<AdColonyAdViewDelegate>)delegate;
@end
