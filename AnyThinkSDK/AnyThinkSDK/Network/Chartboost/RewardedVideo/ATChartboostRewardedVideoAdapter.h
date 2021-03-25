//
//  ATChartboostRewardedVideoAdapter.h
//  ATChartboostRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRewardedVideoAdapter.h"
@interface ATChartboostRewardedVideoAdapter : NSObject
@end

@protocol CHBAdDelegate <NSObject>
@end

@protocol CHBDismissableAdDelegate <CHBAdDelegate>
@end

@protocol CHBRewardableAdDelegate <CHBAdDelegate>
@end

@protocol CHBRewardedDelegate <CHBDismissableAdDelegate, CHBRewardableAdDelegate>
@end

@protocol ATCHBRewarded<NSObject>
@property (nonatomic, weak) id<CHBRewardedDelegate> delegate;
@property (nonatomic, readonly) BOOL isCached;
- (instancetype)initWithLocation:(NSString*)location delegate:(id<CHBRewardedDelegate>)delegate;
- (void)cache;
- (void)showFromViewController:(UIViewController *)viewController;
@end

@protocol ATCHBError<NSObject>
@property (nonatomic, readonly) NSUInteger code;
@end
