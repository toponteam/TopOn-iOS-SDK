//
//  IASDKVideo.h
//  IASDKVideo
//
//  Created by Inneractive on 01/02/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceSingleton.h>

#import "IAVideoContentController.h"
#import "IAVideoContentDelegate.h"
#import "IAVideoLayout.h"
#import "IAVideoContentModel.h"
#import "IAVideoView.h"

/**
 *  @brief Should not be used never.
 */
extern NSString * const _Nonnull kIAVPAIDPlayerURLString;

@interface IASDKVideo : NSObject <IAInterfaceSingleton>

/**
 *  @brief Singleton method, use for any instance call.
 */
+ (instancetype _Null_unspecified)sharedInstance;

@end
