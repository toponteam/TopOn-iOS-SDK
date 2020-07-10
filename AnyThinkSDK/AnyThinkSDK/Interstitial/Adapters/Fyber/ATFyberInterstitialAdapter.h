//
//  ATFyberInterstitialAdapter.h
//  AnyThinkFyberInterstitialAdapter
//
//  Created by Topon on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATFyberInterstitialAdapter : NSObject

@end


typedef NS_ENUM(NSInteger, IAGDPRConsentType) {
    IAGDPRConsentTypeUnknown = -1,
    IAGDPRConsentTypeDenied = 0,
    IAGDPRConsentTypeGiven = 1
};

@protocol ATIASDKCore <NSObject>
@property (atomic, strong, nullable, readonly) NSString *appID;
@property (atomic) IAGDPRConsentType GDPRConsent;
@property (atomic, nullable) NSString *GDPRConsentString;
@property (atomic, nullable) NSString *CCPAString;
+ (instancetype _Null_unspecified)sharedInstance;
- (void)initWithAppID:(NSString * _Nonnull)appID;
- (NSString * _Null_unspecified)version;
- (void)clearGDPRConsentData;
@end

@protocol IAAdRequestBuilder <NSObject>
@required
@property (nonatomic) BOOL useSecureConnections;
@property (nonatomic, copy, nonnull) NSString *spotID;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, copy, nullable) NSString *keywords;
@optional
@property (nonatomic) BOOL muteAudio;
@end

@protocol ATIAAdRequest <NSObject>
@property (nonatomic, strong, nullable, readonly) NSString *unitID;
+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAAdRequestBuilder> _Nonnull builder))buildBlock;
@end

@protocol IAContentController <NSObject>
@end

@protocol IAUnitControllerBuilderProtocol <NSObject>
@required
- (void)addSupportedContentController:(id<IAContentController>)supportedContentController;
@end

@protocol IAVideoContentDelegate;
@protocol IAVideoContentControllerBuilder <NSObject>
@required
@property (nonatomic, weak, nullable) id<IAVideoContentDelegate> videoContentDelegate;
@end

@protocol ATIAVideoContentController <IAContentController>
+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAVideoContentControllerBuilder> _Nonnull builder))buildBlock;
@property (nonatomic, readwrite, getter=isMuted) BOOL muted;
- (void)play;
- (void)pause;
@end

@protocol IAVideoContentDelegate <NSObject>
@optional
- (void)IAVideoCompleted:(id<ATIAVideoContentController>)contentController;
- (void)IAVideoContentController:(id<ATIAVideoContentController>)contentController videoInterruptedWithError:(NSError * _Nonnull)error;
- (void)IAVideoContentController:(id<ATIAVideoContentController>)contentController videoDurationUpdated:(NSTimeInterval)videoDuration;
- (void)IAVideoContentController:(id<ATIAVideoContentController>)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;
@end


@protocol IAUnitController <NSObject>
@end

@protocol IAUnitDelegate <NSObject>
@required
- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(id<IAUnitController>)unitController;
@optional
- (void)IAAdDidReceiveClick:(id<IAUnitController>)unitController;
- (void)IAAdWillLogImpression:(id<IAUnitController>)unitController;
- (void)IAAdDidReward:(id<IAUnitController>)unitController;
- (void)IAUnitControllerWillPresentFullscreen:(id<IAUnitController>)unitController;
- (void)IAUnitControllerDidPresentFullscreen:(id<IAUnitController>)unitController;
- (void)IAUnitControllerWillDismissFullscreen:(id<IAUnitController>)unitController;
- (void)IAUnitControllerDidDismissFullscreen:(id<IAUnitController>)unitController;
- (void)IAUnitControllerWillOpenExternalApp:(id<IAUnitController>)unitController;
@end

@protocol IAFullscreenUnitControllerBuilder <IAUnitControllerBuilderProtocol>
@required
@property (nonatomic, weak, nullable) id<IAUnitDelegate> unitDelegate;
@end

@protocol ATIAFullscreenUnitController <IAUnitController>
+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAFullscreenUnitControllerBuilder> _Nonnull builder))buildBlock;
- (void)showAdAnimated:(BOOL)flag completion:(void (^ _Nullable)(void))completion;
@end

@protocol ATIAAdSpot;
typedef void (^IAAdSpotAdResponseBlock)(id<ATIAAdSpot> _Nullable adSpot, id _Nullable adModel, NSError * _Nullable error);

@protocol IAAdSpotBuilder <NSObject>

@required
@property (atomic, copy, nonnull) id<ATIAAdRequest> adRequest;
- (void)addSupportedUnitController:(id<ATIAFullscreenUnitController>_Nonnull)supportedUnitController;
@end

@protocol ATIAAdSpot<NSObject>
@property (nonatomic, strong, readonly, nullable) id model;
+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAAdSpotBuilder> _Nonnull builder))buildBlock;
- (void)fetchAdWithCompletion:(IAAdSpotAdResponseBlock _Nonnull)completionHandler;
@end

@protocol IAMRAIDContentDelegate <NSObject>
@end
@protocol IAMRAIDContentControllerBuilder <NSObject>

@required
@property (nonatomic, weak, nullable) id<IAMRAIDContentDelegate> MRAIDContentDelegate;

@end

@protocol ATIAMRAIDContentController <IAContentController>
+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAMRAIDContentControllerBuilder> _Nonnull builder))buildBlock;
@end

NS_ASSUME_NONNULL_END
