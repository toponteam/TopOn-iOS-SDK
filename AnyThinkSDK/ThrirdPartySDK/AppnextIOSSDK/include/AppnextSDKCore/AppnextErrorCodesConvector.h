//
//  AppnextErrorCodesConvector.h
//  AppnextLib
//
//  Created by shalom.b on 2/20/18.
//  Copyright © 2018 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextSDKCore.h>
#import "AppnextError.h"

@interface AppnextErrorCodesConvector : AppnextSettingsManager
+ (AppnextError) convertStringErrorToAppnextError:(NSString *) errorstring;
@end
