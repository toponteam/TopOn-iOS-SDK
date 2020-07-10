//
//  ATVungleBannerAdapter.h
//  AnyThinkVungleBannerAdapter
//
//  Created by Martin Lau on 2020/6/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATVungleBannerAdapter : NSObject
@end

@protocol ATVungleSDKDelegate <NSObject>
@end

@protocol ATVungleSDK<NSObject>
@property (strong) id<ATVungleSDKDelegate> delegate;
@property (atomic, readonly, getter=isInitialized) BOOL initialized;
+ (instancetype)sharedSDK;
- (void)updateConsentStatus:(NSInteger)status consentMessageVersion:(NSString *)version;
- (BOOL)startWithAppId:(NSString *)appID error:(NSError **)error;
- (BOOL)loadPlacementWithID:(NSString *)placementID error:(NSError **)error;
- (BOOL)loadPlacementWithID:(NSString *)placementID withSize:(NSInteger)size error:(NSError **)error;
- (BOOL)addAdViewToView:(UIView *)publisherView withOptions:(NSDictionary *)options placementID:(NSString *)placementID error:(NSError *__autoreleasing*)error;
- (void)finishedDisplayingAd;
@end

@protocol ATVungleViewInfo<NSObject>
@property (nonatomic, readonly) NSNumber *completedView;
@property (nonatomic, readonly) NSNumber *playTime;
@property (nonatomic, readonly) NSNumber *didDownload;
@end


