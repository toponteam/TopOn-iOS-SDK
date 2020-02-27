//
//  MTGBidAdapter.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/10.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBBidBaseCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTGBidAdapter : HBBidBaseCustomEvent
@end

@protocol HBAdMTGSDK<NSObject>
+(instancetype)sharedInstance;
- (void)setAppID:(nonnull NSString *)appID ApiKey:(nonnull NSString *)apiKey;
@end

typedef NS_ENUM (NSInteger, HBAdMTGBidLossedReasonCode) {
    
    HBAdMTGBidLossedReasonCodeLowPrice                           = 1,
    HBAdMTGBidLossedReasonCodeBidTimeout                         = 2,
    HBAdMTGBidLossedReasonCodeWonNotShow                         = 3,
    
};
typedef NS_ENUM(NSInteger,HBMTGBannerSizeType) {
    /*Represents the fixed banner ad size - 320pt by 50pt.*/
    MTGStandardBannerType320x50,
    
    /*Represents the fixed banner ad size - 320pt by 90pt.*/
    MTGLargeBannerType320x90,
    
    /*Represents the fixed banner ad size - 300pt by 250pt.*/
    MTGMediumRectangularBanner300x250,
    
    /*if device height <=720,Represents the fixed banner ad size - 320pt by 50pt;
      if device height > 720,Represents the fixed banner ad size - 728pt by 90pt*/
    MTGSmartBannerType
};
@protocol HBAdMTGBiddingResponse<NSObject>
@property (nonatomic,strong,readonly) NSError *error;
@property (nonatomic,assign,readonly) BOOL success;
@property (nonatomic,assign,readonly) double price;
@property (nonatomic,copy,readonly) NSString *currency;
@property (nonatomic,copy,readonly) NSString *bidToken;
-(void)notifyWin;
-(void)notifyLoss:(HBAdMTGBidLossedReasonCode)reasonCode;
@end

@protocol HBMTGBiddingRequestParameter <NSObject>
@property(nonatomic,copy,readonly)NSString *unitId;
@property(nonatomic,readonly)NSNumber *basePrice;
- (instancetype)initWithUnitId:(nonnull NSString *) unitId
                     basePrice:(nullable NSNumber *)basePrice;
@end
@protocol HBAdMTGBiddingRequest<NSObject>
+(void)getBidWithUnitId:(nonnull NSString *)unitId basePrice:(nullable NSNumber *)basePrice completionHandler:(void(^)(id<HBAdMTGBiddingResponse> bidResponse))completionHandler;

+(void)getBidWithRequestParameter:(nonnull __kindof id<HBMTGBiddingRequestParameter>)requestParameter completionHandler:(void(^)(id<HBAdMTGBiddingResponse> bidResponse))completionHandler;
@end

@protocol HBMTGBiddingBannerRequestParameter <NSObject>
- (instancetype)initWithUnitId:(nonnull NSString *) unitId
                     basePrice:(nullable NSNumber *)basePrice
                bannerSizeType:(HBMTGBannerSizeType)bannerSizeType;
@end
NS_ASSUME_NONNULL_END
