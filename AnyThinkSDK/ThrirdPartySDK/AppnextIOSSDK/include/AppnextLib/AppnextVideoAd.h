//
//  AppnextVideoAd.h
//  AppnextLib
//
//  Created by Eran Mausner on 11/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAd.h>

@protocol AppnextVideoAdDelegate <AppnextAdDelegate>
@optional
- (void) videoEnded:(AppnextAd *)ad;
@end

@interface AppnextVideoAd : AppnextAd

#pragma mark - Setters/Getters

- (void) setProgressType:(ANProgressType)progressType;
- (ANProgressType) getProgressType;
- (void) setProgressColor:(NSString *)progressColor;
- (NSString *) getProgressColor;
- (void) setVideoLength:(ANVideoLength)videoLength;
- (ANVideoLength) getVideoLength;
- (void) setCloseDelay:(NSTimeInterval)closeDelay;
- (NSTimeInterval) getCloseDelay;
- (void) setShowClose:(BOOL)showClose;
- (BOOL) getShowClose;
- (void) setMute:(BOOL)mute;
- (BOOL) getMute;

@end
