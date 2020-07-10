//
//  ATChartboostBannerAdapter.h
//  AnyThinkChartboostBannerAdapter
//
//  Created by Martin Lau on 2020/6/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATChartboostBannerAdapter : NSObject
@end

@protocol ATChartboost<NSObject>
+ (void)startWithAppId:(NSString*)appId appSignature:(NSString*)appSignature completion:(void (^)(BOOL))completion;
+ (NSString*)getSDKVersion;
@end

@protocol CHBBannerDelegate <NSObject>
@end

@protocol ATCHBBanner <NSObject>
@property (nonatomic) BOOL automaticallyRefreshesContent;
@property(nonatomic) CGRect            frame;
- (instancetype)initWithSize:(CGSize)size location:(NSString*)location delegate:(id<CHBBannerDelegate>)delegate;
- (void)cache;
- (void)showFromViewController:(UIViewController *)viewController;
@end

@protocol ATCHBCacheEvent<NSObject>
@property (nonatomic, readonly) id<ATCHBBanner> ad;
@end

@protocol ATCHBError<NSObject>
@property (nonatomic, readonly) NSUInteger code;
@end
