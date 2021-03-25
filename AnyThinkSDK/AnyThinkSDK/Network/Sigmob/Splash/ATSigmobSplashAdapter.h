//
//  ATSigmobSplashAdapter.h
//  AnyThinkSigmobSplashAdapter
//
//  Created by Martin Lau on 2019/9/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATSigmobSplashAdapter : NSObject
@end

@protocol WindSplashAdDelegate<NSObject>
@end
@protocol ATWindSplashAd<NSObject>
@property (nonatomic,weak) id<WindSplashAdDelegate> delegate;
@property (nonatomic, assign) int fetchDelay;
@property(nonatomic, weak) UIWindowScene *windowScene API_AVAILABLE(ios(13.0));
- (instancetype)initWithPlacementId:(NSString *)placementId
                              extra:(NSDictionary *)extra;
-(void)loadAdAndShowWithBottomView:(UIView *)bottomView;
- (void)loadAd;

- (void)showAdInWindow:(UIWindow *)window withBottomView:(UIView *)bottomView;

- (void)showAdInWindow:(UIWindow *)window title:(NSString *)title desc:(NSString *)desc;
@end
