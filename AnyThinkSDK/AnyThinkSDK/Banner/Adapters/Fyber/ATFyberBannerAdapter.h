//
//  ATFyberBannerAdapter.h
//  AnyThinkFyberBannerAdapter
//
//  Created by Martin Lau on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATFyberBannerAdapter : NSObject

@end

@protocol ATIASDKCore<NSObject>
- (void)initWithAppID:(NSString * _Nonnull)appID;
@property (atomic) NSInteger GDPRConsent;
@property (atomic, nullable) NSString *GDPRConsentString;
@property (atomic, nullable) NSString *CCPAString;
+ (instancetype _Null_unspecified)sharedInstance;
- (NSString * _Null_unspecified)version;
@end


@protocol IAAdRequestBuilder <NSObject>
@property (nonatomic) BOOL useSecureConnections;
@property (nonatomic, copy, nonnull) NSString *spotID;

@optional

/**
 *  @brief In case is enabled and the responded creative supports this feature, the creative will start interacting without sound.
 */
@property (nonatomic) BOOL muteAudio;

@end

@protocol ATIAAdRequest<NSObject>
@property (nonatomic, strong, nullable, readonly) NSString *unitID;
+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAAdRequestBuilder> _Nonnull builder))buildBlock;
@end

@protocol IAUnitDelegate<NSObject>
@end
@protocol IAViewUnitControllerBuilder <NSObject>
@required
@property (nonatomic, weak, nullable) id<IAUnitDelegate> unitDelegate;
- (void)addSupportedContentController:(id _Nonnull)supportedContentController;
@end

@protocol ATIAAdView;
@protocol ATIAViewUnitController<NSObject>
@property (nonatomic, strong, readonly, nullable) UIView* adView;
+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAViewUnitControllerBuilder> _Nonnull builder))buildBlock;
- (void)showAdInParentView:(UIView * _Nonnull)parentView;
@end

@protocol ATIAAdSpot;
typedef void (^IAAdSpotAdResponseBlock)(id<ATIAAdSpot> _Nullable adSpot, id _Nullable adModel, NSError * _Nullable error);

@protocol IAAdSpotBuilder <NSObject>

@required
@property (atomic, copy, nonnull) id<ATIAAdRequest> adRequest;
- (void)addSupportedUnitController:(id<ATIAViewUnitController>_Nonnull)supportedUnitController;
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

@protocol ATIAMRAIDContentController<NSObject>
+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAMRAIDContentControllerBuilder> _Nonnull builder))buildBlock;
@end

