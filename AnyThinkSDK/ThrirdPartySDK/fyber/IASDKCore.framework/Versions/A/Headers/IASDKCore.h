//
//  IASDKCore.h
//  IASDKCore
//
//  Created by Inneractive on 29/01/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "IALogger.h"

#import "IAInterfaceAllocBlocker.h"
#import "IAInterfaceBuilder.h"
#import "IAInterfaceSingleton.h"

#import "IAGlobalAdDelegate.h"

#import "IAInterfaceUnitController.h"

#import "IAAdSpot.h"
#import "IAAdRequest.h"
#import "IAUserData.h"
#import "IADebugger.h"
#import "IAAdModel.h"

#import "IAUnitController.h"
#import "IAUnitDelegate.h"
#import "IAViewUnitController.h"
#import "IAFullscreenUnitController.h"
#import "IAContentController.h"
#import "IABaseView.h"
#import "IAAdView.h"
#import "IAMRAIDAdView.h"

#import "IAMediation.h"
#import "IAMediationMopub.h"
#import "IAMediationAdMob.h"
#import "IAMediationDFP.h"
#import "IAMediationFyber.h"
#import "IAMediationMax.h"
#import "IAMediationIronSource.h"
#import "IAGDPRConsent.h"

@interface IASDKCore : NSObject <IAInterfaceSingleton>

@property (atomic, strong, nullable, readonly) NSString *appID;

/**
 *  @brief Use this delegate in order to get an info about every shown ad.
 */
@property (atomic, weak, nullable) id<IAGlobalAdDelegate> globalAdDelegate;

/**
 *  @brief The GDPR consent status.
 *
 *  @discussion Use this property in order to set the GDPR consent accoring to your preferences.
 *
 * It can be used as one of the following, in order to allow/restrict:
 *
 * - `[IASDKCore.sharedInstance setGDPRConsent:YES]`
 *
 * - `[IASDKCore.sharedInstance setGDPRConsent:true]`
 *
 * - `IASDKCore.sharedInstance.GDPRConsent = NO`
 *
 * - `IASDKCore.sharedInstance.GDPRConsent = 1`
 *
 * - `IASDKCore.sharedInstance.GDPRConsent = IAGDPRConsentTypeGiven`
 *
 * Or it can be cleared by using the one of the following:
 *
 * - `[IASDKCore.sharedInstance clearGDPRConsentData]`
 *
 * - `IASDKCore.sharedInstance.GDPRConsent = IAGDPRConsentTypeUnknown`. <b>Important</b>: setting the `IAGDPRConsentTypeUnknown`, will clean the `GDPRConsentString` as well.
 *
 * The default (or after calling the `clearGDPRConsentData` method) value is unknown, which is the `IAGDPRConsentTypeUnknown`.
 *
 * The property is thread-safe.
 */
@property (atomic) IAGDPRConsentType GDPRConsent;

/**
 *  @brief Use this property in order to provide a custom GDPR consent data.
 *
 *  @discussion It will be passed as is, without any management/modification.
 */
@property (atomic, nullable) NSString *GDPRConsentString;

/**
 *  @brief Use this property in order to provide the CCPA string. Once it's set, it is saved on a device.
 *
 *  @discussion It will be passed as is, without any validation/modification. In order to clean this data permanently from a device, pass a nil or empty string.
 */
@property (atomic, nullable) NSString *CCPAString;

/**
 *  @brief Singleton method, use for any instance call.
 */
+ (instancetype _Null_unspecified)sharedInstance;

/**
 *  @brief Initialisation of the SDK. Must be invoked before requesting the ads.
 *
 *  @discussion Should be invoked on the main thread. Otherwise it will convert the flow to the main thread.
 *
 *  @param appID A required param. Must be a valid application ID, otherwise the SDK will not be able to request/render the ads.
 */
- (void)initWithAppID:(NSString * _Nonnull)appID;

/**
 *  @brief Get the IASDK current version as the NSString instance.
 *
 *  @discussion The format is `x.y.z`.
 */
- (NSString * _Null_unspecified)version;

/**
 *  @brief Clears all the GDPR related information. The state of the `GDPRConsent` property will become `-1` or `IAGDPRConsentTypeUnknown`.
 */
- (void)clearGDPRConsentData;

@end
