//
//  AppnextEventsManager.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 27/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextEvent.h>

@interface AppnextEventsManager : NSObject

AS_SINGLETON(AppnextEventsManager)

- (void) trackEventAsynch:(AppnextEvent *)event;

@end
