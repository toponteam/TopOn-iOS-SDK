//
//  IAUserData.h
//  IASDKCore
//
//  Created by Inneractive on 19/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IAInterfaceBuilder.h"

typedef NS_ENUM(NSInteger, IAUserGenderType) {
    IAUserGenderTypeUnknown = 0,
    IAUserGenderTypeMale,
    IAUserGenderTypeFemale,
    IAUserGenderTypeOther,
};

@protocol IAUserDataBuilder <NSObject>

@required

@property (nonatomic) NSUInteger age;
@property (nonatomic) IAUserGenderType gender;
@property (nonatomic, copy, nullable) NSString *zipCode;

@end

@interface IAUserData : NSObject <IAInterfaceBuilder, IAUserDataBuilder, NSCopying>

+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAUserDataBuilder> _Nonnull builder))buildBlock;

@end
