//
//  KSNativeAdsManager.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/10/11.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSNativeAd.h"
NS_ASSUME_NONNULL_BEGIN

@protocol KSNativeAdsManagerDelegate;


@interface KSNativeAdsManager : NSObject

@property (nonatomic, strong, nullable) NSArray<KSNativeAd *> *data;
/// The delegate for receiving state change messages such as requests succeeding/failing.
@property (nonatomic, weak, nullable) id<KSNativeAdsManagerDelegate> delegate;

- (id)initWithPosId:(NSString *)posId;

/**
 It is recommended to request no more than 5 ads.
 If more than 5 ads, it will return 1.
 */
- (void)loadAdDataWithCount:(NSInteger)count;

@end


@protocol KSNativeAdsManagerDelegate <NSObject>

@optional

- (void)nativeAdsManagerSuccessToLoad:(KSNativeAdsManager *)adsManager nativeAds:(NSArray<KSNativeAd *> *_Nullable)nativeAdDataArray;

- (void)nativeAdsManager:(KSNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
