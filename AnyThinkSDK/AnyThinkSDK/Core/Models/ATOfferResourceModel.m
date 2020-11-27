//
//  ATOfferResourceModel.m
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATOfferResourceModel.h"
#import "ATOfferResourceLoader.h"
#import "Utilities.h"

static NSString *const kCacheDateKey = @"cache_date";
static NSString *const kLastUseDateKey = @"last_use_date";
static NSString *const kResourcePathsKey = @"resource_paths";
static NSString *const kLengthKey = @"length";
@interface ATOfferResourceModel()
@property(nonatomic, readonly) NSMutableDictionary *resourcePaths;
@end
@implementation ATOfferResourceModel
/*
 * For resource manager to unarchive resource models from disk
 */
-(instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        _cacheDate = dictionary[kCacheDateKey];
        _lastUseDate = dictionary[kLastUseDateKey];
        _resourcePaths = [NSMutableDictionary dictionary];
        NSDictionary *resourcePaths = dictionary[kResourcePathsKey];
        [resourcePaths enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) { self->_resourcePaths[key] = [[ATOfferResourceLoader resourceRootPath] stringByAppendingPathComponent:[obj lastPathComponent]]; }
        }];
        _length = [dictionary[kLengthKey] unsignedIntegerValue];
    }
    return self;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _cacheDate = [NSDate date];
        _resourcePaths = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSArray<NSString*>*) allResourcePaths {
    return [_resourcePaths allValues];
}

-(NSString*) resourcePathForURL:(NSString*)URL {
    return _resourcePaths[URL.md5];
}

-(void) accumulateLength:(NSUInteger)length {
    _length += length;
}

-(void) setResourcePath:(NSString*)path forURL:(NSString*)URL {
    if ([path isKindOfClass:[NSString class]] && [path length] > 0 && [URL isKindOfClass:[NSString class]] && [URL length] > 0) { _resourcePaths[URL.md5] = path; }
}

-(void) updateLastUseDate {
    _lastUseDate = [NSDate date];
}

-(NSDictionary*)dictionary {
    return @{kCacheDateKey:_cacheDate != nil ? _cacheDate : [NSDate date],
             kLastUseDateKey:_lastUseDate != nil ? _lastUseDate : [NSDate date],
             kResourcePathsKey:[_resourcePaths isKindOfClass:[NSDictionary class]] ? _resourcePaths : @{},
             kLengthKey:@(_length)
             };
}

+(instancetype) mockResourceModel {
    return [[self alloc] initWithDictionary:@{kCacheDateKey:[NSDate date], kResourcePathsKey:@{@"9877fb5bf2f9ebc0bae4ff7f10de54b9":[[NSBundle mainBundle] pathForResource:@"9877fb5bf2f9ebc0bae4ff7f10de54b9" ofType:@"png"],
                                                                                               @"0c2f8e141e39e204b4f48b31aa0b8e28":[[NSBundle mainBundle] pathForResource:@"0c2f8e141e39e204b4f48b31aa0b8e28" ofType:@"jpg"],
                                                                                               @"63a94d91a051de9b608d756fdf2839bd":[[NSBundle mainBundle] pathForResource:@"40f3954c76f395e6a39b072244244db5" ofType:@"mp4"]
                                                                                               }, kLengthKey:@(1024 * 1024)}];
}
@end
