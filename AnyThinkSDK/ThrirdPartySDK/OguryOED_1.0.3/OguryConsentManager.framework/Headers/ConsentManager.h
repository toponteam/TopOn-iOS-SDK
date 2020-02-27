//
//  ConsentManager.h
//  OguryConsentManager
//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import "OGYConstants.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^AskConsentCompletionBlock)(NSError * _Nullable error,ConsentManagerAnswer answer);

@interface ConsentManager : NSObject

+ (ConsentManager*)sharedManager;
-(void)askWithViewController:(UIViewController *)viewController assetKey:(NSString *)assetKey andCompletionBlock:(AskConsentCompletionBlock)completionBlock;
-(void)editWithViewController:(UIViewController *)viewController assetKey:(NSString *)assetKey andCompletionBlock:(AskConsentCompletionBlock)completionBlock;
-(NSString *)getIABConsentString;
-(BOOL)isPurposeAccepted:(ConsentManagerPurpose)purpose;
-(BOOL)isAccepted:(NSString *)slug;
-(NSString *)consentSDKVersion;
-(BOOL)gdprApplies;
@end

NS_ASSUME_NONNULL_END
