//
//  NSDictionary+KAKit.h
//  Demo
//
//  Created by Martin Lau on 27/03/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KAKit)
-(NSString*) jsonString_anythink;
-(BOOL)containsObjectForKey:(id)key;
@end

@interface NSMutableDictionary(Weakly)
-(void) AT_setWeakObject:(__weak id)anObject forKey:(id<NSCopying>)aKey;
-(id) AT_weakObjectForKey:(id)aKey;
-(void) AT_removeWeakObjectForKey:(id)key;
@end
