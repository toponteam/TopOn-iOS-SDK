//
//  ATNetworkingManager.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 09/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ATNetworkingHTTPMethod) {
    ATNetworkingHTTPMethodGET = 0,
    ATNetworkingHTTPMethodPOST = 1
};

NS_ASSUME_NONNULL_BEGIN
extern NSString *const kAPIDomain;
@interface ATNetworkingManager : NSObject
+(NSString*)currentNetworkType;
+(instancetype)sharedManager;
/**
 * The data returned from the server are encrypted for which every api has its own decryption method; so the completion callback take a NSData as its parameter instead of an json object or a custom model.
 */
-(void) sendHTTPRequestToDomain:(NSString* const)domain path:(NSString*)path HTTPMethod:(ATNetworkingHTTPMethod)method parameters:(id)parameters completion:(void(^)(NSData *data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion;
-(void) sendHTTPRequestToAddress:(NSString*)address HTTPMethod:(ATNetworkingHTTPMethod)method parameters:(id)parameters completion:(void(^)(NSData *data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion;
-(void) sendHTTPRequestToAddress:(NSString*)address HTTPMethod:(ATNetworkingHTTPMethod)method parameters:(id)parameters gzip:(BOOL)gzip completion:(void(^)(NSData *data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion;
NS_ASSUME_NONNULL_END
@end

