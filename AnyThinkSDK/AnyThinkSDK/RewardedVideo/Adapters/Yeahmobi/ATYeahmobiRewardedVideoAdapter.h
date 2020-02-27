//
//  ATYeahmobiRewardedVideoAdapter.h
//  AnyThinkYeahmobiRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface ATYeahmobiRewardedVideoAdapter : NSObject
@end

@protocol ATCTService<NSObject>
#pragma mark - CTService config Method
+ (instancetype)shareManager;
- (void)loadRequestGetCTSDKConfigBySlot_id:(NSString *)slot_id;
- (void)uploadConsentValue:(NSString *)consentValue consentType:(NSString *)consentType complete:(void(^)(BOOL state))complete;
- (NSString*)getSDKVersion;
#pragma mark - RewardVideo Ad Interface
- (void)setCustomParameters:(NSString *)customParams;
- (void)loadRewardVideoWithSlotId:(NSString *)slot_id delegate:(id)delegate;
- (void)showRewardVideo;
- (void)showRewardVideoWithPresentingViewController:(UIViewController *)viewController;
- (BOOL)checkRewardVideoIsReady;
@end

@protocol CTRewardVideoDelegate <NSObject>
@optional
- (void)CTRewardVideoLoadSuccess;
- (void)CTRewardVideoDidStartPlaying;
- (void)CTRewardVideoDidFinishPlaying;
- (void)CTRewardVideoDidClickRewardAd;
- (void)CTRewardVideoWillLeaveApplication;
- (void)CTRewardVideoJumpfailed;
- (void)CTRewardVideoLoadingFailed:(NSError *)error;
- (void)CTRewardVideoClosed;
- (void)CTRewardVideoAdRewardedName:(NSString *)rewardName rewardAmount:(NSString *)rewardAmount customParams:(NSString*) customParams;
@end
NS_ASSUME_NONNULL_END
