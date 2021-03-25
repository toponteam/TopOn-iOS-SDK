//
//  ATInmobiBaseManager.h
//  AnyThinkInmobiAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ATInMobiBuyerPriceKey;
extern NSString *const kATInmobiSDKInitedNotification;

@class ATUnitGroupModel,ATAdCustomEvent,ATBidInfo;
@interface ATInmobiBiddingRequest : NSObject

@property(nonatomic, strong) id customObject;
@property(nonatomic, strong) ATUnitGroupModel *unitGroup;
@property(nonatomic, strong) ATAdCustomEvent *customEvent;
@property(nonatomic, readwrite) NSDictionary *serverInfo;
@property(nonatomic, strong) id adapter;
@property(nonatomic, copy) NSString *unitID;
@property(nonatomic, copy) NSString *placementID;
@property(nonatomic, copy) void(^bidCompletion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);

// for banner
@property(nonatomic) CGRect bannerFrame;
@property(nonatomic) NSInteger refreshInterval;

@end

@protocol ATIMAdMetaInfo<NSObject>
@property (nonatomic, strong, readonly) NSString* creativeID;
@property (nonatomic, strong, readonly) NSDictionary* bidInfo;
- (double)getBid;
@end

@protocol ATIMSdk<NSObject>
+(NSString *)getVersion;
+(void)initWithAccountID:(NSString *)accountID andCompletionHandler:(void (^)(NSError * ))completionBlock;
+(void) updateGDPRConsent:(NSDictionary *)consentDictionary;
@end

@interface ATInmobiBaseManager : ATNetworkBaseManager

+ (void)checkInitiationStatusWithServerInfo:(NSDictionary *)serverInfo requestItem:(ATInmobiBiddingRequest *)request;
@end

NS_ASSUME_NONNULL_END
