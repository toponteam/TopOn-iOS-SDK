//
//  NADNativeVideoLoader.h
//  NendAdFramework
//
//  Copyright © 2018年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NADNativeVideo.h"
#import "NADUserFeature.h"

NS_ASSUME_NONNULL_BEGIN
@interface NADNativeVideoLoader : NSObject

@property (readwrite, nonatomic, copy, nullable) NSString *userId;
@property (readwrite, nonatomic, copy, nullable) NSString *mediationName;
@property (readwrite, nonatomic, strong, nullable) NADUserFeature *userFeature;
@property (readwrite, nonatomic) BOOL isLocationEnabled;

- (instancetype _Null_unspecified)init NS_UNAVAILABLE;
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey clickAction:(NADNativeVideoClickAction)action;

- (void)setFillerStaticNativeAdId:(NSString *)spotId apiKey:(NSString *)apiKey;
- (void)loadAdWithCompletionHandler:(void(^)(NADNativeVideo * _Nullable, NSError * _Nullable))handler;

@end
NS_ASSUME_NONNULL_END
