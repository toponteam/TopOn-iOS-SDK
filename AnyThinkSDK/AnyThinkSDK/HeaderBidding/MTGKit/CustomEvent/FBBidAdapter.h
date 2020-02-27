//
//  FBBidAdapter.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/10.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBBidBaseCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBBidAdapter : HBBidBaseCustomEvent

@end


typedef NS_ENUM(NSInteger, HBAdFBAdBidFormat) {
    // Bid For Banner 300x50
    HBAdFBAdBidFormatBanner_300_50,
    // Bid For Banner 320x50
    HBAdFBAdBidFormatBanner_320_50,
    // Bid For Banner with flexible width and height 50
    HBAdFBAdBidFormatBanner_HEIGHT_50,
    // Bid For Banner with flexible width and height 90
    HBAdFBAdBidFormatBanner_HEIGHT_90,
    // Bid For Banner with flexible width and height 250
    HBAdFBAdBidFormatBanner_HEIGHT_250,
    // Bid For Interstitial
    HBAdFBAdBidFormatInterstitial,
    // Bid For Native
    HBAdFBAdBidFormatNative,
    // Bid For Native Banner
    HBAdFBAdBidFormatNativeBanner,
    // Bid For Rewarded Video
    HBAdFBAdBidFormatRewardedVideo,
    // Bid For Instream Video
    HBAdFBAdBidFormatInstreamVideo,
};

@protocol HBAdFBAdBidResponse<NSObject>
- (NSString *)getPlatformAuctionID;
- (NSString *)getBidRequestID;
- (NSString *)getImpressionID;
- (NSString *)getPlacementID;
- (double)getPrice;
- (nullable NSString *)getCurrency;
- (nullable NSString *)getPayload;
- (nullable NSString *)getErrorMessage;
- (BOOL)getIsNetworkTimedOut;
- (nullable NSString *)getFBDebugHeader;
- (NSInteger)getHttpStatusCode;
- (void)notifyWin;
- (void)notifyLoss;
- (BOOL)isSuccess;
@end

@protocol HBAdFBAdBidRequest<NSObject>
+ (void)getAudienceNetworkTestBidForAppID:(NSString *)appID
                              placementID:(NSString *)placementID
                               platformID:(NSString *)platformID
                                 adFormat:(HBAdFBAdBidFormat)bidAdFormat
                             maxTimeoutMS:(NSInteger)maxTimeoutMS
                         responseCallback:(void(^)(id<HBAdFBAdBidResponse> bidResponse))callback;

+ (void)getAudienceNetworkBidForAppID:(NSString *)appID
                          placementID:(NSString *)placementID
                           platformID:(NSString *)platformID
                             adFormat:(HBAdFBAdBidFormat)bidAdFormat
                     responseCallback:(void(^)(id<HBAdFBAdBidResponse>bidResponse))callback;
@end

NS_ASSUME_NONNULL_END
