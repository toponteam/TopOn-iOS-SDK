//
//  IAInterfaceSingleton.h
//  IASDKCore
//
//  Created by Inneractive on 22/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#ifndef IAInterfaceSingleton_h
#define IAInterfaceSingleton_h

#import <Foundation/Foundation.h>

#import "IAInterfaceAllocBlocker.h"

@protocol IAInterfaceSingleton <IAInterfaceAllocBlocker>

@required
+ (instancetype _Nonnull)sharedInstance;

@end

#endif /* IAInterfaceSingleton_h */
