//
//  ATADXTracker.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<StoreKit/StoreKit.h>
#import "ATADXOfferModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ATADXTrackerEvent) {
    ATADXTrackerEventVideoStart = 0,
    ATADXTrackerEventVideo25Percent = 1,
    ATADXTrackerEventVideo50Percent = 2,
    ATADXTrackerEventVideo75Percent = 3,
    ATADXTrackerEventVideoEnd = 4,
    ATADXTrackerEventImpression = 5,
    ATADXTrackerEventClick = 6,
    ATADXTrackerEventVideoClick = 7,
    ATADXTrackerEventEndCardShow = 8,
    ATADXTrackerEventEndCardClose = 9,
    ATADXTrackerEventVideoMute = 10,
    ATADXTrackerEventVideoUnMute = 11,
    ATADXTrackerEventVideoPaused = 12,
    ATADXTrackerEventNTKurl = 13,
    ATADXTrackerEventVideoResumed = 14,
    ATADXTrackerEventVideoSkip = 15,
    ATADXTrackerEventVideoPlayFail = 16,
    ATADXTrackerEventVideoDeeplinkStart = 17,
    ATADXTrackerEventVideoDeeplinkSuccess = 18,
    ATADXTrackerEventVideoRewarded,
    ATADXTrackerEventVideoLoaded,
};

@interface ATADXTracker : NSObject
+(instancetype) sharedTracker;

- (void)trackWithUrls:(NSArray<NSString *> *)urls offerModel:(ATADXOfferModel *)offerModel extra:(NSDictionary*)extra;
- (void)trackEvent:(ATADXTrackerEvent)event offerModel:(ATADXOfferModel*)offerModel extra:(NSDictionary*)extra;

/// sucess: It indicates that whether the deeplink or jump url was invoked sucessfully.
-(void) clickOfferWithOfferModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting *)setting extra:(NSDictionary*)extra  clickCallbackHandler:(void (^ __nullable)(BOOL success))clickCallback;

/// sucess: It indicates that whether the deeplink or jump url was invoked sucessfully.
-(void) clickOfferWithOfferModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting *)setting extra:(NSDictionary*)extra skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *) viewController circleId:(NSString *) circleId  clickCallbackHandler:(void (^ __nullable)(BOOL success))clickCallback;
-(void)preloadStorekitForOfferModel:(ATADXOfferModel *)offerModel setting:(ATADXPlacementSetting *) setting  viewController:(UIViewController *)viewController circleId:(NSString *) circleId skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate;

@end

NS_ASSUME_NONNULL_END
