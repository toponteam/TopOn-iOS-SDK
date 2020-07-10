//
//  IALogger.h
//  IASDKCore
//
//  Created by Inneractive on 23/02/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @typedef IALogLevel
 *  @brief Log level.
 */
typedef NS_ENUM(NSUInteger, IALogLevel) {
    /**
     *  @brief Disabled.
     */
    IALogLevelOff = 0,
    /**
     *  @brief Includes error logging.
     */
    IALogLevelError = 1,
    /**
     *  @brief Includes warnings and error logging.
     */
    IALogLevelWarn = 2,
    /**
     *  @brief Includes general info., warnings and error logging.
     */
    IALogLevelInfo = 3,
    /**
     *  @brief Includes debug information, general info., warnings and error logging.
     */
    IALogLevelDebug = 4,
    /**
     *  @brief Includes all types of logging.
     */
    IALogLevelVerbose = 5,
};

@interface IALogger : NSObject

/**
 *  @brief Sets IASDK logging level for:
 *
 *  1. Xcode console
 *
 *  2. Apple System Logs
 *
 *  @param logLevel log level
 */
+ (void)setLogLevel:(IALogLevel)logLevel;
+ (IALogLevel)logLevel:(IALogLevel)logLevel;

@end
