//
//  ATSplashManager.h
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAdManagement.h"

extern NSString *const kATSplashExtraContainerViewKey;
extern NSString *const kATSplashExtraWindowKey;
extern NSString *const kATSplashExtraWindowSceneKey;
extern NSString *const kATSplashExtraLoadingStartDateKey;
extern NSString *const kATSplashExtraBackgroundImageViewKey;

@class ATSplash;
@interface ATSplashManager : NSObject<ATAdManagement>
+(instancetype) sharedManager;

- (void)saveAdWithoutPlacementSetting:(ATSplash *)splash extra:(NSDictionary *)extra placementID:(NSString *)placementID;
//- (ATSplash *)splashReadyWithPlacementID:(NSString *)placementID;
- (ATSplash *)splashForPlacementID:(NSString*)placementID invalidateStatus:(BOOL)invalidateStatus extra:(NSDictionary* __autoreleasing*)extra;
- (void)ckearDefaultSplash;

@end
