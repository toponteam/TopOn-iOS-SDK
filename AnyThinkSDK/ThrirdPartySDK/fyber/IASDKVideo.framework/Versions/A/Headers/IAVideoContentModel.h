//
//  IAVideoContentModel.h
//  IASDKVideo
//
//  Created by Inneractive on 12/04/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceBuilder.h>
#import <IASDKCore/IAInterfaceContentModel.h>

typedef enum : NSInteger {
    IAVideoTypeUndefined = 0,
    
    IAVideoTypeMRect,
    
    // evaluation is by: 1. width = min(width,height); 2. width -= padding; 3. height = width;
    // the video content will fill itself inside video player as aspect fill;
    IAVideoTypeSquare,
    
    IAVideoTypeLandscape, // evaluation is by: 1. width = min(width,height); 2. width -= padding; 3. height = (width * 9) / 16;
    IAVideoTypeInterstitial, // fullscreen only in any rotation;
    IAVideoTypeVertical, // fullscreen only in portrait only mode;
    IAVideoTypeRewarded, // interstitial with incentivised;
} IAVideoType;

@class IAVASTModel;

@interface IAVideoContentModel : NSObject <IAInterfaceContentModel>

@property (nonatomic) IAVideoType videoType;
@property (nonatomic, strong, nonnull) IAVASTModel *VASTModel;
@property (nonatomic) NSTimeInterval skipSeconds;

@end
