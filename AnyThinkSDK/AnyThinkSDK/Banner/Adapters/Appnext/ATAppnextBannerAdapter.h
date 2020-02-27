//
//  ATAppnextBannerAdapter.h
//  AnyThinkAppnextBannerAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAppnextBannerAdapter : NSObject
@end

@protocol ATAppnextSDKApi<NSObject>
+ (NSString *) getSDKVersion;
@end

@protocol ATBannerRequest<NSObject>
@property (nonatomic, strong) NSArray * categories;
@property (nonatomic, assign) NSString * postBack;
@property (nonatomic, assign) NSInteger creative;
@property (nonatomic, assign, getter = isAutoPlay) BOOL autoPlay;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign) NSInteger videoLength;
@property (nonatomic, assign, getter = isClickEnabled) BOOL clickEnabled;
@property (nonatomic, assign) NSInteger maxVideoLength;
@property (nonatomic, assign) NSInteger minVideoLength;
@property (nonatomic, assign) NSInteger bannerType;
+ (instancetype) createBannerRequestFromNSDictionary:(NSDictionary *) data;
- (NSString *) getCreativeAsString;
- (NSString *) getVideoLengthAsString;
- (NSString *) getCategoriesAsString;
@end

@protocol AppnextBannerDelegate <NSObject>
@optional
- (void) onAppnextBannerLoadedSuccessfully;
- (void) onAppnextBannerError:(NSInteger) error;
- (void) onAppnextBannerClicked;
- (void) onAppnextBannerImpressionReported;
@end

@protocol ATAppnextBannerView<NSObject>
@property(nonatomic) CGRect frame;
@property (nonatomic, weak) id<AppnextBannerDelegate> delegate;
//- (instancetype) initBannerWithPlacementID:(NSString *) placemnetID withBannerRequest:(id<ATBannerRequest>) bannerRequest;
- (instancetype) initBannerWithPlacementID:(NSString *) placemnetID;

//- (void) loadAd;
- (void) loadAd:(id<ATBannerRequest>) bannerRequest;

@end
NS_ASSUME_NONNULL_END
