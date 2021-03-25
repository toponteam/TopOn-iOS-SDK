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
#import "UIColor+KAKit.h"
#import "ATOfferFeedBackView.h"
#import "ATAgentEvent.h"

#define videoWidth self.view.bounds.size.width
#define videoHeight self.view.bounds.size.height

@interface ATOfferFullScreenPictureViewController ()<ATOfferFeedBackViewDelegate>
@property (nonatomic , strong)UIView *backView;
@property (nonatomic , strong)UIView *endCardBackView;
@property (nonatomic , strong)UIImageView *endCardImage;

@property (nonatomic , strong)UIButton *closeBtn;
@property (nonatomic , strong)UIButton *feedbackBtn;

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
    if (self.offerModel.crtType != ATOfferCrtTypeOneImage && [Utilities isEmpty:self.offerModel.title] == NO) {
        [self.view addSubview:self.bannerView];
    }else {
        // when there is no a banner view, put the logo image in the low right corner
        NSString * logoPath = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.logoURL];
        if(logoPath != nil){
            NSData *imageData = [NSData dataWithContentsOfFile:logoPath];
            UIImage *logoImage = [UIImage imageWithData:imageData];
            
            CGFloat value = 0;
            if (@available(iOS 11.0, *)) {
                value = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
            }
            CGRect frame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 15 - value, 50, 15);
            UIImageView *logoImgView = [[UIImageView alloc]initWithFrame:frame];

            [self.view addSubview:logoImgView];
            logoImgView.image = logoImage;
        }
    }
//    [self.view addSubview:self.closeBtn];
}

- (void)feedback:(UIButton *)btn event:(UIEvent *)event {
    if (self.offerModel.feedback) {
        return;
    }
    ATOfferFeedBackView *feedback = [ATOfferFeedBackView create];
    feedback.delegate = self;
    [feedback showInView:self.view];
}

- (void)clickMyOfferBanner:(UIButton *)btn event:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint relativePoint = [touch locationInView:btn];
    CGPoint point = [btn convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
    NSDictionary *dic = [self tapInfoWithPoint:point relativePoint:relativePoint];
    self.offerModel.tapInfoDict = dic;
    
    if ([self.delegate respondsToSelector:@selector(offerFullScreenPictureDidClickAdWithOfferModel:extra:)]) {
        [self.delegate offerFullScreenPictureDidClickAdWithOfferModel:self.offerModel extra:dic];
    }
}

- (void)clickMyOfferBanner:(UITapGestureRecognizer *)tap {

    CGPoint relativePoint = [tap locationInView:tap.view];
    CGPoint point = [tap.view convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
    relativePoint = point;
    NSDictionary *dic = [self tapInfoWithPoint:point relativePoint:relativePoint];
    self.offerModel.tapInfoDict = dic;
    
    if ([self.delegate respondsToSelector:@selector(offerFullScreenPictureDidClickAdWithOfferModel:extra:)]) {
        [self.delegate offerFullScreenPictureDidClickAdWithOfferModel:self.offerModel extra:dic];
    }
}

-(void)clickMyOfferClose:(UIButton *)btn event:(UIEvent *)event {
    
    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint relativePoint = [touch locationInView:self.view];
    CGPoint point = [btn convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
    NSDictionary *dic = [self tapInfoWithPoint:point relativePoint:relativePoint];
    self.offerModel.tapInfoDict = dic;
    self.offerModel.feedback = NO;
    if ([self.delegate respondsToSelector:@selector(offerFullScreenPictureEndCardDidCloseWithOfferModel:extra:)]) {
        [self.delegate offerFullScreenPictureEndCardDidCloseWithOfferModel:self.offerModel extra:dic];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//不可切换横竖屏
-(BOOL)shouldAutorotate {
    return NO;
}

-(UIButton *)closeBtn {
    if(!_closeBtn){
        UIEdgeInsets safeAreaInsets = [Utilities safeAreaInsets];
        _closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 55, safeAreaInsets.top + 5, 40, 40)];
        _closeBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_closeBtn setImage:[UIImage anythink_imageWithName:@"offer_video_close"] forState:UIControlStateNormal];
//        _closeBtn.backgroundColor = [UIColor redColor];
        [_closeBtn addTarget:self action:@selector(clickMyOfferClose:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)feedbackBtn {
    if(!_feedbackBtn){
        _feedbackBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        CGFloat width = [Utilities isMandarin] ? 54 : 98;
        _feedbackBtn.frame = CGRectMake(CGRectGetMinX(self.closeBtn.frame) - 10 - width, CGRectGetMinY(self.closeBtn.frame) + 5, width, 30);
        _feedbackBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_feedbackBtn setTitle:[Utilities isMandarin] ? @"反馈" : @"Feedback" forState:UIControlStateNormal];
        _feedbackBtn.layer.cornerRadius = 7;
        _feedbackBtn.clipsToBounds = YES;
        [_feedbackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_feedbackBtn setBackgroundImage:[[[UIColor colorWithHexString:@"666666"] colorWithAlphaComponent:0.5] imageWithSize:_feedbackBtn.frame.size] forState:UIControlStateNormal];
        [_feedbackBtn setBackgroundImage:[[[UIColor colorWithHexString:@"333333"]colorWithAlphaComponent:0.5] imageWithSize:_feedbackBtn.frame.size] forState:UIControlStateHighlighted];
        [_feedbackBtn addTarget:self action:@selector(feedback:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _feedbackBtn;
}

- (CGSize)getBoundsByImageSize:(CGSize)size {
    
    if (size.width == 0 || size.height == 0) {
        return CGSizeZero;
    }
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    width  = screenWidth;
    if (size.width >= size.height) {
        width  = screenWidth;
        height = screenWidth/size.width * size.height;
        return CGSizeMake(width, height);
    }
    
    height = screenHeight;
    width  = screenHeight/size.height * size.width;
    return CGSizeMake(width, height);
}

-(void)endCard {
    if ([self.delegate respondsToSelector:@selector(offerFullScreenPictureEndCardDidShowWithOfferModel:extra:)]) {
        [self.delegate offerFullScreenPictureEndCardDidShowWithOfferModel:self.offerModel extra:nil];
    }
    
    NSString * path = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:imageData];
    
    CGSize imgViewSize = [self getBoundsByImageSize:image.size];
    self.endCardImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imgViewSize.width, imgViewSize.height)];
    self.endCardImage.center = self.endCardBackView.center;
    
    [self.endCardImage setImage:image];
    self.endCardImage.contentMode = UIViewContentModeScaleAspectFit;
    UIImageView *fuzzyImage = [[UIImageView alloc]initWithImage:image];
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:effect];
    effectView.frame = self.view.frame;
    [self.view addSubview:self.endCardBackView];
    [self.endCardBackView addSubview:fuzzyImage];
    [fuzzyImage addSubview:effectView];
    [self.endCardBackView addSubview:self.endCardImage];
    
    if (self.setting.endCardClickable == ATEndCardClickableFullscreen) {
        UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickMyOfferBanner:)];
        gest.numberOfTapsRequired = 1;
        [_endCardBackView addGestureRecognizer:gest];
    }
    
    if (self.offerModel.interActableArea == ATOfferInterActableAreaCTA) {
        UIButton *ctaButton = [UIButton internal_autolayoutButtonWithType:UIButtonTypeCustom];
        UIEdgeInsets safeAreaInsets = [Utilities safeAreaInsets];
        [ctaButton setTitle:self.offerModel.CTA forState:0];
        [ctaButton setBackgroundImage:[[UIImage anythink_imageWithName:@"native_splash_cta_btn_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(.0f, 35.0f, .0f, 35.0f) resizingMode:UIImageResizingModeStretch] forState:0];
        [self.endCardBackView addSubview:ctaButton];
        [ctaButton addTarget:self action:@selector(clickMyOfferBanner:event:) forControlEvents:UIControlEventTouchUpInside];
        [self.endCardBackView addConstraint:[NSLayoutConstraint constraintWithItem:ctaButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.endCardBackView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.endCardBackView addConstraint:[NSLayoutConstraint constraintWithItem:ctaButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.endCardBackView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10-safeAreaInsets.bottom]];
        [self.endCardBackView addConstraint:[NSLayoutConstraint constraintWithItem:ctaButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:222]];
        [self.endCardBackView addConstraint:[NSLayoutConstraint constraintWithItem:ctaButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:58]];
    }

    NSInteger rate = self.setting.closeBtnDelayRate;
    if (rate == 0) {
        [self addCloseAndFeedbackBtn];
        return;
    }
    
    int random = (arc4random() % 100 + 1);
    if (random > rate) {
        [self addCloseAndFeedbackBtn];
        return;
    }
    
    NSInteger newRandom = (arc4random() % (self.setting.closeBtnDelayMaxTime - self.setting.closeBtnDelayMinTime) + self.setting.closeBtnDelayMinTime);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(newRandom * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addCloseAndFeedbackBtn];
    });
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
        
        UIEdgeInsets safeAreaInsets = [Utilities safeAreaInsets];
        _bannerView = [[ATOfferVideoBannerView alloc]initWithFrame:CGRectMake(x, videoHeight - safeAreaInsets.bottom - height -8, width, height) offerModel:_offerModel];
        NSString * path = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL];
        [_bannerView.iconImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:path]]];
        _bannerView.title.text = self.offerModel.title;
        [_bannerView.desc setText:self.offerModel.text];
        [_bannerView.ctaButton setTitle:self.offerModel.CTA forState:UIControlStateNormal];
        [_bannerView.ctaButton addTarget:self action:@selector(clickMyOfferBanner:event:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString * logoPath = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.logoURL];
        if(logoPath != nil){
            NSData *imageData = [NSData dataWithContentsOfFile:logoPath];
            [_bannerView.logoImage setImage:[UIImage imageWithData:imageData]];
        }
        if (self.setting.endCardClickable != ATEndCardClickableCTA) {
            UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickMyOfferBanner:)];
            gest.numberOfTapsRequired = 1;
            [_bannerView addGestureRecognizer:gest];
        }
    }
    return _bannerView;
}

- (void)addCloseAndFeedbackBtn {
    [self.endCardBackView addSubview:self.closeBtn];
    if (self.offerModel.feedback) {
        return;
    }
    if (self.offerModel.offerModelType == ATOfferModelMyOffer ||
        self.offerModel.offerModelType == ATOfferModelADX ||
        self.offerModel.offerModelType == ATOfferModelOnlineApi ) {
        [self.endCardBackView addSubview:self.feedbackBtn];
    }
}

- (NSDictionary *)tapInfoWithPoint:(CGPoint)point relativePoint:(CGPoint)relativePoint {
    
//    NSDictionary *ky_absolute = @{@"down_x":@(relativePoint.x),
//                                  @"down_y":@(relativePoint.y),
//                                  @"up_x":  @(relativePoint.x),
//                                  @"up_y":  @(relativePoint.y)
//    };
//    CGFloat width  = [UIScreen mainScreen].bounds.size.width;
//    CGFloat height = [UIScreen mainScreen].bounds.size.height;
//
//    NSDictionary *ky_relative = @{@"down_x":@(relativePoint.x/width * 1000),
//                                  @"down_y":@(relativePoint.y/height * 1000),
//                                  @"up_x":  @(relativePoint.x/width * 1000),
//                                  @"up_y":  @(relativePoint.y/height * 1000)
//    };
    NSDictionary *dic = @{kATOfferTrackerGDTDownX:       @(point.x),
                                kATOfferTrackerGDTDownY: @(point.y),
                                kATOfferTrackerGDTUpX:   @(point.x),
                                kATOfferTrackerGDTUpY:   @(point.y),
                                kATOfferTrackerGDTWidth: @([UIScreen mainScreen].nativeScale * [[UIScreen mainScreen]bounds].size.width),
                                kATOfferTrackerGDTHeight:@([UIScreen mainScreen].nativeScale * [[UIScreen mainScreen]bounds].size.height),
                                kATOfferTrackerGDTRequestWidth: @([UIScreen mainScreen].nativeScale * [[UIScreen mainScreen]bounds].size.width),
                                kATOfferTrackerGDTRequestHeight:@([UIScreen mainScreen].nativeScale * [[UIScreen mainScreen]bounds].size.height),
                        
                          kATOfferTrackerRelativeDownX:   @(relativePoint.x),
                          kATOfferTrackerRelativeDownY:   @(relativePoint.y),
                          kATOfferTrackerRelativeUpX:     @(relativePoint.x),
                          kATOfferTrackerRelativeUpY:     @(relativePoint.y),
//                          kATOfferTrackerKYAbsoluteCoord: ky_absolute,
//                          kATOfferTrackerKYRelativeCoord: ky_relative
                        
    };
    return dic;
}

// MARK:- feedback view delegate
- (void)feedbackView:(ATOfferFeedBackView *)feedback didSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg {
    if ([self.delegate respondsToSelector:@selector(offerFullScreenPictureFeedbackViewDidSelectItemAtIndex:offerModel:extraMsg:)]) {
        [self.delegate offerFullScreenPictureFeedbackViewDidSelectItemAtIndex:index offerModel:self.offerModel extraMsg:msg];
    }
    self.feedbackBtn.hidden = YES;
}
@end
