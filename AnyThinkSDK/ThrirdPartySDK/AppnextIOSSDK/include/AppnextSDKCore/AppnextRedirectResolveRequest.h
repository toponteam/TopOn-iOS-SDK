//
//  AppnextRedirectResolveRequest.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 23/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdData.h>
#import <AppnextSDKCore/AppnextRedirectResolveManagerDelegate.h>

@interface AppnextRedirectResolveRequest : NSObject

@property (nonatomic, strong, readonly) NSString *resolveUrl;
@property (nonatomic, assign, readonly) BOOL isPostView;
@property (nonatomic, assign, readonly) NSTimeInterval resolveTimeout;
@property (nonatomic, strong, readonly) AppnextAdData *adData;
@property (nonatomic, weak, readonly) id<AppnextRedirectResolveManagerDelegate> delegate;

- (instancetype) initWithUrl:(NSString *)resolveUrl isPostView:(BOOL)postView withTimeout:(NSTimeInterval)timeout withAdData:(AppnextAdData *)adData withDelegate:(id<AppnextRedirectResolveManagerDelegate>)delegate;

@end
