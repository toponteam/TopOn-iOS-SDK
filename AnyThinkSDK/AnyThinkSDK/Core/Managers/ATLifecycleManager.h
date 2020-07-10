//
//  ATLifecycleManager.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/3/18.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATLifecycleManager : NSObject
-(void) saveSDKInitEvent;
+(instancetype) sharedManager;
@end
