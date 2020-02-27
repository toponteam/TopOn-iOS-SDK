//
//  AppnextInterstitialAdConfiguration.h
//  AppnextLib
//
//  Created by Eran Mausner on 11/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdConfiguration.h>

@interface AppnextInterstitialAdConfiguration : AppnextAdConfiguration

@property (nonatomic, assign) ANCreativeType creativeType;
@property (nonatomic, strong) NSString *skipText;
@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign, readonly) BOOL autoPlayWasSet;

@end
