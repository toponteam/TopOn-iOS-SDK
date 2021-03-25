//
//  ATChartboostInterstitialAdapter.h
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface ATChartboostInterstitialAdapter : NSObject
@end

@protocol CHBAdDelegate <NSObject>
@end
@protocol CHBDismissableAdDelegate <CHBAdDelegate>
@end
@protocol CHBInterstitialDelegate <CHBDismissableAdDelegate>
@end

@protocol ATCHBInterstitial<NSObject>
@property (nonatomic, weak) id<CHBInterstitialDelegate> delegate;
@property (nonatomic, readonly) BOOL isCached;
- (instancetype)initWithLocation:(NSString*)location delegate:(id<CHBInterstitialDelegate>)delegate;
- (void)cache;
- (void)showFromViewController:(UIViewController *)viewController;
@end

@protocol ATCHBError<NSObject>
@property (nonatomic, readonly) NSUInteger code;
@end

NS_ASSUME_NONNULL_END
