//
//  AppnextAdsContainerDelegate.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 26/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdData.h>

@protocol AppnextAdsContainerProtocol <NSObject>
- (NSString *) getPlacementID;
- (NSString *) getTID;
- (NSString *) getAUID;
- (NSString *) getCategories;
- (NSString *) getPostback;
- (NSUInteger) getCount;
- (BOOL) isValid;
- (BOOL) isNoAdsValid:(time_t) adsCachingTimeMinutes ;
- (NSArray<AppnextAdData *> *) getAdsArray;
- (NSString *) getAttachedLoadedBannerId;
- (AppnextAdData *) getBannerIfMember:(NSString *)bannerId;
@end

@protocol AppnextAdsContainerDelegate <NSObject>
@optional
- (void) loadedAds:(id<AppnextAdsContainerProtocol>)container;
- (void) failedAds:(id<AppnextAdsContainerProtocol>)container error:(NSString *)error;
@end
