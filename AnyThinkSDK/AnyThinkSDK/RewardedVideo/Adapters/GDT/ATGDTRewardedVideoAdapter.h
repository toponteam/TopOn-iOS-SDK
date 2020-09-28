//
//  ATGDTRewardedVideoAdapter.h
//  AnyThinkGDTRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/12/11.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ATGDTRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATGDTSDKConfig<NSObject>
+ (BOOL)registerAppId:(NSString *)appId;
+ (NSString *)sdkVersion;
+ (void)enableDefaultAudioSessionSetting:(BOOL)enabled;
@end

@protocol GDTRewardedVideoAdDelegate;
@protocol ATGDTRewardVideoAd<NSObject>
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
@property (nonatomic, assign, readonly) NSInteger expiredTimestamp;
@property (nonatomic, weak) id <GDTRewardedVideoAdDelegate> delegate;
- (instancetype)initWithPlacementId:(NSString *)placementId;
- (void)loadAd;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end


@protocol GDTRewardedVideoAdDelegate <NSObject>
@end
