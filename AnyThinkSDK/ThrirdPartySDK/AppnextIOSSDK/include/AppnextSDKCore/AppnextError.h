//
//  AppnextError.h
//  AppnextLib
//
//  Created by shalom.b on 2/20/18.
//  Copyright © 2018 Appnext. All rights reserved.
//

#ifndef AppnextError_h
#define AppnextError_h

typedef NS_ENUM(NSInteger, AppnextError) {
    AppnextNoAds,
    AppnextAdNotReady,
    AppnextConnectionError,
    AppnextNoMarket,
    AppnextTimeOut
};

// In a source file
// initialize arrays with explicit indices to make sure
// the string match the enums properly
static NSString * const AppnextError_toString[5] = {
    [AppnextNoAds] = @"AppnextNoAds",
    [AppnextAdNotReady] = @"AppnextAdNotReady",
    [AppnextConnectionError] = @"AppnextConnectionError",
    [AppnextNoMarket] = @"AppnextNoMarket",
    [AppnextTimeOut] = @"AppnextTimeOut"
};

#endif /* AppnextError_h */
