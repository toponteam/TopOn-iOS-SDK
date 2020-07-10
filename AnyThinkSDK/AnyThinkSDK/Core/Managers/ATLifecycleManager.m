//
//  ATLifecycleManager.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/3/18.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATLifecycleManager.h"
#import "ATAgentEvent.h"
@interface ATLifecycleManager()
@property(atomic) NSDate *SDKinitDate;
@property(atomic) NSDate *lastActivateDate;
@end

@implementation ATLifecycleManager
+(instancetype) sharedManager {
    static ATLifecycleManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATLifecycleManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(void) saveSDKInitEvent {
    self.SDKinitDate = [NSDate date];
}

-(void) handleApplicationDidBecomeActiveNotification:(NSNotification*)notification {
    self.lastActivateDate = [NSDate date];
}

-(void) handleApplicationWillResignActiveNotification:(NSNotification*)notification {
    NSDate *date = [NSDate date];
    NSDate *startDate = self.SDKinitDate ? self.SDKinitDate : self.lastActivateDate;
    NSTimeInterval startTime = [startDate timeIntervalSince1970];
    NSTimeInterval endTime = [date timeIntervalSince1970];
    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyAppLifecycleKey placementID:nil unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoLifecycleEventTypeKey:@(self.SDKinitDate ? 1 : 2),
                                                                                                                                kAgentEventExtraInfoActivateTimeKey:@((NSInteger)(startTime * 1000.0f)),
                                                                                                                                kAgentEventExtraInfoResignActiveTimeKey:@((NSInteger)(endTime * 1000.0f)),
                                                                                                                                kAgentEventExtraInfoLifecycleIntervalKey:@((NSInteger)((endTime - startTime) * 1000.0f))
    }];
    self.SDKinitDate = self.lastActivateDate = nil;
}
@end
