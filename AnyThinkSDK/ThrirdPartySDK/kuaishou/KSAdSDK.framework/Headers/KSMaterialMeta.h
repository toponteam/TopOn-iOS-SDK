//
//  KSMaterialMeta.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/10/11.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSAdImage.h"
#import "KSAd.h"

typedef NS_ENUM(NSInteger, KSAdMaterialType) {
    KSAdMaterialTypeUnkown      =       0,      // 未知
    KSAdMaterialTypeVideo       =       1,      // 视频
    KSAdMaterialTypeSingle      =       2,      // 单图
    KSAdMaterialTypeAtlas       =       3,      // 多图
};

NS_ASSUME_NONNULL_BEGIN

@interface KSMaterialMeta : NSObject

/// interaction types supported by ads.
@property (nonatomic, assign) KSAdInteractionType interactionType;



/// material pictures.
@property (nonatomic, strong) NSArray<KSAdImage *> *imageArray;

/// ad logo icon.
@property (nonatomic, strong, nullable) KSAdImage *sdkLogo;
@property (nonatomic, strong, nullable) KSAdImage *appIconImage;

/// 0-5
@property (nonatomic, assign) CGFloat appScore;
/// downloadCountDesc.
@property (nonatomic, copy) NSString *appDownloadCountDesc;


/// ad description.
@property (nonatomic, copy) NSString *adDescription;

/// ad source.
@property (nonatomic, copy) NSString *adSource;

/// text displayed on the creative button.
@property (nonatomic, copy) NSString *actionDescription;

/// display format of the in-feed ad, other ads ignores it.
@property (nonatomic, assign) KSAdMaterialType materialType;



// video duration
@property (nonatomic, assign) NSInteger videoDuration;


- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError * __autoreleasing *)error;

@property (nonatomic, strong) KSAdImage *videoCoverImage;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *appName;

@end

NS_ASSUME_NONNULL_END
