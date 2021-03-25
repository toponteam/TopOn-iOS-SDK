//
//  ATOfferVideoViewController.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATOfferVideoViewController.h"
#import "ATOfferProgressView.h"
#import "ATOfferModel.h"
#import "ATOfferResourceManager.h"
#import "Utilities.h"
#import "ATOfferVideoBannerView.h"
#import <AVFoundation/AVFoundation.h>
#import "ATOfferFeedbackView.h"
#import "UIColor+KAKit.h"
#import "ATAgentEvent.h"

#define videoWidth self.view.bounds.size.width
#define videoHeight self.view.bounds.size.height

NSString *const kCurrentTimeKey = @"currentTime";

@interface ATOfferVideoViewController ()<ATOfferFeedBackViewDelegate>
@property (nonatomic , strong)AVPlayer *player;
@property (nonatomic , strong)AVPlayerItem *playerItem;
@property (nonatomic , strong)UIView *backView;
@property (nonatomic , strong)UIView *endCardBackView;
@property (nonatomic , strong)UIImageView *endCardImage;
@property (nonatomic , strong)id playerObserver;

@property (nonatomic , strong)UIButton *closeBtn;
@property (nonatomic , strong)UIButton *feedbackBtn;
@property (nonatomic , strong)UIButton *voiceBtn;
@property (nonatomic , assign)BOOL isEndCard;
@property (nonatomic , strong)ATOfferVideoBannerView *bannerView;

@property (nonatomic , assign)CGFloat totalTime;
@property (nonatomic , strong)ATOfferProgressView *progressview;
@property (nonatomic , readonly)UIInterfaceOrientation orientation;

@property (nonatomic , strong)ATOfferModel *offerModel;
@property (nonatomic) ATOfferSetting *setting;
@end

@implementation ATOfferVideoViewController

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
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    self.view.backgroundColor = [UIColor blackColor];
    [self layoutAVPlayer];
    [self layoutTopView];
    [self timeObserver];
    
}

-(void)layoutAVPlayer {
    CGRect playerFrame = CGRectMake(0, 0, videoWidth, videoHeight);
    NSString * path = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.videoURL];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    self.totalTime = (asset.duration.value * 1.0 / asset.duration.timescale * 1.0);
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    
    AVPlayerLayer *playerlayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerlayer.frame = playerFrame;
    playerlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerlayer];
    
    [self.player setMuted:!_setting.unMute];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player play];
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
}

-(void)layoutTopView {
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, videoWidth, videoHeight)];
    [self.view addSubview:self.backView];
    UITapGestureRecognizer *tapsVideo = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapVideo:)];
    tapsVideo.numberOfTapsRequired = 1;
    [self.backView addGestureRecognizer:tapsVideo];
    
    [self.view addSubview:self.progressview];
    [self.view addSubview:self.voiceBtn];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if(object == self.playerItem){
        if([keyPath isEqualToString:@"status"]){
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerStatusUnknown:
                    {
                        [ATLogger logMessage:[NSString stringWithFormat:@"ATOfferVideoController: play failed unknown error:%@", self.playerItem.error] type:ATLogTypeInternal];
                    }
                    break;
                case AVPlayerStatusReadyToPlay:
                    {
                        [ATLogger logMessage:@"ATOfferVideoController: ready to play" type:ATLogTypeInternal];
                        [self.player setVolume:[AVAudioSession sharedInstance].outputVolume];
                    }
                    break;
                case AVPlayerStatusFailed:
                    {
                        [ATLogger logMessage:[NSString stringWithFormat:@"ATOfferVideoController: play failed with error:%@", self.playerItem.error] type:ATLogTypeInternal];
                        if (!self.isEndCard) {
                            if ([self.delegate respondsToSelector:@selector(offerVideoPlayFailWithOfferModel:extra:)]) {
                                [self.delegate offerVideoPlayFailWithOfferModel:self.offerModel extra:nil];
                            }
                        }
                    }
                    break;
                default:
                    break;
            }
        }
    }
}

//监听视频播放进度
-(void)timeObserver {
    CGFloat persentFlag25 = (1.0 / 4.0) * self.totalTime;
    CGFloat persentFlag50 = (1.0 / 2.0) * self.totalTime;
    CGFloat persentFlag75 = (3.0 / 4.0) * self.totalTime;
    CGFloat persentFlag100 = 1.0 * self.totalTime;
    __block BOOL isFlagStart = NO;
    __block BOOL isFlag25 = NO;
    __block BOOL isFlag50 = NO;
    __block BOOL isFlag75 = NO;
    __block BOOL isFlag100 = NO;
    __block BOOL isBannerShowFlag = NO;
    __block BOOL isCloseShowFlag = NO;
    if (_setting.bannerAppearanceInterval == 0) {
        if (self.offerModel.title != nil && [Utilities isEmpty:self.offerModel.title] == NO) {
            [self.view addSubview:self.bannerView];
        }
        isBannerShowFlag = YES;
    }else if (_setting.bannerAppearanceInterval < 0){
        isBannerShowFlag = YES;
    }
    if(_setting.closeButtonAppearanceInterval == -1){
        isCloseShowFlag = YES;
    }
    __weak typeof(self) weakself = self;
    _playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(50, 1000) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentime = (time.value * 1.00) / (time.timescale * 1.00) ;
        [weakself.progressview upDateCircleProgress:currentime];
        
        if ([weakself.delegate respondsToSelector:@selector(offerVideoPlayTime:offerModel:extra:)]) {
            [weakself.delegate offerVideoPlayTime:currentime offerModel:weakself.offerModel extra:nil];
        }
        if(currentime == 0 && isFlagStart == NO){
            isFlagStart = YES;
            if([weakself.delegate respondsToSelector:@selector(offerVideoStartPlayWithOfferModel:extra:)]){
                [weakself.delegate offerVideoStartPlayWithOfferModel:weakself.offerModel extra:nil];
            }
        }
        if (currentime >= persentFlag25 && isFlag25 == NO) {
            isFlag25 = YES;
            if ([weakself.delegate respondsToSelector:@selector(offerVideoPlay25PercentWithOfferModel:extra:)]) {
                [weakself.delegate offerVideoPlay25PercentWithOfferModel:weakself.offerModel extra:nil];
            }
        }else if(currentime >= persentFlag50 && isFlag50 == NO){
            isFlag50 = YES;
            if ([weakself.delegate respondsToSelector:@selector(offerVideoPlay50PercentWithOfferModel:extra:)]) {
                [weakself.delegate offerVideoPlay50PercentWithOfferModel:weakself.offerModel extra:nil];
            }
        }else if(currentime >= persentFlag75 && isFlag75 == NO){
            isFlag75 = YES;
            if ([weakself.delegate respondsToSelector:@selector(offerVideoPlay75PercentWithOfferModel:extra:)]) {
                [weakself.delegate offerVideoPlay75PercentWithOfferModel:weakself.offerModel extra:nil];
            }
        }else if(currentime >= persentFlag100 && isFlag100 == NO){
            isFlag100 = YES;
            if ([weakself.delegate respondsToSelector:@selector(offerVideoDidEndPlayWithOfferModel:extra:)]) {
                [weakself.delegate offerVideoDidEndPlayWithOfferModel:weakself.offerModel extra:nil];
            }
            [weakself endCard];
        }
        if (currentime >= weakself.setting.bannerAppearanceInterval && isBannerShowFlag == NO) {
            isBannerShowFlag = YES;
            [UIView transitionWithView:weakself.view duration:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [weakself.view addSubview:weakself.bannerView];
            } completion:nil];
        }
        if (currentime >= weakself.setting.closeButtonAppearanceInterval && isCloseShowFlag == NO) {
            isCloseShowFlag = YES;
            [weakself.view addSubview:weakself.closeBtn];
            if (weakself.offerModel.feedback) {
                return;
            }
            if (weakself.offerModel.offerModelType == ATOfferModelMyOffer ||
                weakself.offerModel.offerModelType == ATOfferModelADX ||
                weakself.offerModel.offerModelType == ATOfferModelOnlineApi ) {
                
                [weakself.view addSubview:weakself.feedbackBtn];
            }
        }
    }];
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
    if ([self.delegate respondsToSelector:@selector(offerVideoEndCardDidShowWithOfferModel:extra:)]) {
        [self.delegate offerVideoEndCardDidShowWithOfferModel:self.offerModel extra:nil];
    }
    self.isEndCard = YES;
    NSString * path = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:imageData];
    CGSize imgViewSize = [self getBoundsByImageSize:image.size];
    self.endCardImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imgViewSize.width, imgViewSize.height)];
    self.endCardImage.center = self.endCardBackView.center;
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
    if (self.offerModel.crtType != ATOfferCrtTypeOneImage && [Utilities isEmpty:self.offerModel.title] == NO) {
        [self.endCardBackView addSubview:self.bannerView];
    }
    
    if (self.setting.endCardClickable == ATEndCardClickableFullscreen) {
        UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureTap:)];
        gest.numberOfTapsRequired = 1;
        [_endCardBackView addGestureRecognizer:gest];
    }
    
    if (self.offerModel.interActableArea == ATOfferInterActableAreaCTA) {
        UIButton *ctaButton = [UIButton internal_autolayoutButtonWithType:UIButtonTypeCustom];
        UIEdgeInsets safeAreaInsets = [Utilities safeAreaInsets];
        ctaButton.frame = CGRectMake(CGRectGetWidth(self.endCardBackView.frame)/2 - 200/2, CGRectGetHeight(self.endCardBackView.frame) - 58 - 10 - safeAreaInsets.bottom, 222, 58);
        [ctaButton setTitle:self.offerModel.CTA forState:0];
        [ctaButton setBackgroundImage:[[UIImage anythink_imageWithName:@"native_splash_cta_btn_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(.0f, 35.0f, .0f, 35.0f) resizingMode:UIImageResizingModeStretch] forState:0];
        [self.endCardBackView addSubview:ctaButton];
        [ctaButton addTarget:self action:@selector(clickOfferBanner:event:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)addCloseAndFeedbackBtn {
    [self.endCardBackView addSubview:self.closeBtn];
    if (self.offerModel.feedback) {
        return;
    }
    if (self.offerModel.offerModelType == ATOfferModelMyOffer ||
        self.offerModel.offerModelType == ATOfferModelADX ||
        self.offerModel.offerModelType == ATOfferModelOnlineApi ) {
        [_endCardBackView addSubview:self.feedbackBtn];
    }
}
-(void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.player removeTimeObserver:_playerObserver];
    NSLog(@"ATOfferVideoViewController dealloc");
}

-(void)applicationWillResignActive:(NSNotification *)notification {
    [self.player pause];
    if (!self.isEndCard) {
        if ([self.delegate respondsToSelector:@selector(offerVideoDidVideoPausedWithOfferModel:extra:)]) {
            self.offerModel.videoCurrentTime = self.playerItem.currentTime.value/self.playerItem.currentTime.timescale;
            [self.delegate offerVideoDidVideoPausedWithOfferModel:self.offerModel extra:nil];
        }
    }
}

-(void)applicationWillBecomeActive:(NSNotification *)notification {
    [self.player play];
    self.offerModel.videoResumeTime += self.offerModel.videoCurrentTime;
    if (!self.isEndCard) {
        if ([self.delegate respondsToSelector:@selector(offerVideoResumedWithOfferModel:extra:)]) {
            [self.delegate offerVideoResumedWithOfferModel:self.offerModel extra:nil];
        }
    }
}

-(void)tapVideo:(UITapGestureRecognizer *)gesture {
    if (_setting.bannerAppearanceInterval == -1 && [ATOfferVideoBannerView bannerForView:self.view] == nil) {
        [self.view addSubview:self.bannerView];
    }
    CGPoint relativePoint = [gesture locationInView:self.view];
    CGPoint point = [gesture.view convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
    //click video
    if ([self.delegate respondsToSelector:@selector(offerVideoDidClickVideoWithOfferModel:extra:)]) {
        NSDictionary *dic = [self tapInfoWithPoint:point relativePoint:relativePoint];
        self.offerModel.tapInfoDict = dic;
        [self.delegate offerVideoDidClickVideoWithOfferModel:self.offerModel extra:dic];
    }
    //click video open url
    if (_setting.videoClickable == ATVideoClickableWithCTA) {
        if ([self.delegate respondsToSelector:@selector(offerVideoDidClickAdWithOfferModel:extra:)]) {
            NSDictionary *dic = [self tapInfoWithPoint:point relativePoint:point];
            self.offerModel.tapInfoDict = dic;
            [self.delegate offerVideoDidClickAdWithOfferModel:self.offerModel extra:dic];
        }
    }
}

- (NSDictionary *)tapInfoWithPoint:(CGPoint)point relativePoint:(CGPoint)relativePoint {
    
    NSInteger progress = (NSInteger)self.progressview.progress;
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
                          kATOfferTrackerVideoTimePlayed: @(progress),
                          kATOfferTrackerVideoMilliTimePlayed: @(progress * 1000)
    };
    return dic;
}

-(void)clickOfferCloseVideo:(UIButton *)btn event:(UIEvent *)event {
    self.offerModel.videoCurrentTime = self.playerItem.currentTime.value / self.playerItem.currentTime.timescale;
    
    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint relativePoint = [touch locationInView:self.view];
    CGPoint point = [btn convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
    NSDictionary *dic = [self tapInfoWithPoint:point relativePoint:relativePoint];
    self.offerModel.tapInfoDict = dic;
    
    if (self.isEndCard) {
        self.offerModel.feedback = NO;
        if ([self.delegate respondsToSelector:@selector(offerVideoEndCardDidCloseWithOfferModel:extra:)]) {
            [self.delegate offerVideoEndCardDidCloseWithOfferModel:self.offerModel extra:dic];
        }
        if ([self.delegate respondsToSelector:@selector(offerVideoDidCloseWithOfferModel:extra:)]) {
            [self.delegate offerVideoDidCloseWithOfferModel:self.offerModel extra:dic];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.player pause];
        self.player = nil;
        [self endCard];
        if ([self.delegate respondsToSelector:@selector(offerVideoSkipWithOfferModel:extra:)]) {
            [self.delegate offerVideoSkipWithOfferModel:self.offerModel extra:nil];
        }
    }
}

-(void)clickOfferVoiceBtn:(UIButton *)btn event:(UIEvent *)event {
    
    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint relativePoint = [touch locationInView:self.view];
    CGPoint point = [btn convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
    NSDictionary *dic = [self tapInfoWithPoint:point relativePoint:relativePoint];
    self.offerModel.tapInfoDict = dic;
    
    [self.player setMuted:!self.player.isMuted];
    if(self.player.isMuted){
        [_voiceBtn setImage:[UIImage anythink_imageWithName:@"offer_voice_muted"] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(offerVideoDidVideoMutedWithOfferModel:extra:)]) {
            [self.delegate offerVideoDidVideoMutedWithOfferModel:self.offerModel extra:dic];
        }
    }else{
        [_voiceBtn setImage:[UIImage anythink_imageWithName:@"offer_voice_unmuted"] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(offerVideoDidVideoUnMutedWithOfferModel:extra:)]) {
            [self.delegate offerVideoDidVideoUnMutedWithOfferModel:self.offerModel extra:dic];
        }
    }
}

-(void)clickOfferBanner:(UIButton *)btn event:(UIEvent *)event {
    self.offerModel.videoCurrentTime = self.playerItem.currentTime.value / self.playerItem.currentTime.timescale;

    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint relativePoint = [touch locationInView:self.view];
    CGPoint point = [btn convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
    NSDictionary *dic = [self tapInfoWithPoint:point relativePoint:relativePoint];
    self.offerModel.tapInfoDict = dic;
    
    if ([self.delegate respondsToSelector:@selector(offerVideoDidClickAdWithOfferModel:extra:)]) {
        [self.delegate offerVideoDidClickAdWithOfferModel:self.offerModel extra:dic];
    }
}

-(void)gestureTap:(UITapGestureRecognizer *)tap {
    self.offerModel.videoCurrentTime = self.playerItem.currentTime.value / self.playerItem.currentTime.timescale;
    
    CGPoint relativePoint = [tap locationInView:self.view];
    CGPoint point = [tap.view convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
    NSDictionary *dic = [self tapInfoWithPoint:point relativePoint:relativePoint];
    self.offerModel.tapInfoDict = dic;
    
    if ([self.delegate respondsToSelector:@selector(offerVideoDidClickAdWithOfferModel:extra:)]) {
        [self.delegate offerVideoDidClickAdWithOfferModel:self.offerModel extra:dic];
    }
}

- (void)feedback:(UIButton *)btn event:(UIEvent *)event {
    
    if (self.offerModel.feedback) {
        return;
    }
    ATOfferFeedBackView *feedback = [ATOfferFeedBackView create];
    feedback.delegate = self;
    [feedback showInView:self.view];
    [self.player pause];
}

//不可切换横竖屏
-(BOOL)shouldAutorotate {
    return NO;
}
//状态栏隐藏
-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - 懒加载
-(ATOfferProgressView *)progressview {
    if(!_progressview){
        _progressview = [[ATOfferProgressView alloc]initWithFrame:CGRectMake(20, [Utilities safeAreaInsets].top + 10, 30, 30)];
        self.progressview.alpha = 0.6;
        self.progressview.signProgress = self.totalTime;
    }
    return _progressview;
}

-(UIView *)endCardBackView {
    if (!_endCardBackView) {
        _endCardBackView = [[UIView alloc]initWithFrame:self.view.frame];
        _endCardBackView.backgroundColor = [UIColor blackColor];
    }
    return _endCardBackView;
}

-(UIButton *)closeBtn {
    if(!_closeBtn){
        _closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 55, CGRectGetMidY(self.progressview.frame) - 20, 40, 40)];
        _closeBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_closeBtn setImage:[UIImage anythink_imageWithName:@"offer_video_close"] forState:UIControlStateNormal];
//        _closeBtn.backgroundColor = [UIColor redColor];

        [_closeBtn addTarget:self action:@selector(clickOfferCloseVideo:event:) forControlEvents:UIControlEventTouchUpInside];
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
        _feedbackBtn.layer.cornerRadius = 5;
        _feedbackBtn.clipsToBounds = YES;
        [_feedbackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_feedbackBtn setBackgroundImage:[[[UIColor colorWithHexString:@"666666"] colorWithAlphaComponent:0.5] imageWithSize:_feedbackBtn.frame.size] forState:UIControlStateNormal];
        [_feedbackBtn setBackgroundImage:[[[UIColor colorWithHexString:@"333333"]colorWithAlphaComponent:0.5] imageWithSize:_feedbackBtn.frame.size] forState:UIControlStateHighlighted];
        [_feedbackBtn addTarget:self action:@selector(feedback:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _feedbackBtn;
}

-(UIButton *)voiceBtn {
    if(!_voiceBtn){
        _voiceBtn = [[UIButton alloc]initWithFrame:CGRectMake(70, [Utilities safeAreaInsets].top + 10, 30, 30)];
        if (_setting.unMute) {
            [_voiceBtn setImage:[UIImage anythink_imageWithName:@"offer_voice_unmuted"] forState:UIControlStateNormal];
        }else{
            [_voiceBtn setImage:[UIImage anythink_imageWithName:@"offer_voice_muted"] forState:UIControlStateNormal];
        }
        [_voiceBtn addTarget:self action:@selector(clickOfferVoiceBtn:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceBtn;
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
      
        _bannerView = [[ATOfferVideoBannerView alloc]initWithFrame:CGRectMake(x, videoHeight - [Utilities safeAreaInsets].bottom - height - 8, width, height) offerModel:_offerModel];
        NSString * path = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL];
        [_bannerView.iconImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:path]]];
        _bannerView.title.text = self.offerModel.title;
        [_bannerView.desc setText:self.offerModel.text];
        
        if ([Utilities isEmpty:self.offerModel.CTA] == NO) {
            [_bannerView.ctaButton setTitle:self.offerModel.CTA forState:UIControlStateNormal];
            [_bannerView.ctaButton addTarget:self action:@selector(clickOfferBanner:event:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        NSString * logoPath = [[ATOfferResourceManager sharedManager]resourcePathForOfferModel:self.offerModel resourceURL:self.offerModel.logoURL];
        if(logoPath != nil){
            NSData *imageData = [NSData dataWithContentsOfFile:logoPath];
            [_bannerView.logoImage setImage:[UIImage imageWithData:imageData]];
        }
        if (_setting.endCardClickable != ATEndCardClickableCTA) {
            UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureTap:)];
            gest.numberOfTapsRequired = 1;
            [_bannerView addGestureRecognizer:gest];
        }
    }
    return _bannerView;
}

// MARK:- feedback view delegate
- (void)feedbackView:(ATOfferFeedBackView *)feedback didSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg {
    
    if ([self.delegate respondsToSelector:@selector(offerVideoFeedbackViewDidSelectItemAtIndex:extraMsg:offerModel:)]) { 
        [self.delegate offerVideoFeedbackViewDidSelectItemAtIndex:index extraMsg:msg offerModel:self.offerModel];
    }
    self.feedbackBtn.hidden = YES;
}

- (void)feedbackViewWillDismiss:(ATOfferFeedBackView *)feedback {
    [self.player play];
}
@end
