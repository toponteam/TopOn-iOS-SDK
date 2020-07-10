//
//  IAViewUnitController.h
//  IASDKCore
//
//  Created by Inneractive on 14/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "IAInterfaceBuilder.h"
#import "IAUnitController.h"
#import "IAUnitDelegate.h"

/**
 *  @brief Builder block. 'self' can be used. The block is not retained.
 */
@protocol IAViewUnitControllerBuilder <IAUnitControllerBuilderProtocol>

@required
@property (nonatomic, weak, nullable) id<IAUnitDelegate> unitDelegate;

@end

@class IAAdView;

@interface IAViewUnitController : IAUnitController <IAInterfaceBuilder, IAViewUnitControllerBuilder>

@property (nonatomic, strong, readonly, nullable) IAAdView *adView;

+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAViewUnitControllerBuilder> _Nonnull builder))buildBlock;

- (void)showAdInParentView:(UIView * _Nonnull)parentView;

@end
