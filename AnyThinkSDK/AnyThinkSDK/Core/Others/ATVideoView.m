//
//  ATVideoView.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATVideoView.h"
#import "Utilities.h"
@import AVFoundation;

@interface ATVideoView()
@property(nonatomic, readonly) UILabel *countdownLabel;
@property(nonatomic, readonly) UIView *countdownLabelBgView;
@property(nonatomic, readonly) UIButton *muteButton;
@property(nonatomic, readonly) UIButton *playButton;
@property(nonatomic, readonly) AVPlayer *player;
@property(nonatomic) CMTime leftOfTime;
@property(nonatomic) BOOL paused;
@property(nonatomic) NSInteger leftOfCountDown;
@end

@implementation ATVideoView
+(Class)layerClass {
    return [AVPlayerLayer class];
}

-(instancetype) initWithFrame:(CGRect)frame URL:(NSURL*)URL {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.URL = URL;
        [self initSubviews];
        [self makeConstraintsForSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

static CGFloat buttonWidth = 29.0f;
-(void) initSubviews {
    _countdownLabelBgView = [[UIView alloc] initWithFrame:CGRectZero];
    _countdownLabelBgView.translatesAutoresizingMaskIntoConstraints = NO;
    _countdownLabelBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4f];
    [self addSubview:_countdownLabelBgView];
    
    _countdownLabel = [[UILabel alloc] init];
    _countdownLabel.textAlignment = NSTextAlignmentCenter;
    _countdownLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _countdownLabel.font = [UIFont systemFontOfSize:12.0f];
    _countdownLabel.textColor = [UIColor whiteColor];
    [_countdownLabelBgView addSubview:_countdownLabel];
    
    _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _muteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_muteButton addTarget:self action:@selector(muteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    _muteButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4f];
    [_muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_muteButton setImage:[UIImage anythink_imageWithName:@"video_player_demute"] forState:UIControlStateNormal];
    _muteButton.imageEdgeInsets = UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f);
    _muteButton.layer.cornerRadius = buttonWidth / 2.0f;
    [self addSubview:_muteButton];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_playButton addTarget:self action:@selector(playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_playButton setImage:[UIImage anythink_imageWithName:@"video_player_play"] forState:UIControlStateNormal];
    [self addSubview:_playButton];
}

-(void) makeConstraintsForSubviews {
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-2-[_countdownLabel(16)]-2-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_countdownLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_countdownLabel(16)]-2-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_countdownLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_countdownLabelBgView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_countdownLabelBgView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_countdownLabelBgView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_countdownLabelBgView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_muteButton(width)]-|" options:0 metrics:@{@"width":@(buttonWidth)} views:NSDictionaryOfVariableBindings(_muteButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_muteButton(width)]" options:0 metrics:@{@"width":@(buttonWidth)} views:NSDictionaryOfVariableBindings(_muteButton)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_playButton attribute:NSLayoutAttributeWidth multiplier:1.0f constant:.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f]];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appWillResignActive:(NSNotification *)notification {
    _paused = YES;
    if (self.player) {
        [self.player pause];
        self.leftOfTime = _player.currentTime;
        _leftOfCountDown = [_countdownLabel.text integerValue];
    }
}

-(void) appBecomeActive:(NSNotification *)notification {
    if (CMTIME_IS_VALID(self.leftOfTime)) {
        _paused = NO;
        [self.player seekToTime:self.leftOfTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                [self.player play];
                [self configureCountWithDuration:_leftOfCountDown];
            }
        }];
    }
}

-(void) willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow == nil) {
        [_player pause];
        ((AVPlayerLayer*)self.layer).player = nil;
    }
}

-(void) playButtonTapped {
    _playButton.hidden = YES;
    [self play];
}

-(void) muteButtonTapped {
    _player.muted = !_player.isMuted;
    [_muteButton setImage:[UIImage anythink_imageWithName:_player.muted ? @"video_player_mute" : @"video_player_demute"] forState:UIControlStateNormal];
}

-(void) setAutoPlay:(BOOL)autoPlay {
    _autoPlay = autoPlay;
    _countdownLabelBgView.hidden = !(_playButton.hidden = _autoPlay);
}

-(double) progress {
    return (double)(_player.currentTime.value / _player.currentTime.timescale) / (double)(_player.currentItem.asset.duration.value / _player.currentItem.asset.duration.timescale);
}

-(void) configureCountWithDuration:(NSInteger) duration {
    if (!_paused) {
        _countdownLabelBgView.hidden = NO;
        _countdownLabel.text = [NSString stringWithFormat:@"%ld", duration > 0 ? duration : 0];
        if (duration > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self configureCountWithDuration:duration - 1];
            });
        } else {
            if ([_delegate respondsToSelector:@selector(videoDidFinishPlayingInVideoView:)]) {
                [_delegate videoDidFinishPlayingInVideoView:self];
            }
        }
    }
}



-(void) setURL:(NSURL *)URL {
    _URL = URL;
    if (_URL != nil) {
        AVAsset *asset = [AVAsset assetWithURL:URL];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        _player = [AVPlayer playerWithPlayerItem:item];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        ((AVPlayerLayer*)self.layer).player = _player;
        if (_autoPlay) [self play];
    }
    _muteButton.hidden = _countdownLabelBgView.hidden = _URL == nil;
}

-(void) play {
    if ([_delegate respondsToSelector:@selector(videoDidPlayInVideoView:)]) {
        [_delegate videoDidPlayInVideoView:self];
    }
    [_player play];
    AVAsset *asset = [AVAsset assetWithURL:_URL];
    [self configureCountWithDuration:(NSInteger)(asset.duration.value / asset.duration.timescale)];
}
@end
