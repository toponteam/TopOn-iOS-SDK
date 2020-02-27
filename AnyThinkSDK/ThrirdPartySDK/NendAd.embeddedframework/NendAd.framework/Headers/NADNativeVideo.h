//
//  NADNativeVideo.h
//  NendAdFramework
//
//  Copyright © 2018年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NADNative.h"

@class NADNativeVideo;

extern const NSInteger kNADVideoOrientationVertical;
extern const NSInteger kNADVideoOrientationHorizontal;

typedef NS_ENUM(NSInteger, NADNativeVideoClickAction) {
    NADNativeVideoClickActionFullScreen = 1,
    NADNativeVideoClickActionLP = 2
};

@protocol NADNativeVideoDelegate <NSObject>

@optional
- (void)nadNativeVideoDidImpression:(NADNativeVideo * _Nonnull)ad;
- (void)nadNativeVideoDidClickAd:(NADNativeVideo * _Nonnull)ad;
- (void)nadNativeVideoDidClickInformation:(NADNativeVideo * _Nonnull)ad;

@end

@interface NADNativeVideo : NSObject

@property (readwrite, nonatomic, weak, nullable) id<NADNativeVideoDelegate> delegate;
@property (readwrite, nonatomic, getter=isMutedOnFullScreen) BOOL mutedOnFullScreen;
@property (readonly, nonatomic) BOOL hasVideo;
@property (readonly, nonatomic) NSInteger orientation;
@property (readonly, nonatomic, copy, nullable) NSString *title;
@property (readonly, nonatomic, copy, nullable) NSString *advertiserName;
@property (readonly, nonatomic, copy, nullable) NSString *explanation;
@property (readonly, nonatomic) CGFloat userRating;
@property (readonly, nonatomic) NSInteger userRatingCount;
@property (readonly, nonatomic, copy, nullable) NSString *callToAction;
@property (readonly, nonatomic, copy, nullable) NSString *logoImageUrl;
@property (readonly, nonatomic, strong, nullable) UIImage *logoImage;
@property (readonly, nonatomic, strong, nullable) NADNative *staticNativeAd;

- (instancetype _Null_unspecified)init NS_UNAVAILABLE;
- (void)registerInteractionViews:(nonnull NSArray<__kindof UIView *> *)views;
- (void)unregisterInteractionViews;
- (void)downloadLogoImageWithCompletionHandler:(void(^_Nonnull)(UIImage * _Nullable))handler;

@end
