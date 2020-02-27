//
//  BannerRequest.h
//  AppnextLib
//
//  Created by shalom.b on 11/16/17.
//  Copyright © 2017 Appnext. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{Static, Video, All}Creative;
typedef enum{Short, Long, Auto}VideoLength;
typedef enum{Banner, LargeBanner, MediumRectangle}BannerType;

@interface BannerRequest : NSObject

@property (nonatomic, strong) NSArray * categories;
@property (nonatomic, assign) NSString * postBack;
@property (nonatomic, assign) Creative creative;
@property (nonatomic, assign, getter = isAutoPlay) BOOL autoPlay;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign) VideoLength videoLength;
@property (nonatomic, assign, getter = isClickEnabled) BOOL clickEnabled;
@property (nonatomic, assign) NSInteger maxVideoLength;
@property (nonatomic, assign) NSInteger minVideoLength;
@property (nonatomic, assign) BOOL clickInApp;
@property (nonatomic, assign) BannerType bannerType;

/*
+ (BannerType) getBannerTypeByString:(NSString *) bannerTypeAsString;
+ (Creative) getCreativeTypeByString:(NSString *) bannerCreativeAsString;
+ (VideoLength) getVideoLengthByString:(NSString *) bannerVideoLengthAsString;*/
+ (instancetype) createBannerRequestFromNSDictionary:(NSDictionary *) data;

- (NSString *) getCreativeAsString;
- (NSString *) getVideoLengthAsString;
- (NSString *) getCategoriesAsString;
@end
