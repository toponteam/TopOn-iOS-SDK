//
//  ATKidozInterstitialAdapter.h
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kATKidozInterstitialLoadedNotification;
extern NSString *const kATKidozInterstitialFailedToLoadNotification;
extern NSString *const kATKidozInterstitialShowNotification;
extern NSString *const kATKidozInterstitialCloseNotification;
extern NSString *const kATKidozInterstitialNotificationUserInfoErrorKey;

@interface ATKidozInterstitialAdapter : NSObject

@end

@protocol KDZInitDelegate <NSObject>
@optional
-(void)onInitSuccess;
-(void)onInitError:(NSString *)error;
@end

@protocol KDZInterstitialDelegate <NSObject>
-(void)interstitialDidInitialize;
-(void)interstitialDidClose;
-(void)interstitialDidOpen;
-(void)interstitialIsReady;
-(void)interstitialReturnedWithNoOffers;
-(void)interstitialDidPause;
-(void)interstitialDidResume;
-(void)interstitialLoadFailed;
-(void)interstitialDidReciveError:(NSString*)errorMessage;
-(void)interstitialLeftApplication;
@end

@protocol ATKidozSDK <NSObject>

+ (id)instance;

- (void)initializeWithPublisherID:(NSString *)publisherID securityToken:(NSString *)securityToken withDelegate:(id<KDZInitDelegate>)delegate;
- (void)initializeWithPublisherID:(NSString *)publisherID securityToken:(NSString *)securityToken;
- (BOOL)isSDKInitialized;

- (void)loadInterstitial;
- (void)showInterstitial;
- (BOOL)isInterstitialInitialized;
- (BOOL)isInterstitialReady;
- (void)initializeInterstitialWithDelegate:(id<KDZInterstitialDelegate>)delegate;
- (void)setInterstitialDelegate:(id<KDZInterstitialDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
