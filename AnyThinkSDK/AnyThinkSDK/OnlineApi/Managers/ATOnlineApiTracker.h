//
//  ATOnlineApiTracker.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ATOnlineApiTrackerEvent) {
    ATOnlineApiTrackerEventVideoStart = 0,
    ATOnlineApiTrackerEventVideo25Percent = 1,
    ATOnlineApiTrackerEventVideo50Percent = 2,
    ATOnlineApiTrackerEventVideo75Percent = 3,
    ATOnlineApiTrackerEventVideoEnd = 4,
    ATOnlineApiTrackerEventImpression = 5,
    ATOnlineApiTrackerEventClick = 6,
    ATOnlineApiTrackerEventVideoClick = 7,
    ATOnlineApiTrackerEventEndCardShow = 8,
    ATOnlineApiTrackerEventEndCardClose = 9,
    ATOnlineApiTrackerEventVideoMute = 10,
    ATOnlineApiTrackerEventVideoUnMute = 11,
    ATOnlineApiTrackerEventVideoPaused = 12,
    ATOnlineApiTrackerEventVideoResumed = 13,
    ATOnlineApiTrackerEventVideoSkip = 14,
    ATOnlineApiTrackerEventVideoPlayFail = 15,
    ATOnlineApiTrackerEventVideoDeeplinkStart = 16,
    ATOnlineApiTrackerEventVideoDeeplinkSuccess = 17,
    ATOnlineApiTrackerEventVideoRewarded,
    ATOnlineApiTrackerEventVideoLoaded,
//    ATOnlineApiTrackerEventVideoPlaying
};

@class ATOnlineApiOfferModel, ATOnlineApiPlacementSetting;
@interface ATOnlineApiTracker : NSObject

+ (instancetype)sharedTracker;

- (void)trackWithUrls:(NSArray<NSString *> *)urls offerModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary *)extra;
- (void)trackEvent:(ATOnlineApiTrackerEvent)event offerModel:(ATOnlineApiOfferModel *)offerModel extra:(NSDictionary*)extra;

/// sucess: It indicates that whether the deeplink or jump url was invoked sucessfully.
- (void)clickOfferWithOfferModel:(ATOnlineApiOfferModel *)model setting:(ATOnlineApiPlacementSetting *)setting circleID:(NSString *)cid delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)pc extra:(NSDictionary*)extra clickCallbackHandler:(void (^ __nullable)(BOOL success))clickCallback;

- (void)preloadStorekitForOfferModel:(ATOnlineApiOfferModel *)offerModel setting:(ATOnlineApiPlacementSetting *)setting  viewController:(UIViewController *)viewController circleId:(NSString *)cid skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate;

@end

NS_ASSUME_NONNULL_END
