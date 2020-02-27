//
//  ATLogger.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 28/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, ATLogType) {
    ATLogTypeNone = 0,
    ATLogTypeInternal = 1 << 0,
    ATLogTypeExternal = 1 << 1,
    ATLogTypeTemporary = 1 << 2
};
@interface ATLogger : NSObject
+(void) logMessage:(NSString*)message type:(ATLogType)type;
+(void) logWarning:(NSString*)warning type:(ATLogType)type;
+(void) logError:(NSString*)error type:(ATLogType)type;
@end
