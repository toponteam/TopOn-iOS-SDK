//
//  ATKSSplashAdapter.h
//  AnyThinkKuaiShouAdapter
//
//  Created by Topon on 11/20/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATKSSplashAdapter : NSObject

@end

typedef NS_ENUM(NSInteger, ATKSAdShowDirection) {
    KSAdShowDirection_Vertical         =           0,
    KSAdShowDirection_Horizontal,
};

@protocol KSAdSplashInteractDelegate <NSObject>
- (void)ksad_splashAdDidShow;
- (void)ksad_splashAdClicked;
- (void)ksad_splashAdVideoDidStartPlay;
- (void)ksad_splashAdVideoFailedToPlay:(NSError *)error;
- (void)ksad_splashAdVideoDidSkipped:(NSTimeInterval)playDuration;
- (void)ksad_splashAdDismiss:(BOOL)converted;
- (UIViewController *)ksad_splashAdConversionRootVC;
@end

@protocol ATKSAdSplashViewController <NSObject>
// 显示方向，需要在viewDidLoad前设置
@property (nonatomic, assign) ATKSAdShowDirection showDirection;
@property (nonatomic) UIView  *view;
@end

@protocol ATKSAdSplashManager <NSObject>
@property (nonatomic, copy, class) NSString *posId;
/// 闪屏交互代理
@property (nonatomic, weak, class) id<KSAdSplashInteractDelegate> interactDelegate;
+ (void)loadSplash;
+ (void)checkSplash:(void (^)(id<ATKSAdSplashViewController> splashViewController))callback;
+ (void)checkSplashWithTimeout:(NSTimeInterval)timeoutInterval completion:(void (^)(id<ATKSAdSplashViewController> splashViewController))callback;
@end

NS_ASSUME_NONNULL_END
