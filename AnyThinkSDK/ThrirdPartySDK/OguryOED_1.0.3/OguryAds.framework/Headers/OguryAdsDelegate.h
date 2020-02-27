//
//  PresageSDKDelegate.h
//  PresageSDK
//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGARewardItem.h"

typedef NS_ENUM(NSInteger, OguryAdsErrorType) {
    OguryAdsErrorLoadFailed              = 0,
    OguryAdsErrorNoInternetConnection    = 1,
    OguryAdsErrorAdDisable               = 2,
    OguryAdsErrorProfigNotSynced         = 3,
    OguryAdsErrorAdExpired               = 4,
    OguryAdsErrorSdkInitNotCalled        = 5,
};

@protocol OguryAdsOptinVideoDelegate;
@protocol OguryAdsOptinVideoDelegate
-(void)oguryAdsOptinVideoAdAvailable;
-(void)oguryAdsOptinVideoAdNotAvailable;
-(void)oguryAdsOptinVideoAdLoaded;
-(void)oguryAdsOptinVideoAdNotLoaded;
-(void)oguryAdsOptinVideoAdDisplayed;
-(void)oguryAdsOptinVideoAdClosed;
-(void)oguryAdsOptinVideoAdRewarded:(OGARewardItem *)item;
-(void)oguryAdsOptinVideoAdError:(OguryAdsErrorType)errorType;
@end

@protocol OguryAdsInterstitialDelegate;
@protocol OguryAdsInterstitialDelegate
-(void)oguryAdsInterstitialAdAvailable;
-(void)oguryAdsInterstitialAdNotAvailable;
-(void)oguryAdsInterstitialAdLoaded;
-(void)oguryAdsInterstitialAdNotLoaded;
-(void)oguryAdsInterstitialAdDisplayed;
-(void)oguryAdsInterstitialAdClosed;
-(void)oguryAdsInterstitialAdError:(OguryAdsErrorType)errorType;
@end
