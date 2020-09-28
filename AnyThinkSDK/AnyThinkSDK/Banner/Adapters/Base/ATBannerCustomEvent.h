//
//  ATBannerCustomEvent.h
//  AnyThinkBanner
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
//#import "ATAdCustomEvent.h"
#import "ATBannerDelegate.h"
//#import "ATAdAdapter.h"
//#import "ATPlacementModel.h"
#import "ATBanner.h"
#import "ATBannerView.h"
@interface ATBannerCustomEvent : ATAdCustomEvent
-(void) trackBannerAdClick;
-(void) trackBannerAdClosed;
-(void) trackBannerAdLoaded:(id)bannerView adExtra:(NSDictionary *)adExtra;
//-(void) trackBannerAdShow;
-(void) trackBannerAdLoadFailed:(NSError*)error;
-(NSDictionary*)delegateExtra;
-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo;
-(void) cleanup;
@property(nonatomic, assign) id<ATBannerDelegate> delegate;
@property(nonatomic, weak) ATBanner *banner;
@property(nonatomic, weak) ATBannerView *bannerView;
@property(nonatomic, readonly) NSString *unitID;
@property(nonatomic, readonly) CGSize size;
@property(nonatomic, strong) NSValue *admobAdSizeValue;//For admob
@property(nonatomic, assign) NSInteger admobAdSizeFlags;//For admob
@property(nonatomic) NSDictionary *loadingParameters;//For nend
@property(nonatomic) BOOL adjustAdSize;//For nend
@property(nonatomic, assign) NSInteger priorityIndex;

+(UIViewController*)rootViewControllerWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID;
@end
