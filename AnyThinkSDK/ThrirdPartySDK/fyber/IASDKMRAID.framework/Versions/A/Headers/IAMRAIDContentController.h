//
//  IAMRAIDContentController.h
//  IASDKMRAID
//
//  Created by Inneractive on 19/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceBuilder.h>
#import <IASDKCore/IAContentController.h>

@class IAAdModel;
@protocol IAMRAIDContentDelegate;

@protocol IAMRAIDContentControllerBuilder <NSObject>

@required
@property (nonatomic, weak, nullable) id<IAMRAIDContentDelegate> MRAIDContentDelegate;

@optional
@property (nonatomic, getter=isContentAwareBackground) BOOL contentAwareBackground;

@end

@interface IAMRAIDContentController : IAContentController <IAInterfaceBuilder, IAMRAIDContentControllerBuilder>

+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAMRAIDContentControllerBuilder> _Nonnull builder))buildBlock;

@end
