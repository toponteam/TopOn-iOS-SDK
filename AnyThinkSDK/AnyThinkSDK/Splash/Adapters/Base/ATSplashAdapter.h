//
//  ATSplashAdapter.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/3.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATSplashAdapter_h
#define ATSplashAdapter_h

#import <AnyThinkSDK/AnyThinkSDK.h>

@class ATSplash;
@protocol ATSplashDelegate;

@protocol ATSplashAdapter<ATAdAdapter>
@optional
//+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info;
+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate;
@end


#endif /* ATSplashAdapter_h */
