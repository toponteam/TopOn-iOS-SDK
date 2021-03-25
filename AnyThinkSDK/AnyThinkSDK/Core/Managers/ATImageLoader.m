//
//  ATImageLoader.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATImageLoader.h"
#import "ATThreadSafeAccessor.h"
#import "Utilities.h"
@interface ATImageLoader()
@property(nonatomic, readonly) NSMutableDictionary *cache;
@property(nonatomic, readonly) ATThreadSafeAccessor *cacheAccessor;
@end
@implementation ATImageLoader
+(instancetype)shareLoader {
    static ATImageLoader *shareLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareLoader = [[ATImageLoader alloc] init];
    });
    return shareLoader;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _cache = [NSMutableDictionary<NSString*, UIImage*> dictionary];
        _cacheAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

-(void) loadImageWithURL:(NSURL*)URL completion:(void(^)(UIImage *image, NSError *error))completion {
    if ([Utilities isEmpty:URL]) {
        if (completion) {
            NSString *reason = [NSString stringWithFormat:@"URL:%@ is nil or uncorrect",URL.absoluteString];
            NSError *error = [NSError errorWithDomain:reason code:1 userInfo:nil];
            completion(nil,error);
        }
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //Check the cache first before attempting the downloading/read from disk.
        UIImage *image = [self cachedImageWithURL:URL];
        
        //If the cache doesn't contain the requited image, kick off the download/read.
        NSError *error = nil;
        if (image == nil) {
            NSData *data = [NSData dataWithContentsOfURL:URL options:NSDataReadingUncached error:&error];
            image = [UIImage imageWithData:data];
            if (image != nil) [self cacheImage:image URL:URL];
        }
        
        //Invoke the callback with the image(if download/read has been successful) and the error(if any occured).
        if (completion != nil) completion(image, error);
    });
}

static NSString *LastAccessingDateKey = @"last_accessing_date";
static NSString *ImageKey = @"image";
static NSInteger MaxCachedNumber = 16;
/**
 * The structure of the cache is as follows:
 *{
 *  url_md5:
 *          {
 *              image:the_image,
 *              update_date:2018/05/15, 10:23AM
 *          }
 *}
 * At most MaxCachedNumber image will be cached; it this limit is exceeded, half the most ancient images will be removed, keeping the latest ones.
 */
-(void) cacheImage:(UIImage*)image URL:(NSURL*)URL {
    if (image != nil && URL != nil) {
        NSString *key = [URL.absoluteString md5];
        [_cacheAccessor writeWithBlock:^{
            _cache[key] = @{LastAccessingDateKey:[NSDate date], ImageKey:image};
            if ([_cache count] > MaxCachedNumber) {
                NSArray<NSString*> *sortedKeys = [_cache keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj1[LastAccessingDateKey] compare:obj2[LastAccessingDateKey]];
                }];
                for (NSInteger i = [sortedKeys count] / 2; i < [sortedKeys count]; i++) {
                    [_cache removeObjectForKey:sortedKeys[i]];
                }
            }
        }];
    }
}

-(UIImage*)cachedImageWithURL:(NSURL*)URL {
    NSString *key = [URL.absoluteString md5];
    //Update the last accessing date in the cache.
    [_cacheAccessor writeWithBlock:^{
        if ([_cache containsObjectForKey:key]) {
            _cache[key] = @{LastAccessingDateKey:[NSDate date], ImageKey:_cache[key][ImageKey]};
        }
    }];
    return [_cacheAccessor readWithBlock:^id{ return _cache[key][ImageKey]; }];
}
@end
