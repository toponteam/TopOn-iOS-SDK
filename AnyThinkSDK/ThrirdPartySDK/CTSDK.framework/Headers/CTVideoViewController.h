//
//  CTVideoViewController.h
//  CTSDK
//
//  Created by yeahmobi on 2018/3/6.
//  Copyright © 2018年 Mirinda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CTNativeVideoDataModelAd;

@interface CTVideoViewController : UIViewController
@property (nonatomic, strong) CTNativeVideoDataModelAd *centerModel;
@property (nonatomic , strong) NSString *imageUrl;
@property (nonatomic , strong) UIImage *image;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL WWANPlayEnabled;
@property (nonatomic, assign) BOOL impressionSend;

- (UIView*)getMovieView;
- (void)setFrame:(CGRect) frame;
- (instancetype)initWithFrame:(CGRect)frame andPath:(NSString *)path isMuted:(BOOL)isMuted playLocal:(NSInteger)isLocal videoType:(NSInteger)videoType;
- (void)playVideo;
- (void)stopVideo;
- (void)setMute:(BOOL)isMuted;
- (void)sendImpression;
@end
