//
//  ATAppnextInterstitialAdapter.h
//  AnyThinkAppnextInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/16.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAppnextInterstitialAdapter : NSObject
@end

@protocol ATAppnextSDKApi<NSObject>
+ (NSString *) getSDKVersion;
@end

@protocol ATAppnextAd;

@protocol AppnextAdDelegate <NSObject>
@optional
- (void) adLoaded:(id<ATAppnextAd>)ad;
- (void) adOpened:(id<ATAppnextAd>)ad;
- (void) adClosed:(id<ATAppnextAd>)ad;
- (void) adClicked:(id<ATAppnextAd>)ad;
- (void) adUserWillLeaveApplication:(id<ATAppnextAd>)ad;
- (void) adError:(id<ATAppnextAd>)ad error:(NSString *)error;
@end

@protocol ATAppnextAdConfiguration<NSObject>
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *postback;
@property (nonatomic, strong) NSString *buttonText;
@property (nonatomic, strong) NSString *buttonColor;
@property (nonatomic, strong) NSString *preferredOrientation;
@end

@protocol ATAppnextAd<NSObject>
@property (nonatomic, weak) id<AppnextAdDelegate> delegate;

@property (nonatomic, strong) NSString *placementID;
@property (nonatomic, assign, readonly) BOOL adIsLoaded;

- (instancetype) init;
- (instancetype) initWithPlacementID:(NSString *)placement;
- (instancetype) initWithConfig:(id<ATAppnextAdConfiguration>)config;
- (instancetype) initWithConfig:(id<ATAppnextAdConfiguration>)config placementID:(NSString *)placement;
- (void) loadAd;
- (void) showAd;

#pragma mark - Setters/Getters

- (void) setCategories:(NSString *)categories;
- (NSString *) getCategories;
- (void) setPostback:(NSString *)postback;
- (NSString *) getPostback;
- (void) setButtonText:(NSString *)buttonText;
- (NSString *) getButtonText;
- (void) setButtonColor:(NSString *)buttonColor;
- (NSString *) getButtonColor;
- (void) setPreferredOrientation:(NSString *)preferredOrientation;
- (NSString *) getPreferredOrientation;

@end
NS_ASSUME_NONNULL_END
