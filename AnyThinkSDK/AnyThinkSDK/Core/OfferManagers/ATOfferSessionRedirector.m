//
//  ATOfferSessionRedirector.m
//  AnyThinkSDK
//
//  Created by Topon on 9/1/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOfferSessionRedirector.h"

@interface ATOfferSessionRedirector()<NSURLSessionDelegate>
@property(nonatomic, copy) void(^completion)(NSURL *finalURL, NSError *error);
@property(nonatomic, readonly) NSURL *URL;
@end

@implementation ATOfferSessionRedirector

+(instancetype) redirectorWithURL:(NSURL*)URL completion:(void(^)(NSURL *finalURL, NSError *error))completion {
    return [[self alloc] initWithURL:(NSURL*)URL completion:completion];
}

-(instancetype) initWithURL:(NSURL*)URL completion:(void(^)(NSURL *finalURL, NSError *error))completion {
    self = [super init];
    if (self != nil) {
        _URL = URL;
        _completion = completion;
        [self start];
    }
    return self;
}

-(void) start {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    [[session dataTaskWithRequest:[NSMutableURLRequest requestWithURL:_URL]] resume];
    [session finishTasksAndInvalidate];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    _completion(task.currentRequest.URL, error);
}

@end
