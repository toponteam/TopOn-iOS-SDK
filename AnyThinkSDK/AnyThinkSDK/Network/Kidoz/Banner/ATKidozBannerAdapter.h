//
//  ATKidozBannerAdapter.h
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


extern NSString *const kATKidozBannerLoadedNotification;
extern NSString *const kATKidozBannerFailedToLoadNotification;
extern NSString *const kATKidozBannerShowNotification;
extern NSString *const kATKidozBannerNotificationUserInfoErrorKey;

@interface ATKidozBannerAdapter : NSObject

@end

@protocol KDZInitDelegate <NSObject>
@optional
-(void)onInitSuccess;
-(void)onInitError:(NSString *)error;
@end

@protocol KDZBannerDelegate <NSObject>
-(void)bannerDidInitialize;
-(void)bannerDidClose;
-(void)bannerDidOpen;
-(void)bannerIsReady;
-(void)bannerReturnedWithNoOffers;
-(void)bannerLoadFailed;
-(void)bannerDidReciveError:(NSString*)errorMessage;
-(void)bannerLeftApplication;
@end

typedef enum {
    BOTTOM_CENTER,
    TOP_LEFT,
    TOP_CENTER,
    TOP_RIGHT,
    BOTTOM_LEFT,
    BOTTOM_RIGHT,
    NONE
} ATBANNER_POSITION;

@protocol ATKidozSDK <NSObject>

+ (id)instance;

- (void)initializeWithPublisherID:(NSString *)publisherID securityToken:(NSString *)securityToken withDelegate:(id<KDZInitDelegate>)delegate;
- (void)initializeWithPublisherID:(NSString *)publisherID securityToken:(NSString *)securityToken;
- (BOOL)isSDKInitialized;

- (void)initializeBannerWithDelegate:(id<KDZBannerDelegate>)delegate withViewController:(UIViewController *)viewController;
- (void)initializeBannerWithDelegate:(id<KDZBannerDelegate>)delegate withView:(UIView*)view;

- (void)loadBanner;
- (void)showBanner;
- (void)hideBanner;
- (void)setBannerPosition:(ATBANNER_POSITION)bannerPosition;

- (BOOL)isBannerInitialized;
- (BOOL)isBannerReady;
- (void)setBannerDelegate:(id<KDZBannerDelegate>)delegate;
@end
NS_ASSUME_NONNULL_END
