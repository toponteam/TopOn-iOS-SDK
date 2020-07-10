//
//  SMLog.h
//  SigmobDemo
//
//  Created by happyelements on 03/04/2018.
//  Copyright © 2018 Codi. All rights reserved.
//

#ifndef SIGLog_h
#define SIGLog_h

#ifdef __cplusplus
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SIGLogLevel){
    SIGLogLevelDebug=2,
    SIGLogLevelInfo=4,
    SIGLogLevelWarning=6,
    SIGLogLevelError=8,
    
};


#define SIGLog(level, ...) \
{ \
SMLogEx(level, @(__FILE__), @(__PRETTY_FUNCTION__), __LINE__, nil, __VA_ARGS__); \
}



//! Log to Error level
#define SIGLogError(...)        SIGLog(SIGLogLevelError,__VA_ARGS__)
//! Log to Warning level
#define SIGLogWarning(...)      SIGLog(SIGLogLevelWarning,  __VA_ARGS__)
//! Log to Information level
#define SIGLogInfo(...)         SIGLog(SIGLogLevelInfo,  __VA_ARGS__)
//! Log to Debug level
#define SIGLogDebug(...)        SIGLog(SIGLogLevelDebug, __VA_ARGS__)




FOUNDATION_EXPORT void SMLogEx(SIGLogLevel level,
                                NSString *file,
                                NSString *function,
                                unsigned int line,
                                id __nullable contextObject,
                                NSString *format, ...) NS_FORMAT_FUNCTION(6,7);



NS_ASSUME_NONNULL_END

#endif /* SMLog_h */
