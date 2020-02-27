//
//  AppnextConfigurationForRequest.h
//  AppnextSDKCore
//
//  Created by shalom.b on 1/15/18.
//  Copyright © 2018 Appnext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppnextConfigurationForRequest : NSObject

@property (nonatomic, strong, readonly) NSString *placementID;
@property (nonatomic, strong, readonly) NSString *TID;
@property (nonatomic, strong, readonly) NSString *AUID;
@property (nonatomic, strong, readonly) NSString *categories;
@property (nonatomic, strong, readonly) NSString *postBack;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly, getter=isRequiredImage) BOOL requiredImage;
@property (nonatomic, readonly, getter=isRequiredVideo) BOOL requiredVideo;
@property (nonatomic, strong, readonly) NSString *offerWallUrlExtensionForAdWithCount;
@property (nonatomic, readonly) BOOL  adShouldAttachBanner;
@property (nonatomic, readonly) BOOL adNeedsVideoDownloaded;
@property (nonatomic, readonly) time_t adResponseValidityPeriod;
@property (nonatomic, readonly) ANVideoLength videoLength;
@property (nonatomic, readonly) NSTimeInterval bannerExpirationTime;
@property (nonatomic, assign) BOOL shoudDownloadVideo;


-(instancetype) initWithPlacementID:(NSString * ) placementID withTID:(NSString *) tid withAuid: (NSString *) auid withCategories: (NSString *)categories
                       withPostback:(NSString *)postback  withCount:(NSUInteger)count  isRequiredImage: (BOOL) isRequiredImage isRequiredVideo:(BOOL) isRequiredVideo withOfferWallUrlExtensionForAdWithCount:(NSString * ) offerWallUrlExtensionForAdWithCount adShouldAttachBanner:(BOOL ) adShouldAttachBanner adNeedsVideoDownloaded: (BOOL) adNeedsVideoDownloaded adResponseValidityPeriod:(time_t ) adResponseValidityPeriod withVideoLength:(ANVideoLength) videoLength withBannerExpirationTime:(NSTimeInterval ) bannerExpirationTime;
@end
