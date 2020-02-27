//
//  ATInmobiBannerAdapter.h
//  AnyThinkInmobiBannerAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATInmobiBannerAdapter : NSObject
@end

@protocol ATIMSdk<NSObject>
+(NSString *)getVersion;
+(void)initWithAccountID:(NSString *)accountID;
+(void) updateGDPRConsent:(NSDictionary *)consentDictionary;
@end

@protocol IMBannerDelegate;
@protocol ATIMBanner<NSObject>
@property (nonatomic, weak) id<IMBannerDelegate> delegate;
@property (nonatomic) NSInteger refreshInterval;
@property (nonatomic, strong) NSString* keywords;
@property (nonatomic, strong) NSDictionary* extras;
@property (nonatomic) long long placementId;
@property (nonatomic) UIViewAnimationTransition transitionAnimation;
@property (nonatomic, strong, readonly) NSString* creativeId;
-(instancetype)initWithFrame:(CGRect)frame placementId:(long long)placementId;
-(instancetype)initWithFrame:(CGRect)frame placementId:(long long)placementId delegate:(id<IMBannerDelegate>)delegate;
-(void)load;
-(void)shouldAutoRefresh:(BOOL)refresh;
-(void)setRefreshInterval:(NSInteger)interval;
- (NSDictionary *)getAdMetaInfo;
@end

@protocol IMBannerDelegate <NSObject>
-(void)bannerDidFinishLoading:(id<ATIMBanner>)banner;
-(void)banner:(id<ATIMBanner>)banner didFailToLoadWithError:(NSError*)error;
-(void)banner:(id<ATIMBanner>)banner didInteractWithParams:(NSDictionary*)params;
-(void)userWillLeaveApplicationFromBanner:(id<ATIMBanner>)banner;
-(void)bannerWillPresentScreen:(id<ATIMBanner>)banner;
-(void)bannerDidPresentScreen:(id<ATIMBanner>)banner;
-(void)bannerWillDismissScreen:(id<ATIMBanner>)banner;
-(void)bannerDidDismissScreen:(id<ATIMBanner>)banner;
-(void)banner:(id<ATIMBanner>)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards;
@end

NS_ASSUME_NONNULL_END
