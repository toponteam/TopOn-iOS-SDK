//
//  ATMyOfferSetting.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATModel.h"
typedef NS_ENUM(NSInteger, ATMyOfferEndCardClickable) {
    ATMyOfferEndCardClickableFullscreen,
    ATMyOfferEndCardClickableCTA,
    ATMyOfferEndCardClickableBanner
};
@interface ATMyOfferSetting : ATModel
-(instancetype) initWithDictionary:(NSDictionary *)dictionary placementID:(NSString*)placementID;

@property(nonatomic, readonly) NSString *placementID;
@property(nonatomic, readonly) NSInteger format;
@property(nonatomic, readonly) BOOL videoAreaInteractionEnabled;
@property(nonatomic, readonly) NSTimeInterval bannerAppearanceInterval;
@property(nonatomic, readonly) ATMyOfferEndCardClickable endCardClickable;
@property(nonatomic, readonly) BOOL mute;
@property(nonatomic, readonly) NSTimeInterval closeButtonAppearanceInterval;
@property(nonatomic, readonly) NSTimeInterval resourceDownloadTimeout;
@property(nonatomic, readonly) NSTimeInterval resourceCacheTime;

+(instancetype) mockSetting;
@end
