//
//  PresageInterstitial.h
//  PresageSDK
//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OguryAdsDelegate.h"

@interface OguryAdsInterstitial : NSObject

@property (nonatomic, weak) id  <OguryAdsInterstitialDelegate> _Nullable interstitialDelegate;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, strong) NSString  * _Nullable adUnitID;

@property (nonatomic,strong) NSString * _Nullable userId;

- (instancetype _Nullable)initWithAdUnitID:( NSString* _Nullable )adUnitID;

- (void)load;
- (void)showInViewController:(UIViewController * _Nonnull)controller;
- (BOOL)isLoaded;
@end

