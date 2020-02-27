//
//  NADLogger.h
//  NendAdFramework
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NADLogLevel) {
    NADLogLevelDebug = 1,
    NADLogLevelInfo  = 2,
    NADLogLevelWarn  = 3,
    NADLogLevelError = 4,
    NADLogLevelOff   = INT_MAX
};

@protocol NADLogging

- (void)logMessage:(NSString *)message logLevel:(NADLogLevel)logLevel;

@end

@interface NADLogger : NSObject

@property (nonatomic) id<NADLogging> logger;

+ (instancetype)sharedInstance;
+ (void)setLogLevel:(NADLogLevel)logLevel;

@end
