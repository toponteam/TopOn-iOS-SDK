//
//  ATAppSettingManager.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 09/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAPI+Internal.h"
#import "ATModel.h"
//The keyed value stores the flag as to whether or not clients are expected to upload the offer metadata
extern NSString *const kATAppSettingGDPAFlag;
extern NSString *const kATAppSettingGDPRPolicyURLKey;
extern NSString *const kATSDKCustomChannel;
extern NSString *const kATSDKInhouseBiddingUrl;

@class ATTrackingSetting;
@class ATADXSetting;
@class ATOnlineApiSetting;
@interface ATAppSettingManager : NSObject
+(instancetype)sharedManager;
-(void) requestAppSettingCompletion:(void(^)(NSDictionary *setting, NSError *error))completion;
/**
 * The following setting accessing methods are thread-safe.
 */
-(BOOL) currentSettingExpired;
-(NSTimeInterval) splashTolerateTimeout;
-(BOOL) usesServerDataConsentSet;
- (BOOL)complyWithCOPPA;
- (BOOL)complyWithCCPA;
-(NSTimeInterval) psIDInterval;
-(NSTimeInterval) psIDIntervalForHotLaunch;
-(ATDataConsentSet) serverDataConsentSet;
-(ATDataConsentSet) commonTkDataConsentSet;
-(NSUInteger) myOfferMaxResourceLength;
-(NSArray *) preinitInfoArr;
-(BOOL)limitThirdPartySDKDataCollection:(BOOL*)setThirdPartySDK networkFirmID:(NSInteger)networkFirmID;
-(BOOL)shouldUploadProtectedFields;
/**
 * If the SDK has been init-ed the first time, the data protected area list will be the embeded one(stored in the Info.plist of the SDK bundle under the key Data Protection Area); or it'll be the one that's returned by the server.
 */
-(BOOL) inDataProtectedArea;
-(void) getUserLocationWithCallback:(void(^)(ATUserLocation location))callback;
@property(nonatomic, readonly) NSDictionary *currentSetting;
@property(nonatomic, readonly) NSDictionary *defaultSetting;
@property(nonatomic, readonly) ATTrackingSetting *trackingSetting;
@property(nonatomic, readonly) ATADXSetting *adxSetting;
@property(nonatomic, readonly) ATOnlineApiSetting *onlineApiSetting;

@property(nonatomic, readonly) NSString *ABTestID;

/*
 *up id
 */
@property(nonatomic, readonly) NSString* ATID;
/**
 * sysid
 */
@property(nonatomic, readonly) NSString* SYSID;
/**
 * bkupid
 */
@property(nonatomic, readonly) NSString* BKUPID;

@property(nonatomic, readonly) NSString *clickNotificationName;
@property(nonatomic, readonly) NSString *showNotificationName;
@end

@interface ATTrackingSetting:ATModel
+(instancetype) defaultSetting;
@property(nonatomic, readonly) NSString *trackerAddress;
@property(nonatomic, readonly) NSInteger trackerNumberThreadhold;
@property(nonatomic, readonly) NSTimeInterval trackerInterval;
@property(nonatomic, readonly) BOOL sendsDataEveryInterval;
@property(nonatomic, readonly) NSString *agentEventAddress;
@property(nonatomic, readonly) NSInteger agentEventNumberThreadhold;
@property(nonatomic, readonly) NSTimeInterval agentEventInterval;
@property(nonatomic, readonly) NSArray<NSString*>* agentEventDropNetworks;
@property(nonatomic, readonly) NSDictionary<NSString*, NSArray<NSString*>*>* agentEventDropFormats;
@property(nonatomic, readonly) NSDictionary<NSString*, NSArray<NSString*>*>* agentEventRTFormats;
/*
 *for batch upload
 */
@property(nonatomic, readonly) NSInteger agentEventBatNumberThreadhold;
@property(nonatomic, readonly) NSInteger agentEventBatInterval;
//TCP
@property(nonatomic, readonly) NSString *trackerTCPAddress;
@property(nonatomic, readonly) NSInteger trackerTCPPort;
@property(nonatomic, readonly) NSInteger trackerTCPType;
@property(nonatomic, readonly) NSString *trackerTCPRate;

//TC
@property(nonatomic, readonly) NSArray<NSString*>* tcHosts;
@property(nonatomic, readonly) NSDictionary<NSString*, NSArray<NSString*>*>* tcTKSkipFormats;
@property(nonatomic, readonly) NSArray<NSString*>* tcTKSkipNetworks;
@end

@interface ATADXSetting:ATModel
+(instancetype) defaultSetting;
@property(nonatomic, readonly) NSString *reqHttpAddress;
@property(nonatomic, readonly) NSString *reqTCPAdress;
@property(nonatomic, readonly) NSInteger reqTCPPort;
@property(nonatomic, readonly) NSInteger reqNetType;

@property(nonatomic, readonly) NSString *bidHttpAddress;
@property(nonatomic, readonly) NSString *bidTCPAdress;
@property(nonatomic, readonly) NSInteger bidTCPPort;
@property(nonatomic, readonly) NSInteger bidNetType;

@property(nonatomic, readonly) NSString *trackerHttpAdress;
@property(nonatomic, readonly) NSString *trackerTCPAdress;
@property(nonatomic, readonly) NSInteger trackerTCPPort;
@property(nonatomic, readonly) NSInteger trackerNetType;
@end

@interface ATOnlineApiSetting:ATModel
+(instancetype) defaultSetting;
@property(nonatomic, readonly) NSString *reqHttpAddress;
@property(nonatomic, readonly) NSString *reqTCPAdress;
@property(nonatomic, readonly) NSInteger reqTCPPort;
@property(nonatomic, readonly) NSInteger reqNetType;

@property(nonatomic, readonly) NSString *trackerHttpAdress;
@property(nonatomic, readonly) NSString *trackerTCPAdress;
@property(nonatomic, readonly) NSInteger trackerTCPPort;
@property(nonatomic, readonly) NSInteger trackerNetType;
@end
