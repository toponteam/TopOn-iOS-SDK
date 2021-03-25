//
//  ATBannerManager.h
//  AnyThinkBanner
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAdManagement.h"
extern NSString *const kBannerAssetsUnitIDKey;
extern NSString *const kBannerAssetsBannerViewKey;
extern NSString *const kBannerAssetsCustomEventKey;

extern NSString *const kBannerPresentModalViewControllerNotification;
extern NSString *const kBannerDismissModalViewControllerNotification;

extern NSString *const kBannerNotificationUserInfoRequestIDKey;
@class ATBanner;
@interface ATBannerManager : NSObject<ATAdManagement>

@property(nonatomic, readonly) NSMutableDictionary *statusStorage;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, id>*>*bannerStorage;

+(instancetype) sharedManager;
-(void) removeCacheContainingBanner:(ATBanner*)banner;
-(ATBanner*) bannerForPlacementID:(NSString*)placementID extra:(NSDictionary* __autoreleasing*)extra;
-(ATBanner*) bannerForPlacementID:(NSString*)placementID invalidateStatus:(BOOL)invalidateStatus extra:(NSDictionary* __autoreleasing*)extra;
@end
