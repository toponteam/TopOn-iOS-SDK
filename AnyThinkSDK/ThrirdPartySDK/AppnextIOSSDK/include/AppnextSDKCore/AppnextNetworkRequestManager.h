//
//  AppnextNetworkRequestManager.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 13/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

@interface AppnextNetworkRequestManager : NSObject

AS_SINGLETON(AppnextNetworkRequestManager)

- (void) performNetworkSpeedTest;
- (double) getNetworkSpeed;

- (BOOL) getSettingsRequest:(NSString *)urlExtension  withParameters:(id)parameters completion:(success)completionBlock failed:(failure)failedBlock;
- (BOOL) getLookUpRequestWithCompletion:(success)completionBlock failed:(failure)failedBlock;
- (BOOL) getScriptRequest:(NSString *)urlExtension completion:(success)completionBlock failed:(failure)failedBlock;
- (BOOL) performAppnextApiRequest:(NSString *)urlExtension withHTTPMethod:(HTTPMethodType)httpMethodType withParameters:(id)parameters withBody:(NSData *)body completion:(success)completionBlock failed:(failure)failedBlock;
- (BOOL) performAppnextGlobalApiRequest:(NSString *)urlExtension withHTTPMethod:(HTTPMethodType)httpMethodType withParameters:(id)parameters withBody:(NSData *)body completion:(success)completionBlock failed:(failure)failedBlock;
- (BOOL) performNetworkTest:(success)completionBlock failed:(failure)failedBlock;
- (BOOL) downloadFileRequest:(NSString *)urlPath toFile:(NSString *)filePath completion:(success)completionBlock failed:(failure)failedBlock;
- (BOOL) performUrlRequest:(NSString *)url
            withHTTPMethod:(HTTPMethodType)httpMethodType
                  withBody:(NSData *)body
                completion:(success)completionBlock
                    failed:(failure)failedBlock
        ignoreReachability:(BOOL)ignore;
- (BOOL) performConnectionAppnextApiRequest:(NSMutableURLRequest *)request withUrl:(NSString *)url;

@end
