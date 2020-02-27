//
//  ATMobPowerNativeAdapter.h
//  AnyThinkMobPowerNativeAdapter
//
//  Created by Martin Lau on 2018/12/24.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATMobPowerNativeAdapter : NSObject

@end

@protocol ATMPSDK<NSObject>
+(NSString*)sdkVersion;
+(instancetype)sharedSDK;
-(BOOL) startWithAppID:(NSString*)appID appKey:(NSString*)appKey error:(NSError**)error;
@property(nonatomic, readonly) NSString *appKey;
@property(nonatomic, readonly) NSString *appID;
@end

@protocol ATMPNative;
@protocol MPNativeDelegate<NSObject>
@optional;
-(void) didPreloadNativeAdsForPlacementID:(NSString*)placementID;
-(void) didLoadNativeAds:(NSArray<id<ATMPNative>>*)ads forPlacementID:(NSString*)placementID;
-(void) failToLoadNativeAdsForPlacementID:(NSString*)placementID error:(NSError*)error;
-(void) didShowNativeAd:(id<ATMPNative>)nativeAd;
-(void) didClickNativeAd:(id<ATMPNative>)nativeAd;
-(void) startClickNativeAd:(id<ATMPNative>)nativeAd;
-(void) endClickNativeAd:(id<ATMPNative>)nativeAd;
@end

@protocol ATMPNative<NSObject>
- (void)registerViewForInteraction:(UIView *)view withViewController:(nullable UIViewController *)viewController withClickableViews:(NSArray<UIView*>*)clickableViews;
@property(nonatomic, readonly) NSString *placementID;
@property(nonatomic, readonly) NSString *titile;
@property(nonatomic, readonly) NSString *body;
@property(nonatomic, readonly) double star;
@property(nonatomic, readonly) NSString *ctaText;
@property(nonatomic, readonly) NSString *packageName;
@property(nonatomic, readonly) NSURL *iconURL;
@property(nonatomic, readonly) NSURL *imageURL;
@property(nonatomic, weak) id<MPNativeDelegate> delegate;
@end

@protocol ATMPNativeManager<NSObject>
+(instancetype)sharedManager;
/*
 Count has to be less than/equal to ten
 */
-(void) loadNativeAdsWithPlacementID:(NSString*)placementID count:(NSInteger)count category:(NSInteger)category delegate:(id<MPNativeDelegate>)delegate;
-(void) preloadNativeAdsWithPlacementID:(NSString*)placementID count:(NSInteger)count category:(NSInteger)category delegate:(id<MPNativeDelegate>)delegate;
@end
