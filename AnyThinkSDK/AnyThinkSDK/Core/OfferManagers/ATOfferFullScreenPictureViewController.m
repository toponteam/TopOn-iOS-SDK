//
//  ATOfferFullScreenPictureViewController.m
//  AnyThinkMyOffer
//
//  Created by Topon on 8/14/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOfferFullScreenPictureViewController.h"
#import "ATOfferResourceManager.h"
#import "Utilities.h"
#import "ATOfferVideoBannerView.h"
#import <AVFoundation/AVFoundation.h>

#define videoWidth self.view.bounds.size.width
#define videoHeight self.view.bounds.size.height

@interface ATOfferFullScreenPictureViewController ()
@property (nonatomic , strong)UIView *backView;
@property (nonatomic , strong)UIView *endCardBackView;
@property (nonatomic , strong)UIImageView *endCardImage;

@property (nonatomic , strong)UIButton *closeBtn;
@property (nonatomic , strong)ATOfferVideoBannerView *bannerView;
@property (nonatomic , readonly)UIInterfaceOrientation orientation;

@property (nonatomic , strong)ATOfferModel *offerModel;
@property (nonatomic) ATOfferSetting *setting;
@end

@implementation ATOfferFullScreenPictureViewController

- (instancetype)initWithOfferModel:(ATOfferModel*)offerModel rewardedVideoSetting:(ATOfferSetting *)setting {
    self = [super init];
    if (self) {
        _offerModel = offerModel;
        _setting = setting;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self endCard];
    [self.view addSubview:self.bannerView];
    [self.view addSubview:self.closeBtn];
}

-(void)clickMyOfferBanner {
    if ([self.delegate respondsToSelector:@selector(offerFullScreenPictureDidClickAdWithOfferModel:extra:)]) {
        [self.delegate offerFullScreenPictureDidClickAdWithOfferModel:self.offerModel extra:nil];
    }
}

-(void)clickMyOfferClose {
    if ([self.delegate respondsToSelector:@selector(offerFullScreenPictureEndCardDidCloseWithOfferModel:extra:)]) {
        [self.delegate offerFullScreenPictureEndCardDidCloseWithOfferModel:self.offerModel extra:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//不可切换横竖屏
-(BOOL)shouldAutorotate {
    return NO;
}

UIEdgeInsets SafeAreaInsets_ATMyOfferFullScreenPictureVC() {
    return ([[UIApplication sharedApplication].keyWindow respondsToSelector:@selector(safeAreaInsets)] ? [UIApplication sharedApplication].keyWindow.safeAreaInsets : UIEdgeInsetsZero);
}

-(UIButton *)closeBtn {
    if(!_closeBtn){
        UIEdgeInsets safeAreaInsets = SafeAreaInsets_ATMyOfferFullScreenPictureVC();
        _closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 65, safeAreaInsets.top + 5, 40, 40)];
        _closeBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_closeBtn setImage:[UIImage anythink_imageWithName:@"offer_video_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(clickMyOfferClose) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(void)endCard {
    if ([self.delegate respondsToSelector:@selector(offerFullScreenPictureEndCardDidShowWithOfferModel:extra:)]) {
        [self.delegate offerFullScreenPictureEndCardDidShowWithOfferModel:self.offerModel extra:nil];
    }
    
    NSString * path = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:imageData];
    self.endCardImage = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.endCardImage setImage:image];
    UIImageView *fuzzyImage = [[UIImageView alloc]initWithImage:image];
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:effect];
    effectView.frame = self.view.frame;
    self.endCardImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.endCardBackView];
    [self.endCardBackView addSubview:fuzzyImage];
    [fuzzyImage addSubview:effectView];
    [self.endCardBackView addSubview:self.endCardImage];
    [self.endCardBackView addSubview:self.closeBtn];
    [self.endCardBackView addSubview:self.bannerView];
    UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickMyOfferBanner)];
    gest.numberOfTapsRequired = 1;
    [_endCardBackView addGestureRecognizer:gest];
}

-(UIView *)endCardBackView {
    if (!_endCardBackView) {
        _endCardBackView = [[UIView alloc]initWithFrame:self.view.frame];
        _endCardBackView.backgroundColor = [UIColor blackColor];
    }
    return _endCardBackView;
}

-(ATOfferVideoBannerView *)bannerView {
    if (!_bannerView) {
        CGFloat height = 80.0;
        CGFloat x = 10.0f;
        CGFloat width = videoWidth - 20;
//        if([Utilities screenOrientation] == @2 && (_offerModel.text.length == 0 && _offerModel.iconURL.length == 0)){
//            x = videoWidth/2 + 10.0f;
//            width = videoWidth/2 - 20.0f;
//        }
        
        UIEdgeInsets safeAreaInsets = SafeAreaInsets_ATMyOfferFullScreenPictureVC();
        _bannerView = [[ATOfferVideoBannerView alloc]initWithFrame:CGRectMake(x, videoHeight - safeAreaInsets.bottom - height -8, width, height) offerModel:_offerModel];
        NSString * path = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL];
        [_bannerView.iconImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:path]]];
        _bannerView.title.text = self.offerModel.title;
        [_bannerView.desc setText:self.offerModel.text];
        [_bannerView.ctaButton setTitle:self.offerModel.CTA forState:UIControlStateNormal];
        [_bannerView.ctaButton addTarget:self action:@selector(clickMyOfferBanner) forControlEvents:UIControlEventTouchUpInside];
        NSString * logoPath = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.logoURL];
        if(logoPath != nil){
            NSData *imageData = [NSData dataWithContentsOfFile:logoPath];
            [_bannerView.logoImage setImage:[UIImage imageWithData:imageData]];
        }
        if (_setting.endCardClickable != ATEndCardClickableCTA) {
            UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickMyOfferBanner)];
            gest.numberOfTapsRequired = 1;
            [_bannerView addGestureRecognizer:gest];
        }
    }
    return _bannerView;
}

@end
