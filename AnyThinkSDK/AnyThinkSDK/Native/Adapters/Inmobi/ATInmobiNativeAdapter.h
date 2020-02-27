//
//  ATInmobiNativeAdapter.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 21/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const kInmobiNativeADAdapterAssetKey;
extern NSString *const kInmobiNativeADAdapterEventKey;
@interface ATInmobiNativeAdapter : NSObject
@end

@protocol ATIMSdk<NSObject>
+(NSString *)getVersion;
+(void)initWithAccountID:(NSString *)accountID;
+(void) updateGDPRConsent:(NSDictionary *)consentDictionary;
@end

@protocol ATIMNativeDelegate;
@protocol ATIMNative<NSObject>
-(instancetype)initWithPlacementId:(long long)placementId;
-(void)load;
-(void)reportAdClickAndOpenLandingPage;
-(UIView*)primaryViewOfWidth:(CGFloat)width;
-(void)recyclePrimaryView;
@property (nonatomic, weak) id<ATIMNativeDelegate> delegate;
@property (nonatomic, strong, readonly) UIImage* adIcon;
@property (nonatomic, strong, readonly) NSString* adTitle;
@property (nonatomic, strong, readonly) NSString* adDescription;
@property (nonatomic, strong, readonly) NSString* adCtaText;
@property (nonatomic, strong, readonly) NSString* adRating;
@end

@protocol ATIMNativeDelegate<NSObject>
-(void)nativeDidFinishLoading:(id<ATIMNative>)native;
-(void)native:(id<ATIMNative>)native didFailToLoadWithError:(NSError*)error;
-(void)native:(id<ATIMNative>)native didInteractWithParams:(NSDictionary*)params;
- (void)nativeAdImpressed:(id<ATIMNative>)native;
- (void)nativeDidDismissScreen:(id<ATIMNative>)native;
- (void)nativeDidFinishPlayingMedia:(id<ATIMNative>)native;
- (void)nativeDidPresentScreen:(id<ATIMNative>)native;
- (void)nativeWillDismissScreen:(id<ATIMNative>)native;
- (void)nativeWillPresentScreen:(id<ATIMNative>)native;
- (void)userDidSkipPlayingMediaFromNative:(id<ATIMNative>)native;
- (void)userWillLeaveApplicationFromNative:(id<ATIMNative>)native;
@end
