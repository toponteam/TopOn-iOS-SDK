//
//  AppnextRedirectResolveResponse.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 23/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

@interface AppnextRedirectResolveResponse : NSObject

@property (nonatomic, strong, readonly) NSString *appStoreUrl;
@property (nonatomic, strong, readonly) NSHTTPCookie *resolveCookie;
@property (nonatomic, assign, readonly) BOOL isPostView;

- (instancetype) initWithAppStoreUrl:(NSString *)appStoreUrl withResolveCookie:(NSHTTPCookie *)resolveCookie isPostView:(BOOL)postView;

@end
