//
//  CTNativeVideoDelegate.h
//  CTSDK
//
//  Created by yeahmobi on 2018/2/27.
//  Copyright © 2018年 Mirinda. All rights reserved.
//

#ifndef CTNativeVideoDelegate_h
#define CTNativeVideoDelegate_h

@class CTNativeVideoModel;

@protocol CTNativeVideoDelegate <NSObject>

@optional
/**
 * Advertisement load success.
 */
-(void)CTNativeVideoLoadSuccess:(CTNativeVideoModel *)nativeVideoModel;

/**
 * Advertisement load failed.
 */
-(void)CTNativeVideoLoadFailed:(NSError *)error;


@end

#endif /* CTNativeVideoDelegate_h */
