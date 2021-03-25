//
//  ATMintegralSplashAdapter.h
//  AnyThinkMintegralSplashAdapter
//
//  Created by Martin Lau on 2020/6/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATMintegralSplashAdapter : NSObject

@end

@protocol MTGSplashADDelegate<NSObject>
@end

@protocol ATMTGSplashAD<NSObject>
- (instancetype)initWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID countdown:(NSUInteger)countdown allowSkip:(BOOL)allowSkip customViewSize:(CGSize)customViewSize preferredOrientation:(NSInteger)preferredOrientation;
- (void)preload;
- (void)showInKeyWindow:(UIWindow *)window customView:(UIView *)customView;
- (void)loadAndShowInKeyWindow:(UIWindow *)window customView:(UIView *)customView timeout:(NSInteger)timeout;
@property (nonatomic, weak) id <MTGSplashADDelegate> delegate;
@end
