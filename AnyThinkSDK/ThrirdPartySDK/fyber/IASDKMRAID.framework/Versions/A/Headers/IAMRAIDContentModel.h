//
//  IAMRAIDContentModel.h
//  IASDKMRAID
//
//  Created by Inneractive on 27/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceBuilder.h>
#import <IASDKCore/IAInterfaceContentModel.h>

@protocol IAMRAIDContentModelBuilder <NSObject>

@required
@property (nonatomic, strong, nonnull) NSString *HTMLString;

@end

@interface IAMRAIDContentModel : NSObject <IAInterfaceBuilder, IAInterfaceContentModel, IAMRAIDContentModelBuilder>

+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAMRAIDContentModelBuilder> _Nonnull builder))buildBlock;

@end
