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
@class ATTrackingSetting;
@interface ATAppSettingManager : NSObject
+(instancetype)sharedManager;
-(void) requestAppSettingCompletion:(void(^)(NSDictionary *setting, NSError *error))completion;
/**
 * The following setting accessing methods are thread-safe.
 */
-(BOOL) currentSettingExpired;
-(NSTimeInterval) splashTolerateTimeout;
-(BOOL) usesServerDataConsentSet;
-(NSTimeInterval) psIDInterval;
-(ATDataConsentSet) serverDataConsentSet;
-(ATDataConsentSet) commonTkDataConsentSet;
-(NSUInteger) myOfferMaxResourceLength;
-(NSArray *) preinitInfoArr;
-(BOOL)limitThirdPartySDKDataCollection:(BOOL*)setThirdPartySDK;
-(BOOL)shouldUploadProtectedFields;
/**
 * If the SDK has been init-ed the first time, the data protected area list will be the embeded one(stored in the Info.plist of the SDK bundle under the key Data Protection Area); or it'll be the one that's returned by the server.
 */
-(BOOL) inDataProtectedArea;
@property(nonatomic, readonly) NSDictionary *currentSetting;
@property(nonatomic, readonly) NSDictionary *defaultSetting;
@property(nonatomic, readonly) ATTrackingSetting *trackingSetting;

/*
 *up id
 */
@property(nonatomic, readonly) NSString* ATID;
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
@property(nonatomic, readonly) NSArray<NSString*>* agentEventDropKeys;
@property(nonatomic, readonly) NSArray<NSString*>* agentEventRTKeys;
/*
 *for batch upload
 */
@property(nonatomic, readonly) NSInteger agentEventBatNumberThreadhold;
@property(nonatomic, readonly) NSInteger agentEventBatInterval;

//TC
@property(nonatomic, readonly) NSArray<NSString*>* tcHosts;
@property(nonatomic, readonly) NSArray<NSNumber*>* tcTKSkipTypes;
@end
