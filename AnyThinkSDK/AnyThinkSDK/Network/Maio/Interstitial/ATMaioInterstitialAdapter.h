//
//  ATMaioInterstitialAdapter.h
//  AnyThinkMaioInterstitialAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATMaioInterstitialAdapter : NSObject
@end

@protocol ATMaioInstance;
@protocol MaioDelegate;
@protocol Maio<NSObject>
+ (NSString *)sdkVersion;
+ (void)setAdTestMode:(BOOL)adTestMode;
+ (void)addDelegateObject:(id<MaioDelegate>)delegate;
+ (void)removeDelegateObject:(id<MaioDelegate>)delegate;
+ (BOOL)containsMaioDelegate:(id<MaioDelegate>)delegate;
+ (void)startWithMediaId:(NSString *)mediaId delegate:(id<MaioDelegate>)delegate;
+ (id<ATMaioInstance>)startWithNonDefaultMediaId:(NSString *)mediaEid delegate:(id<MaioDelegate>)delegate;
+ (BOOL)canShowAtZoneId:(NSString *)zoneId;
+ (void)showAtZoneId:(NSString *)zoneEid vc:(UIViewController *)vc;
@end

@protocol ATMaioInstance<NSObject>
@property (nonatomic, readonly) NSString *mediaId;
@property (nonatomic) BOOL adTestMode;
@property (nonatomic) id<MaioDelegate> delegate;
- (void)addDelegateObject:(id<MaioDelegate>)delegate;
- (void)removeDelegateObject:(id<MaioDelegate>)delegate;
- (BOOL)containsDelegate:(id<MaioDelegate>)delegate;
- (BOOL)canShowAtZoneId:(NSString *)zoneId;
- (void)showAtZoneId:(NSString *)zoneEid vc:(UIViewController *)vc;
@end

@protocol MaioDelegate <NSObject>
@optional
- (void)maioDidInitialize;
- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue;
- (void)maioWillStartAd:(NSString *)zoneId;
- (void)maioDidFinishAd:(NSString *)zoneId playtime:(NSInteger)playtime skipped:(BOOL)skipped rewardParam:(NSString *)rewardParam;
- (void)maioDidClickAd:(NSString *)zoneId;
- (void)maioDidCloseAd:(NSString *)zoneId;
- (void)maioDidFail:(NSString *)zoneId reason:(NSInteger)reason;
@end
