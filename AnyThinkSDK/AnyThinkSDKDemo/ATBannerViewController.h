//
//  ATBannerViewController.h
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 19/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *const kInmobiPlacement;
extern NSString *const kFacebookPlacement;
extern NSString *const kAdMobPlacement;
extern NSString *const kApplovinPlacement;
extern NSString *const kFlurryPlacement;
extern NSString *const kMopubPlacementName;
extern NSString *const kGDTPlacement;
extern NSString *const kMopubVideoPlacementName;
extern NSString *const kMintegralPlacement;
extern NSString *const kTapjoyPlacementName;
extern NSString *const kChartboostPlacementName;
extern NSString *const kIronsourcePlacementName;
extern NSString *const kVunglePlacementName;
extern NSString *const kAdcolonyPlacementName;
extern NSString *const kUnityAdsPlacementName;
extern NSString *const kAllPlacementName;
extern NSString *const kTTPlacementName;
extern NSString *const kYeahmobiPlacement;
extern NSString *const kAppnextPlacement;
extern NSString *const kBaiduPlacement;
extern NSString *const kNendPlacement;
extern NSString *const kBannerShownNotification;
extern NSString *const kBannerLoadingFailedNotification;
extern NSString *const kHeaderBiddingPlacement;

@interface ATBannerViewController : UIViewController
-(instancetype) initWithPlacementName:(NSString*)name;
@end
