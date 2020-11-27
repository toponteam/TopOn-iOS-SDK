//
//  ATOfferResourceManager.m
//  AnyThinkOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATOfferResourceManager.h"
#import "ATThreadSafeAccessor.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATOfferResourceLoader.h"


@interface ATOfferResourceManager()
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDictionary*> *resourceDictionaryStorage;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, ATOfferResourceModel*> *resourceStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *resourceStorageAccessor;
@end
@implementation ATOfferResourceManager
+(NSString*)resourceDictionaryPath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.OfferMetadata"];
}

+(instancetype) sharedManager {
    static ATOfferResourceManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATOfferResourceManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _resourceDictionaryStorage = [[NSMutableDictionary alloc] initWithContentsOfFile:[ATOfferResourceManager resourceDictionaryPath]];
        _resourceStorage = [NSMutableDictionary<NSString*, ATOfferResourceModel*> dictionary];
        if ([_resourceDictionaryStorage isKindOfClass:[NSMutableDictionary<NSString*, NSDictionary*> class]]) {
            __weak typeof(self) weakSelf = self;
            [_resourceDictionaryStorage enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
                ATOfferResourceModel *resourceModel = [[ATOfferResourceModel alloc] initWithDictionary:obj];
                if (resourceModel != nil) { weakSelf.resourceStorage[key] = resourceModel; }
            }];
        } else {
            _resourceDictionaryStorage = [NSMutableDictionary<NSString*, NSDictionary*> dictionary];
        }
        _resourceStorageAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

-(void) saveResourceModel:(ATOfferResourceModel*)resourceModel forResourceID:(NSString*)resourceID {
    if ([resourceModel isKindOfClass:[ATOfferResourceModel class]] && [resourceModel dictionary] != nil && resourceID != nil) {
        __weak typeof(self) weakSelf = self;
        [_resourceStorageAccessor writeWithBlock:^{
            weakSelf.resourceStorage[resourceID] = resourceModel;
            weakSelf.resourceDictionaryStorage[resourceID] = [resourceModel dictionary];
            [weakSelf.resourceDictionaryStorage writeToFile:[ATOfferResourceManager resourceDictionaryPath] atomically:YES];
            
            //Remove
            NSUInteger maxSize = [[ATAppSettingManager sharedManager] myOfferMaxResourceLength];
            NSUInteger totalLength = [[[weakSelf.resourceStorage allValues] valueForKeyPath:@"@sum.length"] unsignedIntegerValue];
            if (totalLength > maxSize) {
                NSArray<NSString*> *auxiliary = [weakSelf.resourceStorage keysSortedByValueUsingComparator:^NSComparisonResult(ATOfferResourceModel*  _Nonnull obj1, ATOfferResourceModel*  _Nonnull obj2) {
                    return [obj1.lastUseDate compare:obj2.lastUseDate];
                }];
                NSMutableArray<NSString*>* resourceIDsToBeRemoved = [NSMutableArray<NSString*> array];
                __block NSUInteger removeSize = 0;
                [auxiliary enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    removeSize += weakSelf.resourceStorage[obj].length;
                    [resourceIDsToBeRemoved addObject:obj];
                    if (totalLength - removeSize < maxSize) { *stop = YES; }
                }];
                [resourceIDsToBeRemoved enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [[weakSelf.resourceStorage[obj] allResourcePaths] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [[NSFileManager defaultManager] removeItemAtPath:obj error:nil]; }];
                }];
                [weakSelf.resourceStorage removeObjectsForKeys:resourceIDsToBeRemoved];
                [weakSelf.resourceDictionaryStorage removeObjectsForKeys:resourceIDsToBeRemoved];
                [weakSelf.resourceDictionaryStorage writeToFile:[ATOfferResourceManager resourceDictionaryPath] atomically:YES];
            }
        }];
    }
}

-(ATOfferResourceModel*)retrieveResourceModelWithResourceID:(NSString*)resourceID {
    __weak typeof(self) weakSelf = self;
    if ([resourceID isKindOfClass:[NSString class]]) {
        return [_resourceStorageAccessor readWithBlock:^id{
            ATOfferResourceModel *resourceModel = weakSelf.resourceStorage[resourceID];
            __block BOOL resourceNotExisted = YES;
            [resourceModel.allResourcePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { resourceNotExisted = *stop = ![[NSFileManager defaultManager] fileExistsAtPath:obj]; }];
            return !resourceNotExisted ? resourceModel : nil;
        }];
    } else {
        return nil;
    }
}

-(void) updateLastUseDateForResourceWithResourceID:(NSString*)resourceID {
    if ([resourceID isKindOfClass:[NSString class]]) {
        __weak typeof(self) weakSelf = self;
        [_resourceStorageAccessor writeWithBlock:^{
            ATOfferResourceModel *resourceModel = weakSelf.resourceStorage[resourceID];
            if ([resourceModel isKindOfClass:[ATOfferResourceModel class]]) {
                [resourceModel updateLastUseDate];
                weakSelf.resourceDictionaryStorage[resourceID] = [resourceModel dictionary];
                [weakSelf.resourceDictionaryStorage writeToFile:[ATOfferResourceManager resourceDictionaryPath] atomically:YES];
            }
        }];
    }
}

-(NSString*) resourcePathForOfferModel:(ATOfferModel*)offerModel resourceURL:(NSString*)URL {
    if ([offerModel.offerID isKindOfClass:[NSString class]] && [offerModel.offerID length] > 0 && [URL isKindOfClass:[NSString class]] && [URL length] > 0) {
        __weak typeof(self) weakSelf = self;
        return [_resourceStorageAccessor readWithBlock:^id{
            return [weakSelf.resourceStorage[offerModel.localResourceID] resourcePathForURL:URL];
        }];
    } else {
        return nil;
    }
}

-(UIImage *) imageForOfferModel:(ATOfferModel*)offerModel resourceURL:(NSString*)URL {
    NSString * path = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:offerModel resourceURL:URL];
    return path != nil ? [UIImage imageWithData:[NSData dataWithContentsOfFile:path]] : nil;
}

@end
