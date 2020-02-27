//
//  ATApplovinNativeAdapter.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATApplovinNativeAdapter : NSObject
@end

@protocol ALNativeAdLoadDelegate;
@protocol ATALNativeAdService<NSObject>
- (void)loadNextAdAndNotify:(id<ALNativeAdLoadDelegate>)delegate;
@end

@protocol ALNativeAdLoadDelegate<NSObject>
- (void)nativeAdService:(id<ATALNativeAdService>)service didLoadAds:(NSArray *) ads;
- (void)nativeAdService:(id<ATALNativeAdService>)service didFailToLoadAdsWithError:(NSInteger)code;
@end

@protocol ATALSdk<NSObject>
+ (instancetype)sharedWithKey:(NSString *)sdkKey;
+(NSUInteger)versionCode;
+ (NSString *)version;
+ (void)initializeSdk;
@property (strong, nonatomic, readonly) id<ATALNativeAdService> nativeAdService;
@end

@protocol ATALPrivacySettings<NSObject>
+ (void)setHasUserConsent:(BOOL)hasUserConsent;
+ (void)setIsAgeRestrictedUser:(BOOL)isAgeRestrictedUser;
@end

@protocol ATALNativeAd<NSObject>
-(void)trackImpression;
-(void) launchClickTarget;
- (NSURL *)videoEndTrackingURL:(NSUInteger)percentViewed firstPlay:(BOOL)firstPlay;
@property (strong, nonatomic, readonly) NSURL *videoStartTrackingURL;
@property (copy, nonatomic, readonly) NSString *title;
@property (copy, nonatomic, readonly) NSString *descriptionText;
@property (copy, nonatomic, readonly) NSString *ctaText;
@property (strong, nonatomic, readonly) NSNumber *starRating;
@property (strong, nonatomic, readonly) NSURL *videoURL;
@property (strong, nonatomic, readonly) NSURL *imageURL;
@property (strong, nonatomic, readonly) NSURL *iconURL;
@end
