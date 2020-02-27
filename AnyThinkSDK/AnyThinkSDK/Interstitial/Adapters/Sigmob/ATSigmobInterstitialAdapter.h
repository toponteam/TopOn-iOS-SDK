//
//  ATSigmobInterstitialAdapter.h
//  AnyThinkSigmobInterstitialAdapter
//
//  Created by Martin Lau on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kATSigmobInterstitialDataLoadedNotification;
extern NSString *const kATSigmobInterstitialLoadedNotification;
extern NSString *const kATSigmobInterstitialFailedToLoadNotification;
extern NSString *const kATSigmobInterstitialPlayStartNotification;
extern NSString *const kATSigmobInterstitialPlayEndNotification;
extern NSString *const kATSigmobInterstitialClickNotification;
extern NSString *const kATSigmobInterstitialCloseNotification;
extern NSString *const kATSigmobInterstitialFailedToPlayNotification;
extern NSString *const kATSigmobInterstitialNotificationUserInfoPlacementIDKey;
extern NSString *const kATSigmobInterstitialNotificationUserInfoErrorKey;
extern NSString *const kATSigmobInterstitialNotificationUserInfoRewardedFlag;

@interface ATSigmobInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATWindAdOptions<NSObject>
@property (copy, nonatomic) NSString* appId;
@property (copy, nonatomic) NSString* apiKey;
+ (instancetype)options;
@end

@protocol ATWindAds<NSObject>
+ (void) startWithOptions:(nullable id<ATWindAdOptions>)options;
+ (NSString * _Nonnull)sdkVersion;
@end

@protocol WindFullscreenVideoAdDelegate <NSObject>
@end

@protocol ATWindRewardInfo<NSObject>
@property (nonatomic, copy  ) NSString  *rewardId;
@property (nonatomic, copy  ) NSString  *rewardName;
@property (nonatomic, assign) NSInteger rewardAmount;
@property (nonatomic,assign) BOOL isCompeltedView;
@end

@protocol ATWindAdRequest<NSObject>
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *placementId;
@property (nonatomic,strong) NSDictionary<NSString *, NSString *> *options;
+ (instancetype)request;
@end



@protocol ATWindFullscreenVideoAd <NSObject>
@property (nonatomic,weak) id<WindFullscreenVideoAdDelegate> delegate;
+ (instancetype)sharedInstance;
- (BOOL)isReady:(NSString *)placementId;
- (void)loadRequest:(id<ATWindAdRequest>)request withPlacementId:(NSString *)placementId;
- (BOOL)playAd:(UIViewController *)controller withPlacementId:(NSString *)placementId options:(NSDictionary *)options error:( NSError **)error;
@end
