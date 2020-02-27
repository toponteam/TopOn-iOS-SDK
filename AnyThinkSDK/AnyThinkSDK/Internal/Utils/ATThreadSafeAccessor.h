//
//  ATThreadSafeAccessor.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 Thread safe accessor provide a way to make data access thread-safe. Client can create an instance of this class for each piece of data which needs protecting and read/write that data using one of the read/write method, providing the read/write block; the blocks provided will be executed in a thread-safe environment.
 To be more specific, multiple read blocks can run in parallel from multiple threads; but the write blocks are critical section that can't be retered.
 */
@interface ATThreadSafeAccessor : NSObject
-(id) readWithBlock:(id(^)(void))readBlock;

-(void) writeWithBlock:(void(^)(void))writeBlock;
@end

@interface ATSerialThreadSafeAccessor:NSObject
-(id) readWithBlock:(id(^)(void))readBlock;
-(void) writeWithBlock:(void(^)(void))writeBlock;
@end
