//
//  AppnextSettingsManager.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 11/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextResourceLoader.h>

@interface AppnextSettingsManager : AppnextResourceLoader

- (NSString *) getSetting:(NSString *)key;

@end
