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

@protocol ATWindAdOptions<NSObject>
@property (copy, nonatomic) NSString* appId;
@property (copy, nonatomic) NSString* apiKey;
+ (instancetype)options;
@end

@protocol ATWindAds<NSObject>
+ (void) startWithOptions:(nullable id<ATWindAdOptions>)options;
+ (NSString * _Nonnull)sdkVersion;
@end

@protocol WindSplashAdDelegate<NSObject>
@end
@protocol ATWindSplashAd<NSObject>
@property (nonatomic,weak) id<WindSplashAdDelegate> delegate;
@property (nonatomic, assign) int fetchDelay;
- (instancetype)initWithPlacementId:(NSString *)placementId;
-(void)loadAdAndShowWithBottomView:(UIView *)bottomView;
@end
