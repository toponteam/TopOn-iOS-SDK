//
//  AppnextRedirectResolveManagerDelegate.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 23/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

@class AppnextRedirectResolveRequest;
@class AppnextRedirectResolveResponse;

@protocol AppnextRedirectResolveManagerDelegate <NSObject>
@optional
- (void) onResolveSuccess:(AppnextRedirectResolveRequest *)resolveRequest withResponse:(AppnextRedirectResolveResponse *)resolveResponse;
- (void) onResolveFailed:(AppnextRedirectResolveRequest *)resolveRequest withResponse:(AppnextRedirectResolveResponse *)resolveResponse resolveError:(NSString *)error;
@end
