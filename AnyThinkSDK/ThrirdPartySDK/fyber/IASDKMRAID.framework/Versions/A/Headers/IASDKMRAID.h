//
//  IASDKMRAID.h
//  IASDKMRAID
//
//  Created by Inneractive on 02/02/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceSingleton.h>

#import "IAMRAIDContentController.h"
#import "IAMRAIDContentDelegate.h"
#import "IAMRAIDContentModel.h"

@interface IASDKMRAID : NSObject <IAInterfaceSingleton>

/**
 *  @brief Singleton method, use for any instance call.
 */
+ (instancetype)sharedInstance;

@end
