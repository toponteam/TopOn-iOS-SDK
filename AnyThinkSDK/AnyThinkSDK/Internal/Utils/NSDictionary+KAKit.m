//
//  NSDictionary+KAKit.m
//  Demo
//
//  Created by Martin Lau on 27/03/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "NSDictionary+KAKit.h"
#import "Utilities.h"

@implementation NSDictionary (KAKit)
-(NSString*) jsonString_anythink {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:kNilOptions
                                                         error:&error];
    
    if (!jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

-(BOOL)containsObjectForKey:(id)key {
    BOOL ret = NO;
    @try {
        ret = [self.allKeys containsObject:key];
    } @catch (NSException *exception) {
        [ATLogger logError:[NSString stringWithFormat:@"Expretion occured:%@", exception] type:ATLogTypeInternal];
    } @finally {
        return ret;
    }
}

-(NSDictionary*)calculateObjectChangeStringForKey{
    NSMutableDictionary * customData = [NSMutableDictionary dictionary];
    if ([self count] > 0) { [customData addEntriesFromDictionary:self]; }
    NSArray<NSString*>* keys = [customData allKeys];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { customData[obj] = [NSString stringWithFormat:@"%@", customData[obj]]; }];
    return customData;
}

@end

@interface ATWeakDictionarySlot:NSObject
+(instancetype) slotWithObject:(__weak id)object;
@property(nonatomic, weak) id object;
@end
@implementation ATWeakDictionarySlot
-(instancetype) initWithObject:(__weak id)object {
    self = [super init];
    if (self != nil) { _object = object; }
    return self;
}

+(instancetype) slotWithObject:(__weak id)object {
    return [[ATWeakDictionarySlot alloc] initWithObject:object];
}
@end

@implementation NSMutableDictionary (Weakly)
-(void) AT_setWeakObject:(__weak id)anObject forKey:(id<NSCopying>)aKey {
    if (aKey != nil) { self[aKey] = [ATWeakDictionarySlot slotWithObject:anObject]; }
}

-(id) AT_weakObjectForKey:(id)aKey {
    return ((ATWeakDictionarySlot*)self[aKey]).object;
}

-(void) AT_removeWeakObjectForKey:(id)key {
    if (key != nil) { [self removeObjectForKey:key]; }
}

@end
