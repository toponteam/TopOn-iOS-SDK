//
//  CTManager.h
//  CTSDK
//  You should call [[CTService shareManager] loadRequestGetCTSDKConfigBySlot_id:@"slotID"] in didFinishLaunchingWithOptions Method

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CTElementModel.h"
#import "CTNativeVideoModel.h"
#import "CTADMRAIDView.h"

typedef enum : NSUInteger {
    CTImageWHRateOneToOne= 0,           //Width:Hight  = 1:1
    CTImageWHRateOnePointNineToOne      //Width:Hight  = 1.9:1
} CTImageWidthHightRate;

typedef enum : NSUInteger {
    CTADBannerSizeW320H50= 0,      //Width = 320  Hight = 50
    CTADBannerSizeW320H100,        //Width = 320  Hight = 100
    CTADBannerSizeW300H250         //Width = 300  Hight = 250
} CTADBannerSize;

@interface CTService : NSObject

#pragma mark - CTService config Method
/**
 You should pass the singleton method to create the object, then calls the requests of the different types of ads.

 @return returns a global instance of CTService
 */
+ (instancetype)shareManager;

/**
 Get CT AD Config in Appdelegate(didFinishLaunchingWithOptions:)

 @param slot_id Ad
 */
- (void)loadRequestGetCTSDKConfigBySlot_id:(NSString *)slot_id;

/**
 For GDPR

 @param consentValue  yes/no/other
 @param consentType   content type is the agreement name you signed with users
 @param complete      state
 */
- (void)uploadConsentValue:(NSString *)consentValue
               consentType:(NSString *)consentType
                  complete:(void(^)(BOOL state))complete;

#pragma mark - Native Ad Interface（Return Ad Elements）
/**
 We recommend use CTNative Interface！！！
 Using inheritance CTNativeAd advertising View customize layout, in prior to add to the parent View will return to the frame and successful nativeModel assigned to a custom View.
 
 @param slot_id         Cloud Tech Native AD ID
 @param delegate        Set Delegate of Ad event(<CTNativeAdDelegate>)
 @param WHRate          Set Image Rate
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Native Element Ad
 @param failure         The request failed Block, retuen error
 */
- (void)getNativeADswithSlotId:(NSString *)slot_id
                      delegate:(id)delegate
           imageWidthHightRate:(CTImageWidthHightRate)WHRate
                        isTest:(BOOL)isTest
                       success:(void (^)(CTNativeAdModel *nativeModel))success
                       failure:(void (^)(NSError *error))failure;


/**
 Preload native ADs with image
 Using inheritance CTNativeAd advertising View customize layout, in prior to add to the parent View will return to the frame and successful nativeModel assigned to a custom View.
 
 @param slot_id         Cloud Tech Native AD ID
 @param delegate        Set Delegate of Ad event(<CTNativeAdDelegate>)
 @param WHRate          Set Image Rate
 @param preloadImage    preload AD images if afferent YES
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Native Element Ad
 @param failure         The request failed Block, retuen error
 */
- (void)preloadNativeADswithSlotId:(NSString *)slot_id
                      delegate:(id)delegate
           imageWidthHightRate:(CTImageWidthHightRate)WHRate
                  preloadImage:(BOOL)preloadImage
                        isTest:(BOOL)isTest
                       success:(void (^)(CTNativeAdModel *nativeModel))success
                       failure:(void (^)(NSError *error))failure;
/**
 Get Keywords Element Native ADs
 Using inheritance CTNativeAd advertising View customize layout, in prior to add to the parent View will return to the frame and successful nativeModel assigned to a custom View.
 
 @param slot_id         Cloud Tech Native AD ID
 @param delegate        Set Delegate of Ad event(<CTNativeAdDelegate>)
 @param WHRate          Set Image Rate
 @param cat             ad type
 @param keyWords        Set Ad Keywords
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Native Element Ad
 @param failure         The request failed Block, retuen error
 */
- (void)getNativeADswithSlotId:(NSString *)slot_id
                      delegate:(id)delegate
           imageWidthHightRate:(CTImageWidthHightRate)WHRate
                         adcat:(NSInteger)cat
                      keyWords:(NSArray *)keyWords
                        isTest:(BOOL)isTest
                       success:(void (^)(CTNativeAdModel *nativeModel))success
                       failure:(void (^)(NSError *error))failure;


/**
 Get Multiterm Element Native ADs
 Using inheritance CTNativeAd advertising View customize layout, in prior to add to the parent View will return to the frame and successful nativeModel assigned to a custom View.
 
 @param slot_id         Cloud Tech Native AD ID
 @param num             Ad numbers
 @param delegate        Set Delegate of Ad event(<CTNativeAdDelegate>)
 @param WHRate          Set Image Rate
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Native Element Ad
 @param failure         The request failed Block, retuen error
 */
-(void)getMultitermNativeADswithSlotId:(NSString *)slot_id
                             adNumbers:(NSInteger)num
                              delegate:(id)delegate
                   imageWidthHightRate:(CTImageWidthHightRate)WHRate
                                isTest:(BOOL)isTest
                               success:(void (^)(NSArray *nativeArr))success
                               failure:(void (^)(NSError *error))failure;


#pragma mark - Banner AD Interface
/**
 Get Banner Ad View (Deprecated)
 
 @param slotid         Cloud Tech Banner AD ID
 @param delegate        Set Delegate of Ad event(<CTAdViewDelegate>)
 @param size          requre Ad Size
 @param containerView   the view which shows ads on
 @param isTest          Use test advertisement or not
 */
- (void)getMRAIDBannerAdWithSlot:(NSString*)slotid delegate:(id)delegate adSize:(CTADBannerSize)size container:(UIView*)containerView isTest:(BOOL)isTest NS_DEPRECATED_IOS(7.0, 12.0);


/**
 Get Banner Ad View
 
 @param slotid         Cloud Tech Banner AD ID
 @param delegate        Set Delegate of Ad event(<CTAdViewDelegate>)
 @param size          requre Ad Size
 @param isTest          Use test advertisement or not
 */
- (void)getMRAIDBannerAdWithSlot:(NSString*)slotid delegate:(id)delegate adSize:(CTADBannerSize)size isTest:(BOOL)isTest;


#pragma mark - AppWall Ad Interface
/**
 Get AppWall ViewController
 First,you must should Call preloadAppWallWithSlotID method,Then get successs,call showAppWallViewController method show Appwall！
 
 @param slot_id         Cloud Tech Native AD ID
 @param customColor     If you want set custom UI,you should create CTCustomColor object
 @param delegate        Set Delegate of Ads event (<CTAppWallDelegate>)
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block
 @param failure         The request failed Block, retuen error
 */
- (void)preloadAppWallWithSlotID:(NSString *)slot_id
                customColor:(CTCustomColor *)customColor
                   delegate:(id)delegate
                     isTest:(BOOL)isTest
                    success:(void(^)())success
                    failure:(void(^)(NSError *error))failure;

/**
 Get App Wall ViewController

 @return AppWallViewController
 */
- (UIViewController *)showAppWallViewController;


#pragma mark - RewardVideo Ad Interface
//Get Reward Video Ads

/**
 Set Rewarded Video Custom Parameters

  @param customParams         custom Params
 
 */
- (void)setCustomParameters:(NSString *)customParams;


/**
 Get RewardVideo Ad
 First,you must should Call (loadRewardVideoWithSlotId:delegate:) method get RewardVideo Ad！Then On his return to the success of the proxy method invokes the （showRewardVideo） method

 @param slot_id         Cloud Tech AD ID
 @param delegate        Set Delegate of Ads event (<CTRewardVideoDelegate>)
 */
- (void)loadRewardVideoWithSlotId:(NSString *)slot_id delegate:(id)delegate;

/**
 show RewardVideo      // We recommendation use [ showRewardVideoWithPresentingViewController: ] interface !
 */
- (void)showRewardVideo;

/**
 show RewardVideo

 @param viewController The view controller on which the interstitial will display
 */
- (void)showRewardVideoWithPresentingViewController:(UIViewController *)viewController;

/**
 CT Reward video is ready to play

 @return YES:you can call show rewardvideo interface / NO:don't call show rewardvideo interface 
 */
- (BOOL)checkRewardVideoIsReady;

#pragma mark - U3D Delegate

/**
 Set U3D Delegate
 */

- (void)setDelegateObjName:(NSString*) delegateName;

#pragma mark - CTSDK Version
/**
 Get SDK Version

 @return SDK Version (NSString class)
 */
- (NSString*)getSDKVersion;


#pragma mark - Native Video Ad Interface
/**
 Get Native video Ad
 Call this interface to get Native Video AD.
 
 @param slot_id         Cloud Tech AD ID
 @param delegate        Set Delegate of Ads event (<CTNativeVideoDelegate>)
 @param WHRate          Set Image Rate
 @param isTest          Use test advertisement or not
 */
- (void)getNativeVideoADswithSlotId:(NSString*)slot_id
                           delegate:(id)delegate
                imageWidthHightRate:(CTImageWidthHightRate)WHRate
                             isTest:(BOOL)isTest;

- (BOOL)isWifi;

#pragma mark -  New Interstitial Ad Interface
/**
 Preload Interstitial Ad
 Call this interface preload Interstitial AD.
 
 @param slotid         Cloud Tech AD ID
 @param delegate        Set Delegate of Ads event (<CTAdViewDelegate>)
 @param isTest          Use test advertisement or not
 */
- (void)preloadMRAIDInterstitialAdWithSlotId:(NSString *)slotid delegate:(id)delegate isTest:(BOOL)isTest;

/**
 Show interstitial ad
 Call this method after preload Interstitial ad success
 */
- (void)mraidInterstitialShow;

/**
 Check interstitial ad to be Ready
 Call this method before show ad
 */
- (BOOL)mraidInterstitialIsReady;
@end
