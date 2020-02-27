//
//  ATThreadSafeAccessor.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATThreadSafeAccessor.h"
@interface ATThreadSafeAccessor()
@property(nonatomic, readonly) dispatch_queue_t data_access_control_queue;
@end
@implementation ATThreadSafeAccessor
-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _data_access_control_queue = dispatch_queue_create("dataAccessControlQueue.com.anythink", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(id) readWithBlock:(id(^)(void))readBlock {
    __block id returnValue = nil;
    dispatch_sync(_data_access_control_queue, ^{ returnValue = readBlock(); });
    return returnValue;
}

-(void) writeWithBlock:(void(^)(void))writeBlock {
    dispatch_barrier_async(_data_access_control_queue, writeBlock);
}
@end

@interface ATSerialThreadSafeAccessor()
@property(nonatomic, readonly) dispatch_queue_t data_access_queue;
@end
@implementation ATSerialThreadSafeAccessor
-(instancetype)init {
    self = [super init];
    if (self != nil) { _data_access_queue = dispatch_queue_create("com.anythink.serialAccessControlQueue", DISPATCH_QUEUE_SERIAL); }
    return self;
}

-(id) readWithBlock:(id (^)(void))readBlock {
    __block id returnValue = nil;
    dispatch_sync(_data_access_queue, ^{ returnValue = readBlock(); });
    return returnValue;
}

-(void) writeWithBlock:(void (^)(void))writeBlock {
    dispatch_async(_data_access_queue, writeBlock);
}
@end
