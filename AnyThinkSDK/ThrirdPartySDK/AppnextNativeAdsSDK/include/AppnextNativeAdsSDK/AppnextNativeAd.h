//
//  AppnextNativeAd.h
//  AppnextNativeAdsSDK
//
//  Created by Eran Mausner on 16/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAd.h>

@interface AppnextNativeAd : AppnextAd
- (instancetype) initWithPlacementID:(NSString *)placement withViewController:(UIViewController*) viewController;
@end
