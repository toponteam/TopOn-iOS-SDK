//
//  IAInterfaceAllocBlocker.h
//  IASDKCore
//
//  Created by Inneractive on 22/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#ifndef IAInterfaceAllocBlocker_h
#define IAInterfaceAllocBlocker_h

#import <Foundation/Foundation.h>

@protocol IAInterfaceAllocBlocker <NSObject>

@required
+ (null_unspecified instancetype)alloc __attribute__((unavailable("<Inneractive> The 'alloc' is not available, use 'build:' instead.")));
- (null_unspecified instancetype)init __attribute__((unavailable("<Inneractive> The 'init' is not available, use 'build:' instead.")));
+ (null_unspecified instancetype)new __attribute__((unavailable("<Inneractive> The 'new' is not available, use 'build:' instead.")));

@end

#endif /* IAInterfaceAllocBlocker_h */
