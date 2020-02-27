//
//  CTMediaView.h
//  CTSDK
//
//  Created by yeahmobi on 2018/5/2.
//  Copyright © 2018年 Mirinda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTVideoViewController.h"
#import "CTNativeVideoModel.h"

@interface CTMediaView : UIView
@property (nonatomic, strong) CTVideoViewController *videoController;
@property (nonatomic, strong) CTNativeVideoModel *NativeVideoAd;
@property (nonatomic, assign) BOOL autoplayEnabled; //auto controll video play or pause, default : NO
@property (nonatomic, assign) BOOL WWANPlayEnabled; //allow video play in mobile network (3g/4g etc.) , default : NO
@end
