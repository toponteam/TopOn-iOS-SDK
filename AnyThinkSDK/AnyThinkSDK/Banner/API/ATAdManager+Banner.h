//
//  ATAdManager+Banner.h
//  AnyThinkBanner
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
//Supported by Nend banner only
extern NSString *const kATBannerLoadingExtraParameters;
extern NSString *const kATAdLoadingExtraBannerAdSizeKey;//defaults to 320 * 50
extern NSString *const kATAdLoadingExtraBannerSizeAdjustKey;//Currently supported by Nend
@class ATBannerView;
@interface ATAdManager (Banner)
-(BOOL) bannerAdReadyForPlacementID:(NSString*)placementID;
/*
 nil will be returned if you try to show banner ad for the placementID if it's not ready.
 */
-(nullable ATBannerView*)retrieveBannerViewForPlacementID:(NSString*)placementID;
-(nullable ATBannerView*)retrieveBannerViewForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra DEPRECATED_ATTRIBUTE;

@end
