//
//  ATNetworkingManager.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 09/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNetworkingManager.h"
#import "ATAPI.h"
#import "Utilities.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@interface ATNetworkingManager()<NSURLSessionDelegate>
@property(nonatomic, readonly) NSURLSession *URLSession;
@end

#ifdef UNDER_DEVELOPMENT
NSString *const kAPIDomain = @"test.aa.toponad.com";//@"18.140.1.181:8080";//@"test.go-api.toponad.com";//@"test.aa.toponad.com";//
NSString *const kTrackDomain = @"test.tk.toponad.com";
NSString *const kAgentDomain = @"test.tk.toponad.com";
#else
NSString *const kAPIDomain = @"aa.toponad.com";//@"52.2.132.38:3020";//
NSString *const kTrackDomain = @"tk.toponad.com";
NSString *const kAgentDomain = @"tk.toponad.com";
#endif

@implementation ATNetworkingManager
#pragma mark - init
+(instancetype)sharedManager {
    static ATNetworkingManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATNetworkingManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

#pragma mark - making http request
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSURLCredential *credntial = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credntial);
    }
}

-(void) sendHTTPRequestToAddress:(NSString*)address HTTPMethod:(ATNetworkingHTTPMethod)method parameters:(id)parameters completion:(void(^)(NSData *data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion {
    [self postParameters:parameters toURL:[NSURL URLWithString:address] gzipBody:YES completion:completion];
}

-(void) postParameters:(id)parameters toURL:(NSURL*)URL gzipBody:(BOOL)gzip completion:(void(^)(NSData *data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion {
    NSData *bodyData = [[parameters jsonString_anythink] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:gzip ? [bodyData gzippedData_ATKit] : bodyData];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    if (gzip) { [request setValue:@"gzip" forHTTPHeaderField:@"Request-Encoding"]; }
    [[_URLSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([data length] > 0 && completion != nil) {
            completion([data isGzippedData_ATKit] ? [data gunzippedData_ATKit] : data, response, error);
        } else if (completion != nil) {
            completion(nil, response, error);
        }
    }] resume];
}

-(void) sendHTTPRequestToDomain:(NSString*)domain path:(NSString*)path HTTPMethod:(ATNetworkingHTTPMethod)method parameters:(id)parameters completion:(void(^)(NSData *data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion {
    [self postParameters:parameters toURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@", [self schemeWithDomain:domain], domain, path]] gzipBody:[ATNetworkingManager gzipBodyForRequestToDomain:domain path:path HTTPMethod:method parameters:parameters] completion:completion];
}

+(NSData*)buildBodyForRequestToDomain:(NSString*)domain path:(NSString*)path HTTPMethod:(ATNetworkingHTTPMethod)method parameters:(id)parameters {
    NSData *bodyData = [[parameters jsonString_anythink] dataUsingEncoding:NSUTF8StringEncoding];
    bodyData = [self gzipBodyForRequestToDomain:domain path:path HTTPMethod:method parameters:parameters] ? [bodyData gzippedData_ATKit] : bodyData;
    return bodyData;
}

+(BOOL) gzipBodyForRequestToDomain:(NSString*)domain path:(NSString*)path HTTPMethod:(ATNetworkingHTTPMethod)method parameters:(id)parameters {
    return !([domain isEqualToString:kAPIDomain] && ([path isEqualToString:@"v1/open/app"] || [path isEqualToString:@"v1/open/placement"]));
}

-(NSString*)schemeWithDomain:(NSString*)domain {
#ifdef UNDER_DEVELOPMENT
    return @{kAPIDomain:@"http",
             kTrackDomain:@"http",
             kAgentDomain:@"http"
             }[domain];
#else
    return @{kAPIDomain:@"https",
             kTrackDomain:@"https",
             kAgentDomain:@"https"
             }[domain];
#endif
    
}

#pragma mark - network type
/**
 The current implementation does not differentiate among 2G, 3G, 4G.
 */
typedef enum : NSInteger {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

+(NSString*)currentNetworkType {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [@"https://www.baidu.com" UTF8String]);
    NetworkStatus status = NotReachable;
    if (reachability != NULL) {
        status = [self currentReachabilityStatus:reachability];
        CFRelease(reachability);
    }
    
    //Guard against condition where undefined status is returned.
    return @[@"-1", @"-2", @"13"][status > ReachableViaWWAN ? NotReachable : status];
}


+ (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return NotReachable;
    }
    
    NetworkStatus returnValue = NotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = ReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = ReachableViaWWAN;
    }
    
    return returnValue;
}


+ (NetworkStatus)currentReachabilityStatus:(SCNetworkReachabilityRef)reachabilityRef
{
    NSAssert(reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    NetworkStatus returnValue = NotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        returnValue = [self networkStatusForFlags:flags];
    }
    
    return returnValue;
}
@end
