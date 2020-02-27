//
//  AppnextFullAdData.h
//  AppnextSDKCore
//
//  Created by shalom.b on 1/24/18.
//  Copyright © 2018 Appnext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppnextBannerData : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *imageFilePath;
@property (nonatomic, strong) NSString *imageWideFilePath;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *storeRating;
@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL clickable;
@property (nonatomic, assign) BOOL mute;

- (instancetype) initWithTitle:(NSString *) title withDesc:(NSString *) description withImageFilePath:(NSString *) imageFilePath withVideoUrl:(NSString *) videoUrl withImageWideForVideoFilePath:(NSString *) imageWideFilePath
               withStoreRating:(NSString *) storeRating withAutoPlay:(BOOL) autoPlay withClickable:(BOOL) clickable withMute:(BOOL) mute;

@end
