//
//  TopOnAdManager.h
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2020/1/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSInteger const TopOnAPITypeTopOn;

@interface TopOnAdManager : NSObject
+(instancetype) sharedManager;
@property (atomic, readwrite) NSInteger currentAPIType;
-(void) initSDKAPIWithAPIType:(NSInteger)apiType;
-(void) initSDKAPIWithAppID:(NSString*)appID appKey:(NSString*)appKey;
@end

NS_ASSUME_NONNULL_END
