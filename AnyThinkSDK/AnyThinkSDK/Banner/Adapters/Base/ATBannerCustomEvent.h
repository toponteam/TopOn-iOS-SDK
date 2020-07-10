//
//  ATBannerCustomEvent.h
//  AnyThinkBanner
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdCustomEvent.h"
#import "ATBannerDelegate.h"
#import "ATAdAdapter.h"
#import "ATPlacementModel.h"
#import "ATBanner.h"
#import "ATBannerView.h"
@interface ATBannerCustomEvent : ATAdCustomEvent
-(void) trackClick;
-(NSDictionary*)delegateExtra;
-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo;
-(void) cleanup;
@property(nonatomic, assign) id<ATBannerDelegate> delegate;
@property(nonatomic, weak) ATBanner *banner;
@property(nonatomic, weak) ATBannerView *bannerView;
@property(nonatomic, readonly) NSString *unitID;
@property(nonatomic, readonly) CGSize size;
@property(nonatomic) NSDictionary *loadingParameters;//For nend
@property(nonatomic) BOOL adjustAdSize;//For nend
@property(nonatomic, assign) NSInteger priorityIndex;

+(UIViewController*)rootViewControllerWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID;
@end
