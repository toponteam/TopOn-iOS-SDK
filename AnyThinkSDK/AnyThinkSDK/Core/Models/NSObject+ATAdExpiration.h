//
//  NSObject+ATAdExpiration.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/2/21.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSObject (ATAdExpiration)
//Calculated by cacheDate and networkCacheTime in unitGroupModel
-(BOOL) expired;
@end
