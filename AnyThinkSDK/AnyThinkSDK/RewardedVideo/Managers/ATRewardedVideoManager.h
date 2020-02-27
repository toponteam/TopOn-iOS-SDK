//
//  ATRewardedVideoManager.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 28/06/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAd.h"
#import "ATAdManagement.h"
extern NSString *const kRewardedVideoAssetsUnitIDKey;
extern NSString *const kRewardedVideoAssetsCustomEventKey;
@class ATPlacementModel;
@class ATUnitGroupModel;
@class ATRewardedVideo;
@interface ATRewardedVideoManager : NSObject<ATAdManagement>
+(instancetype) sharedManager;
-(void) setCustomEvent:(id)event forKey:(NSString*)key;
-(void) removeCustomEventForKey:(NSString*)key;
-(id) customEventForKey:(NSString*)key;
-(void) setFirstLoadFlagForNetwork:(NSString*)network;
-(BOOL) firstLoadFlagForNetwork:(NSString*)network;
-(ATRewardedVideo*) rewardedVideoForPlacementID:(NSString*)placementID extra:(NSDictionary*__autoreleasing*)extra;
-(ATRewardedVideo*) rewardedVideoForPlacementID:(NSString*)placementID invalidateStatus:(BOOL)invalidateStatus extra:(NSDictionary*__autoreleasing*)extra;
@end
