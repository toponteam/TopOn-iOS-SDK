//
//  KSAdPos.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/11/14.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KSAdPosAdType) {
    KSAdPosAdTypeUnknown        =           0,
    KSAdPosAdTypeBanner,
    KSAdPosAdTypeInterstitial,
    KSAdPosAdTypeSplash,
    KSAdPosAdTypeSplash_Cache,
    KSAdPosAdTypeFeed,
    KSAdPosAdTypePaster,
    KSAdPosAdTypeRewardVideo,
    KSAdPosAdTypeFullScreenVideo,
    KSAdPosAdTypeDrawVideo,
};

typedef NS_ENUM(NSInteger, KSAdPosPosition) {
    KSAdPosPositionTop = 1,
    KSAdPosPositionBottom = 2,
    KSAdPosPositionFeed = 3,
    KSAdPosPositionMiddle = 4,
    KSAdPosPositionFullScreen = 5,
};


NS_ASSUME_NONNULL_BEGIN

@interface KSAdPos : NSObject

@end

NS_ASSUME_NONNULL_END
