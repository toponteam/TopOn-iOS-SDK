//
//  AppnextResourceLoader.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 17/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import "NSData+AppnextBase64.h"
@class AppnextResourceLoader;


typedef NS_ENUM(NSUInteger, ANResourceOrigin)
{
    ANResourceOriginNone,
    ANResourceOriginInternal,
    ANResourceOriginServer
};

@protocol AppnextResourceLoaderDelegate <NSObject>
@optional
- (void) loadedResource:(id)resource byLoader:(AppnextResourceLoader *)loader;
- (void) failedLoadingResource:(NSString *)error byLoader:(AppnextResourceLoader *)loader;
@end

@interface AppnextResourceLoader : NSObject

@property (nonatomic, strong, readonly) id loadedResource;
@property (nonatomic, assign, readonly) ANResourceOrigin resourceOrigin;

- (BOOL) isLoaded;
- (void) getResource:(id<AppnextResourceLoaderDelegate>)delegate origin:(ANResourceOrigin)origin withTid:(NSString *) TID;
+ (NSString *) getVideoUrlStringForAd:(AppnextAdData *)adData withLengthType:(ANVideoLength) videoLength;
@end
