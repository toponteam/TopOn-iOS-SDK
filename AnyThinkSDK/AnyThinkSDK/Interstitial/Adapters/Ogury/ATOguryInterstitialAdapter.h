//
//  ATOguryInterstitialAdapter.h
//  AnyThinkOguryInterstitialAdapter
//
//  Created by Topon on 2019/11/27.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ATOguryAdsErrorType) {
    OguryAdsErrorLoadFailed              = 0,
    OguryAdsErrorNoInternetConnection    = 1,
    OguryAdsErrorAdDisable               = 2,
    OguryAdsErrorProfigNotSynced         = 3,
    OguryAdsErrorAdExpired               = 4,
    OguryAdsErrorSdkInitNotCalled        = 5,
};

typedef NS_ENUM(NSInteger, ATConsentManagerAnswer) {
    ConsentManagerAnswerFullApproval = 1,
    ConsentManagerAnswerPartialApproval = 2,
    ConsentManagerAnswerRefusal = 3,
    ConsentManagerAnswerNoAnswer = 4
};

typedef NS_ENUM(NSInteger, ATConsentManagerPurpose) {
    ConsentManagerPurposeInformation = 1,
    ConsentManagerPurposePersonalisation = 2,
    ConsentManagerPurposeAd = 3,
    ConsentManagerPurposeContent = 4,
    ConsentManagerPurposeMeasurement = 5
};
@interface ATOguryInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);

@end

@protocol ATOguryAds <NSObject>
@property (nonatomic, strong) NSString * sdkVersion;
+ (instancetype)shared;
- (void)setupWithAssetKey:(NSString *)assetKey;
@end


@protocol ATOguryAdsInterstitialDelegate;
@protocol ATOguryAdsInterstitialDelegate
-(void)oguryAdsInterstitialAdAvailable;
-(void)oguryAdsInterstitialAdNotAvailable;
-(void)oguryAdsInterstitialAdLoaded;
-(void)oguryAdsInterstitialAdNotLoaded;
-(void)oguryAdsInterstitialAdDisplayed;
-(void)oguryAdsInterstitialAdClosed;
-(void)oguryAdsInterstitialAdError:(ATOguryAdsErrorType)errorType;
@end

@protocol ATOguryAdsInterstitial <NSObject>
@property (nonatomic, weak) id  <ATOguryAdsInterstitialDelegate> _Nullable interstitialDelegate;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, strong) NSString  * _Nullable adUnitID;

@property (nonatomic,strong) NSString * _Nullable userId;

- (instancetype _Nullable)initWithAdUnitID:( NSString* _Nullable )adUnitID;

- (void)load;
- (void)showInViewController:(UIViewController * _Nonnull)controller;
- (BOOL)isLoaded;
@end

@protocol ATConsentManager <NSObject>
typedef void (^AskConsentCompletionBlock)(NSError * _Nullable error,ATConsentManagerAnswer answer);
+ (id<ATConsentManager>)sharedManager;
-(void)askWithViewController:(UIViewController *)viewController assetKey:(NSString *)assetKey andCompletionBlock:(AskConsentCompletionBlock)completionBlock;
-(void)editWithViewController:(UIViewController *)viewController assetKey:(NSString *)assetKey andCompletionBlock:(AskConsentCompletionBlock)completionBlock;
-(NSString *)getIABConsentString;
-(BOOL)isPurposeAccepted:(ATConsentManagerPurpose)purpose;
-(BOOL)isAccepted:(NSString *)slug;
-(NSString *)consentSDKVersion;
-(BOOL)gdprApplies;
@end

@protocol ATExternalConsentManager <NSObject>
typedef void (^ExternalConsentManagerCompletionBlock)(NSString * response);

+ (void)setConsentWithAssetKey:(NSString * _Nonnull)assetKey iabString:(NSString * _Nonnull)iabString andNonIABVendorsAccepted:(NSArray<NSString*>* _Nullable)nonIABVendorsAccepted;

@end
