//
//  ATAppnextNativeAdapter.h
//  AnyThinkAppnextNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAppnextNativeAdapter : NSObject
@end

extern NSString *const kAppnextNativeAssetsAPIObjectKey;
@protocol ATAppnextAdData<NSObject, NSCoding, NSCopying>
@property (nonatomic, strong, readonly) NSString *buttonText;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *desc;
@property (nonatomic, strong, readonly) NSString *urlImg;
@property (nonatomic, strong, readonly) NSString *urlImgWide;
@property (nonatomic, strong, readonly) NSString *categories;
@property (nonatomic, strong, readonly) NSString *idx;
@property (nonatomic, strong, readonly) NSString *iosPackage;
@property (nonatomic, strong, readonly) NSString *supportedDevices;
@property (nonatomic, strong, readonly) NSString *urlVideo;
@property (nonatomic, strong, readonly) NSString *urlVideoHigh;
@property (nonatomic, strong, readonly) NSString *urlVideo30Sec;
@property (nonatomic, strong, readonly) NSString *urlVideo30SecHigh;
@property (nonatomic, strong, readonly) NSString *bannerId; // The Identifier
@property (nonatomic, strong, readonly) NSString *campaignId;
@property (nonatomic, strong, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSString *campaignType;
@property (nonatomic, strong, readonly) NSString *supportedVersion;
@property (nonatomic, strong, readonly) NSString *storeRating;
@property (nonatomic, strong, readonly) NSString *appSize;
@end

@protocol ATAppnextNativeAdsRequest<NSObject>
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *postback;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSInteger creativeType;
@end

@protocol AppnextNativeAdsRequestDelegate<NSObject>
@optional
- (void) onAdsLoaded:(NSArray<id<ATAppnextAdData>> *)ads forRequest:(id<ATAppnextNativeAdsRequest>)request;
- (void) onError:(NSString *)error forRequest:(id<ATAppnextNativeAdsRequest>)request;
@end

@protocol AppnextNativeAdOpenedDelegate <NSObject>
@optional
- (void) storeOpened:(id<ATAppnextAdData>)adData;
- (void) onError:(NSString *)error forAdData:(id<ATAppnextAdData>)adData;
@end

@protocol AppnextPrivacyClickedDelegate <NSObject>
@optional
- (void) successOpeningAppnextPrivacy:(id<ATAppnextAdData>)adData;
- (void) failureOpeningAppnextPrivacy:(id<ATAppnextAdData>)adData;
@end

@protocol ATAppnextNativeAdsSDKApi<NSObject>
@property (nonatomic, strong, readonly) NSString *placementID;
#pragma mark - Class methods
+ (NSString *) getNativeAdsSDKVersion;
#pragma mark - Public methods
//- (instancetype) initWithPlacementID:(NSString *)placement;
- (instancetype) initWithPlacementID:(NSString *)placement withViewController:(UIViewController *) viewController;
- (void) setViewController:(UIViewController *) viewController;


- (void) loadAds:(id<ATAppnextNativeAdsRequest>)request withRequestDelegate:(id<AppnextNativeAdsRequestDelegate>)delegate;
- (void) adClicked:(id<ATAppnextAdData>)adData withAdOpenedDelegate:(id<AppnextNativeAdOpenedDelegate>)delegate;
- (void) adImpression:(id<ATAppnextAdData>)adData;
- (void) videoStarted:(id<ATAppnextAdData>)adData;
- (void) videoEnded:(id<ATAppnextAdData>)adData;
- (void) privacyClicked:(id<ATAppnextAdData>)adData withPrivacyClickedDelegate:(id<AppnextPrivacyClickedDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
