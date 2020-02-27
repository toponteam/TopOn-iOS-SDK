//
//  AppnextRedirectResolveManager.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 23/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextRedirectResolveRequest.h>

@interface AppnextRedirectResolveManager : NSObject

AS_SINGLETON(AppnextRedirectResolveManager)

- (void) resolveRequest:(AppnextRedirectResolveRequest *)resolveRequest;
- (void) quitResolveRequest:(AppnextRedirectResolveRequest *)resolveRequest;

@end
