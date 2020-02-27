//
//  HBAdsBidConstants.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#ifndef HBAdsBidConstants_h
#define HBAdsBidConstants_h

#define HiBidVersion  @"1.0.0"

typedef NS_ENUM(NSInteger, HBAdBidFormat) {
    // Bid For Native Ad
    HBAdBidFormatNative = 1,
    // Bid For Interstitial Ad
    HBAdBidFormatInterstitial,
    // Bid For Rewarded Video Ad
    HBAdBidFormatRewardedVideo,
    // Bid For Banner
    HBAdBidFormatBanner,
};


typedef NS_ENUM(NSInteger, HBAdBidNetwork) {
    
    HBAdBidNetworkFacebook = 1,
    HBAdBidNetworkMintegral,// will support later
};

#ifdef DEBUG
#define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#else
#define DLog(fmt, ...)
#endif


#endif /* HBAdsBidConstants_h */
