//
//  ATHeaderBiddingManager.h
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2019/6/18.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ATHBAdBidFormat) {
    // Bid For Native Ad
    ATHBAdBidFormatNative = 1,
    // Bid For Interstitial Ad
    ATHBAdBidFormatInterstitial,
    // Bid For Rewarded Video Ad
    ATHBAdBidFormatRewardedVideo,
    // Bid For Banner Video Ad
    ATHBAdBidFormatBanner,
};

typedef NS_ENUM(NSInteger, ATHBAdBidNetwork) {
    
    ATHBAdBidNetworkFacebook = 1,
    AnyThinkHBAdBidNetworkMintegral,// will support later
};

extern NSString *const kATHeaderBiddingBidRequestExtraStatisticsInfoKey;
@protocol ATAdSource;
@protocol ATHeaderBiddingAdSource;
@interface ATHeaderBiddingManager : NSObject
+(instancetype) sharedManager;
-(void) runHeaderBiddingWithForamt:(ATHBAdBidFormat)format unitID:(NSString*)unitID adSources:(NSArray<id<ATAdSource>>*)adsrouces headerBiddingAdSources:(NSArray<id<ATHeaderBiddingAdSource>>*)HBAdSources extra:(NSDictionary*)extra timeout:(NSTimeInterval)timeout completion:(void(^)(NSArray<id<ATAdSource>>*, NSDictionary*))completion;
@end

@protocol ATAdSource<NSObject>
@property(nonatomic, readonly) NSString *unitID;
@property(nonatomic, readonly) double price;
@property(nonatomic, readonly) ATHBAdBidNetwork network;
@property(nonatomic, readonly) BOOL headerBidding;
@end

extern NSString *const kATHeaderBiddingAdSourceInfoAppIDKey;
extern NSString *const kATHeaderBiddingAdSourceInfoUnitIDKey;
@protocol ATHeaderBiddingAdSource<ATAdSource>
@property(nonatomic, readonly) NSDictionary *adSrouceInfo;
@property(nonatomic, readwrite) double bidPrice;
@property(nonatomic, readwrite) id bidToken;
@property(nonatomic, readonly) NSTimeInterval headerBiddingRequestTimeout;
extern NSString *const kUnitGroupBidInfoPriceKey;
extern NSString *const kUnitGroupBidInfoBidTokenKey;
-(NSDictionary*)latestBidInfo;
@end

@protocol ATHBBidNetworkItem<NSObject>
+ (instancetype)buildItemNetwork:(ATHBAdBidNetwork)network customEventClassName:(NSString *)className appId:(NSString *)appId unitId:(NSString *)unitId;
@property (nonatomic,assign)  ATHBAdBidNetwork network;
@property (nonatomic,  copy)  NSString *placementId;
@property (nonatomic,  copy)  NSString *unitId;
@property (nonatomic,strong)  NSDictionary *extraParams;
@property (nonatomic,assign)  NSInteger maxTimeoutMS;
@property (nonatomic,  copy)  NSString *platformId;
@property (nonatomic,assign)  BOOL      testMode;
@end

@protocol ATHBAdBidResponse<ATAdSource>
@property (nonatomic,copy,  readonly) NSString *unitId;
@property (nonatomic,copy,  readonly) NSObject *payLoad;
@property (nonatomic,assign,readonly) double price;
@property (nonatomic,copy,  readonly) NSString *currency;
@property (nonatomic,assign,readonly) BOOL success;
@property (nonatomic,strong,readonly) NSError *error;
@property (nonatomic,strong,readonly) id<ATHBBidNetworkItem> networkItem;
@end

@protocol ATHBAuctionResult<NSObject>
@property (nonatomic,strong,readonly) id<ATHBAdBidResponse> winner;
@property (nonatomic,strong,readonly) NSArray<id<ATHBAdBidResponse>> *otherResponse;
@end

@protocol ATHBAdsBidRequest<NSObject>
+ (void)getBidNetworks:(NSArray<id<ATHBBidNetworkItem>>*)networkItems statisticsInfo:(NSDictionary*)statisticsInfo unitId:(NSString *)unitId adFormat:(ATHBAdBidFormat)format maxTimeoutMS:(NSInteger)maxTimeoutMS responseCallback:(void(^)(id<ATHBAuctionResult> auctionResponse, NSError *error))callback;
@end
