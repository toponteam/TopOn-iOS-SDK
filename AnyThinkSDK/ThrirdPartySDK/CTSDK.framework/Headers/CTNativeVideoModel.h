//
//  CTNativeVideoModel.h
//  CTSDK
//
//  Created by yeahmobi on 2018/2/27.
//  Copyright © 2018年 Mirinda. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CTNativeVideoDelegate.h"
#import "CTVideoViewController.h"

@interface CTNativeVideoModel : NSObject
@property (nonatomic, strong)NSString * _Nullable title; //titel
@property (nonatomic, strong)NSString * _Nullable icon; //icon image url
@property (nonatomic, strong)NSString * _Nullable image; //big image url
@property (nonatomic, strong)UIImage * _Nullable AdImage; //Ad big image
@property (nonatomic, strong)NSString * _Nullable desc; //detail description
@property (nonatomic, strong)NSString * _Nullable button; //button words
@property (nonatomic, assign)float star;  //rating
@property (nonatomic, strong)UIImage * _Nullable ADsignImage; //ad sign image
@property (nonatomic, strong)UIImage * _Nullable playBtnImage; //play button image
@property (nonatomic, strong)NSString * _Nullable choices_link_url;
@property (nonatomic, strong)UIViewController * _Nonnull storeViewController; //video-store vc
@property (nonatomic, strong)CTVideoViewController * _Nonnull videoViewController;  //video vc, for users to add on their views and controll video play or stop
@property (nonatomic, strong)NSString * _Nullable slot; //request slotId
//When the ad is showed , call this interface to send impression
- (void)impressionForAd;

//When user click ad, call this interface to show video-appstore by Modal present
- (BOOL)clickToPresentOnParentVC:(UIViewController*_Nonnull)parentViewController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion;

//When user click ad, call this interface to show video-appstore by UINavigationController
- (BOOL)clickToPushOnParentVC:(UIViewController*_Nonnull)parentViewController animated:(BOOL)animated;

//When user click download button, call this interface to open appstore
- (BOOL)clickDownload;


@end

