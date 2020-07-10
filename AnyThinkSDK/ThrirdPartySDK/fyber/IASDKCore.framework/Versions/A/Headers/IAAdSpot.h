//
//  IAAdSpot.h
//  IASDKCore
//
//  Created by Inneractive on 13/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IAInterfaceBuilder.h"

@class IAAdRequest;
@class IAMediation;
@class IAAdModel;
@class IAAdSpot;

@class IAUnitController;

typedef void (^IAAdSpotAdResponseBlock)(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error);

@protocol IAAdSpotBuilder <NSObject>

@required
@property (atomic, copy, nonnull) IAAdRequest *adRequest;
@property (nonatomic, copy, nonnull) IAMediation *mediationType;

- (void)addSupportedUnitController:(IAUnitController * _Nonnull)supportedUnitController;

@end

@interface IAAdSpot : NSObject <IAInterfaceBuilder, IAAdSpotBuilder>

/**
 *  @brief The unit controller, that is relevant to the received ad unit.
 */
@property (nonatomic, weak, readonly, nullable) IAUnitController *activeUnitController;

@property (nonatomic, strong, readonly, nullable) IAAdModel *model;

+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAAdSpotBuilder> _Nonnull builder))buildBlock;

/**
 *  @brief Fetch ad. Ad response block must be provided, otherwise fetch will not be performed.
 *
 *  @discussion Ad response block will be retained, therefore 'self' should not be used insided this block. Please use weak reference to 'self' instead.
 * This block will be invoked both on first ad request result, and on ad refresh result.
 */
- (void)fetchAdWithCompletion:(IAAdSpotAdResponseBlock _Nonnull)completionHandler;

/**
 *  @brief Use for being notified about ad reload result.
 *  @discussion IA SDK will copy this block, if you want to clean it, you should provide a 'nil' value.
 */
- (void)setAdRefreshCompletion:(IAAdSpotAdResponseBlock _Nonnull)completionHandler;

- (void)refreshAd;

@end
