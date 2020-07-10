//
//  IAInterfaceBuilder.h
//  IASDKCore
//
//  Created by Inneractive on 20/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#ifndef IAInterfaceBuilder_h
#define IAInterfaceBuilder_h

#import <Foundation/Foundation.h>

#import "IAInterfaceAllocBlocker.h"

@protocol IAInterfaceBuilder;

@protocol IAInterfaceBuilder <IAInterfaceAllocBlocker>

@required
+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAInterfaceBuilder> _Nonnull builder))buildBlock;

@end

#endif /* IAInterfaceBuilder_h */
