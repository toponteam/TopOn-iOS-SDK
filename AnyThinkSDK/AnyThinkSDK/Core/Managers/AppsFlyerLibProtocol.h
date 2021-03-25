//
//  AppsFlyerLibProtocol.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/11/3.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppsFlyerLibProtocol <NSObject>

+ (instancetype _Nullable)shared;
- (void)logEvent:(NSString *_Nullable)eventName withValues:(NSDictionary * _Nullable)values;

@end
