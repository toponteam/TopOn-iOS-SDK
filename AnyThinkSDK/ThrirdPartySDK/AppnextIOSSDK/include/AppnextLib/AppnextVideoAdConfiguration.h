//
//  AppnextVideoAdConfiguration.h
//  AppnextLib
//
//  Created by Eran Mausner on 11/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdConfiguration.h>

@interface AppnextVideoAdConfiguration : AppnextAdConfiguration

@property (nonatomic, assign) ANProgressType progressType;
@property (nonatomic, strong) NSString *progressColor;
@property (nonatomic, assign) ANVideoLength videoLength;
@property (nonatomic, assign) NSTimeInterval closeDelay;
@property (nonatomic, assign, readonly) BOOL closeDelayWasSet;
@property (nonatomic, assign) BOOL showClose;
@property (nonatomic, assign, readonly) BOOL showCloseWasSet;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign, readonly) BOOL muteWasSet;

@end
