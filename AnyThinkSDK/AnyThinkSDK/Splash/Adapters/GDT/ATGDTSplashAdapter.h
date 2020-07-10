//
//  ATGDTSplashAdapter.h
//  AnyThinkGDTSplashAdapter
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATGDTSplashAdapter : NSObject

@end

@protocol ATGDTSDKConfig<NSObject>
+ (BOOL)registerAppId:(NSString *)appId;
+ (NSString *)sdkVersion;
@end

@protocol GDTSplashAdDelegate <NSObject>
@end

@protocol ATGDTSplashAd<NSObject>
@property (nonatomic, weak) id<GDTSplashAdDelegate> delegate;
@property (nonatomic, assign) CGFloat fetchDelay;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, assign) CGPoint skipButtonCenter;
- (instancetype)initWithPlacementId:(NSString *)placementId;
- (void)loadAd;
- (void)showAdInWindow:(UIWindow *)window withBottomView:(UIView *)bottomView skipView:(UIView *)skipView;
@end
