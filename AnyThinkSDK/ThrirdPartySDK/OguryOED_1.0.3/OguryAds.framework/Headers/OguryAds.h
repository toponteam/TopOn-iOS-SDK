//
//  PresageSDK.h
//  PresageSDK
//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryAds/OguryAdsDelegate.h>
#import <OguryAds/OguryAdsInterstitial.h>
#import <OguryAds/OguryAdsOptinVideo.h>
#import <OguryAds/OGARewardItem.h>


@interface OguryAds : NSObject

@property (nonatomic, strong) NSString * sdkVersion;

+ (instancetype)shared;
- (void)setupWithAssetKey:(NSString *)assetKey;

@end
