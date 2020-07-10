//
//  ATInterstitialManager.h
//  AnyThinkInterstitial
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAdManagement.h"

extern NSString *const kInterstitialAssetsUnitIDKey;
extern NSString *const kInterstitialAssetsCustomEventKey;
@class ATInterstitial;
@interface ATInterstitialManager : NSObject<ATAdManagement>
+(instancetype)sharedManager;
-(ATInterstitial*) interstitialWithPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID;
-(ATInterstitial*) interstitialForPlacementID:(NSString*)placementID extra:(NSDictionary* __autoreleasing*)extra;
-(ATInterstitial*) interstitialForPlacementID:(NSString*)placementID invalidateStatus:(BOOL)invalidateStatus extra:(NSDictionary* __autoreleasing*)extra;
@end
