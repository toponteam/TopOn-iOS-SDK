//
//  AppnextInterstitialAd.h
//  AppnextLib
//
//  Created by Eran Mausner on 11/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAd.h>

@interface AppnextInterstitialAd : AppnextAd

#pragma mark - Setters/Getters

- (void) setCreativeType:(ANCreativeType)creativeType;
- (ANCreativeType) getCreativeType;
- (void) setSkipText:(NSString *)skipText;
- (NSString *) getSkipText;
- (void) setAutoPlay:(BOOL)autoPlay;
- (BOOL) getAutoPlay;

@end
