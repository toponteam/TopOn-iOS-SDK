//
//  ATSigmobRewardedVideoAdapter.h
//  AnyThinkSigmobRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/9/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *const kATSigmobRVDataLoadedNotification;
extern NSString *const kATSigmobRVLoadedNotification;
extern NSString *const kATSigmobRVFailedToLoadNotification;
extern NSString *const kATSigmobRVPlayStartNotification;
extern NSString *const kATSigmobRVPlayEndNotification;
extern NSString *const kATSigmobRVClickNotification;
extern NSString *const kATSigmobRVCloseNotification;
extern NSString *const kATSigmobRVFailedToPlayNotification;
extern NSString *const kATSigmobRVNotificationUserInfoPlacementIDKey;
extern NSString *const kATSigmobRVNotificationUserInfoErrorKey;
extern NSString *const kATSigmobRVNotificationUserInfoRewardedFlag;

@interface ATSigmobRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol WindRewardedVideoAdDelegate<NSObject>
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

@protocol ATWindRewardedVideoAd<NSObject>
@property (nonatomic,weak) id<WindRewardedVideoAdDelegate> delegate;
+ (instancetype)sharedInstance;
- (BOOL)isReady:(NSString *)placementId;
- (void)loadRequest:(id<ATWindAdRequest>)request withPlacementId:(NSString * _Nullable)placementId;
- (BOOL)playAd:(UIViewController *)controller withPlacementId:(NSString * _Nullable)placementId options:(NSDictionary * _Nullable)options error:( NSError *__autoreleasing _Nullable *_Nullable)error;
@end
