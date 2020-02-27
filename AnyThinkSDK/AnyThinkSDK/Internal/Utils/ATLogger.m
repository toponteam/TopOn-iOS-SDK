//
//  ATLogger.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 28/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATLogger.h"
#import "ATAPI+Internal.h"
//ATLogTypeExternal for release
//ATLogTypeExternal | ATLogTypeInternal for test
static const ATLogType logType = ATLogTypeExternal | ATLogTypeTemporary;
@implementation ATLogger
+(void) logMessage:(NSString*)message type:(ATLogType)type {
    if ([self shouldLogType:type]) NSLog(@"ATLooger(%@) Message:%@", [ATAPI sharedInstance].version, message);
}

+(void) logWarning:(NSString*)warning type:(ATLogType)type {
    if ([self shouldLogType:type]) NSLog(@"ATLooger(%@) Warning:%@", [ATAPI sharedInstance].version, warning);
}

+(void) logError:(NSString*)error type:(ATLogType)type {
    if ([self shouldLogType:type]) NSLog(@"ATLooger(%@) Error:%@", [ATAPI sharedInstance].version, error);
}

+(BOOL) shouldLogType:(ATLogType)type {
    return (type & logType) && [ATAPI logEnabled];
}
@end
