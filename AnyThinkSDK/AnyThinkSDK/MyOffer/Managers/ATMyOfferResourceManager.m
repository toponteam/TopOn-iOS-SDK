//
//  ATMyOfferResourceManager.m
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferResourceManager.h"
#import "ATMyOfferOfferManager.h"
#import "ATThreadSafeAccessor.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATMyOfferResourceLoader.h"
@interface ATMyOfferResourceManager()
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDictionary*> *resourceDictionaryStorage;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, ATMyOfferResourceModel*> *resourceStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *resourceStorageAccessor;
@end
@implementation ATMyOfferResourceManager
+(NSString*)resourceDictionaryPath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.MyOfferMetadata"];
}

+(instancetype) sharedManager {
    static ATMyOfferResourceManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATMyOfferResourceManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _resourceDictionaryStorage = [[NSMutableDictionary alloc] initWithContentsOfFile:[ATMyOfferResourceManager resourceDictionaryPath]];
        _resourceStorage = [NSMutableDictionary<NSString*, ATMyOfferResourceModel*> dictionary];
        if ([_resourceDictionaryStorage isKindOfClass:[NSMutableDictionary<NSString*, NSDictionary*> class]]) {
            __weak typeof(self) weakSelf = self;
            [_resourceDictionaryStorage enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
                ATMyOfferResourceModel *resourceModel = [[ATMyOfferResourceModel alloc] initWithDictionary:obj];
                if (resourceModel != nil) { weakSelf.resourceStorage[key] = resourceModel; }
            }];
        } else {
            _resourceDictionaryStorage = [NSMutableDictionary<NSString*, NSDictionary*> dictionary];
        }
        _resourceStorageAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

-(void) saveResourceModel:(ATMyOfferResourceModel*)resourceModel forResourceID:(NSString*)resourceID {
    if ([resourceModel isKindOfClass:[ATMyOfferResourceModel class]] && [resourceModel dictionary] != nil && resourceID != nil) {
        __weak typeof(self) weakSelf = self;
        [_resourceStorageAccessor writeWithBlock:^{
            weakSelf.resourceStorage[resourceID] = resourceModel;
            weakSelf.resourceDictionaryStorage[resourceID] = [resourceModel dictionary];
            [weakSelf.resourceDictionaryStorage writeToFile:[ATMyOfferResourceManager resourceDictionaryPath] atomically:YES];
            
            //Remove
            NSUInteger maxSize = [[ATAppSettingManager sharedManager] myOfferMaxResourceLength];
            NSUInteger totalLength = [[[weakSelf.resourceStorage allValues] valueForKeyPath:@"@sum.length"] unsignedIntegerValue];
            if (totalLength > maxSize) {
                NSArray<NSString*> *auxiliary = [weakSelf.resourceStorage keysSortedByValueUsingComparator:^NSComparisonResult(ATMyOfferResourceModel*  _Nonnull obj1, ATMyOfferResourceModel*  _Nonnull obj2) {
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
                [weakSelf.resourceDictionaryStorage writeToFile:[ATMyOfferResourceManager resourceDictionaryPath] atomically:YES];
            }
        }];
    }
}

-(ATMyOfferResourceModel*)retrieveResourceModelWithResourceID:(NSString*)resourceID {
    __weak typeof(self) weakSelf = self;
    if ([resourceID isKindOfClass:[NSString class]]) {
        return [_resourceStorageAccessor readWithBlock:^id{
            ATMyOfferResourceModel *resourceModel = weakSelf.resourceStorage[resourceID];
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
            ATMyOfferResourceModel *resourceModel = weakSelf.resourceStorage[resourceID];
            if ([resourceModel isKindOfClass:[ATMyOfferResourceModel class]]) {
                [resourceModel updateLastUseDate];
                weakSelf.resourceDictionaryStorage[resourceID] = [resourceModel dictionary];
                [weakSelf.resourceDictionaryStorage writeToFile:[ATMyOfferResourceManager resourceDictionaryPath] atomically:YES];
            }
        }];
    }
}

-(NSString*) resourcePathForOfferModel:(ATMyOfferOfferModel*)offerModel resourceURL:(NSString*)URL {
    if ([offerModel.offerID isKindOfClass:[NSString class]] && [offerModel.offerID length] > 0 && [URL isKindOfClass:[NSString class]] && [URL length] > 0) {
        __weak typeof(self) weakSelf = self;
        return [_resourceStorageAccessor readWithBlock:^id{
            return [weakSelf.resourceStorage[offerModel.resourceID] resourcePathForURL:URL];
        }];
    } else {
        return nil;
    }
}
@end
