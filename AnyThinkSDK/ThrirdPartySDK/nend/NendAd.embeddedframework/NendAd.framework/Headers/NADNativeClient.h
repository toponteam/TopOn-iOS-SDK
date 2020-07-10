//
//  NADNativeClient.h
//  NendAd
//
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NADNative.h"
#import "NADNativeError.h"
#import "NADNativeLogger.h"

typedef void (^NADNativeCompletionBlock)(NADNative *ad, NSError *error);

@interface NADNativeClient : NSObject

/**
 * Initializes a client object.
 *
 * @return A NADNativeClient object.
 */
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;

/**
 * Load native ad.
 */
- (void)loadWithCompletionBlock:(NADNativeCompletionBlock)completionBlock;

/**
 * Enable auto reload.
 */
- (void)enableAutoReloadWithInterval:(NSTimeInterval)interval completionBlock:(NADNativeCompletionBlock)completionBlock;

/**
 * Disable auto reload.
 */
- (void)disableAutoReload;

@end
