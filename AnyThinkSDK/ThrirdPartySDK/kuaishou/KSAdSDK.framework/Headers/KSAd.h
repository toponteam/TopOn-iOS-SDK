//
//  KSAd.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/10/30.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KSAdInteractionType) {
    KSAdInteractionType_Unknown,
    KSAdInteractionType_App,
    KSAdInteractionType_Web,
    KSAdInteractionType_DeepLink,
};

NS_ASSUME_NONNULL_BEGIN

@interface KSAd : NSObject

// 单位:分，只有视频资源下载成功后，这个才可能有值
@property (nonatomic, readonly) NSInteger ecpm;
/// 媒体二次议价
- (void)setBidEcpm:(NSInteger)ecpm;

@end

NS_ASSUME_NONNULL_END
