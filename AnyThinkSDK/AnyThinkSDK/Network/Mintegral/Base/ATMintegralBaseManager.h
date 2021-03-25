//
//  ATMintegralBaseManager.h
//  AnyThinkMintegralAdapter
//
//  Created by Topon on 11/14/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"
#import "ATUnitGroupModel.h"
#import "ATPlacementModel.h"
#import "ATBidInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ATMTGUserPrivateType) {
    ATMTGUserPrivateType_ALL         = 0,
    ATMTGUserPrivateType_GeneralData = 1,
    ATMTGUserPrivateType_DeviceId    = 2,
    ATMTGUserPrivateType_Gps         = 3,
};

@interface ATMintegralBaseManager : ATNetworkBaseManager
+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion;
@end

@protocol ATMTGBiddingSDK<NSObject>
+ (NSString *)buyerUID;
@end

@protocol ATMTGSDK<NSObject>
+ (nonnull instancetype)sharedInstance;
+(NSString *)sdkVersion;
- (void)setAppID:(nonnull NSString *)appID ApiKey:(nonnull NSString *)apiKey;
- (void)setUserPrivateInfoType:(ATMTGUserPrivateType)type agree:(BOOL)agree;
- (void)setDoNotTrackStatus:(BOOL)status;
@property (nonatomic, assign) BOOL consentStatus;
@end

@protocol ATMTGAdCustomConfig<NSObject>
+(instancetype)sharedInstance;
-(void)setCustomInfo:(NSString*)customInfo type:(NSInteger)type unitId:(NSString*)unitID;
@end

@protocol ATMTGBiddingResponse<NSObject>
@property (nonatomic,strong,readonly) NSError *error;
@property (nonatomic,assign,readonly) BOOL success;
@property (nonatomic,assign,readonly) NSString *price;
@property (nonatomic,copy,readonly) NSString *currency;
@property (nonatomic,copy,readonly) NSString *bidToken;
-(void)notifyWin;
-(void)notifyLoss:(NSInteger)reasonCode;
@end

@protocol ATMTGBiddingRequestParameter <NSObject>
@property(nonatomic,copy,readonly)NSString *unitId;
@property(nonatomic,readonly)NSNumber *basePrice;
- (instancetype)initWithPlacementId:(NSString *)placementId
   unitId:(NSString *) unitId
basePrice:(NSNumber *)basePrice;
@end

@protocol ATMTGBiddingRequest<NSObject>
+(void)getBidWithRequestParameter:(__kindof id<ATMTGBiddingRequestParameter>)requestParameter completionHandler:(void(^)(id<ATMTGBiddingResponse> bidResponse))completionHandler;
@end

NS_ASSUME_NONNULL_END
