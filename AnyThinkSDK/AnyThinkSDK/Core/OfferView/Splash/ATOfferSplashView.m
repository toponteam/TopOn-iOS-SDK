//
//  ATOfferSplashView.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOfferSplashView.h"
#import "UIView+AutoLayout.h"
#import "Utilities.h"
#import "UIScreen+SafeArea.h"
#import "ATOfferSplashStarRatingView.h"
#import "NSString+KAKit.h"
#import "ATAPI+Internal.h"

@interface ATOfferSplashView ()

@property(nonatomic) BOOL isPortrait;
@property(nonatomic, readonly) ATOfferSplashStarRatingView *starView;
@property(nonatomic, readonly) ATOfferModel *offerModel;

@end

@implementation ATOfferSplashView

- (instancetype) initWithFrame:(CGRect)frame containerView:(UIView *)containerView offerModel:(ATOfferModel*)offerModel isPortrait:(BOOL)portrait {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _containerView = containerView;
        _isPortrait = portrait;
        
        _offerModel = offerModel;
        [self initSubviews];
        [self makeConstraintsForSubviews];
    }
    return self;
}

- (void)setStarts:(CGFloat)starts {
    [self.starView configureStar:starts];
}

- (NSArray<UIView*> *) clickableViews {

    if (self.offerModel.interActableArea == ATOfferInterActableAreaCTA) {
        return @[_ctaLabel,_ctaBackgroundImageView];
    }

    NSMutableArray <UIView*>* clickableViews = [NSMutableArray<UIView*> array];
    if (self.ctaLabel) { [clickableViews addObject:self.ctaLabel]; }
    if (self.mainImageView) { [clickableViews addObject:self.mainImageView]; }
    if (self.textLabel) { [clickableViews addObject:self.textLabel]; }
    if (self.titleLabel ) { [clickableViews addObject:self.titleLabel]; }
    if (self.iconImageView) {
        [clickableViews addObject:self.iconImageView];
    }
    if (self.offerModel.interActableArea == ATOfferInterActableAreaAll && self.blurView) {
        [clickableViews addObject:self.blurView];
    }
    
    if (self.ctaBackgroundImageView ) { [clickableViews addObject:self.ctaBackgroundImageView]; }
    if (self.starView != nil) { [clickableViews addObject:self.starView]; }
    return clickableViews;
}

// MARK:- private methods
- (void)initSubviews {
    _backgroundImageView = [UIImageView internal_autolayoutView];
    
    self.backgroundColor = [UIColor clearColor];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _blurView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _textLabel = [UILabel internal_autolayoutLabelFont:[UIFont boldSystemFontOfSize:17.0f] textColor:[UIColor whiteColor]];
    _textLabel.numberOfLines = 2;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    
    _mainImageView = [UIImageView internal_autolayoutView];
    _mainImageView.backgroundColor = [UIColor clearColor];
    _mainImageView.layer.cornerRadius = 4.0f;
    _mainImageView.layer.masksToBounds = YES;
    _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _iconImageView = [UIImageView internal_autolayoutView];
    _iconImageView.backgroundColor = [UIColor clearColor];
    _iconImageView.layer.cornerRadius = 4.0f;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _skipButton = [UIButton internal_autolayoutButtonWithType:UIButtonTypeCustom];
    [_skipButton setTitleColor:[UIColor colorWithRed:233.0f / 255.0f green:233.0f / 255.0f blue:233.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    _skipButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _skipButton.backgroundColor = _isPortrait ? [[UIColor whiteColor] colorWithAlphaComponent:.3f] : [[UIColor grayColor] colorWithAlphaComponent:.6f];
    _skipButton.layer.cornerRadius = 14.0f;
    
    _sponsorImageView = [UIImageView internal_autolayoutView];
    
    _starView = [ATOfferSplashStarRatingView internal_autolayoutView];
    
    _titleLabel = [UILabel internal_autolayoutLabelFont:[UIFont boldSystemFontOfSize:_isPortrait ? 23.0f : 16.0f] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _ctaBackgroundImageView = [UIImageView internal_autolayoutView];
    _ctaBackgroundImageView.image = [[UIImage anythink_imageWithName:@"native_splash_cta_btn_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(.0f, 35.0f, .0f, 35.0f) resizingMode:UIImageResizingModeStretch];
    
    _ctaLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:_isPortrait ? 23.0f : 15.0f] textColor:[UIColor whiteColor]];
    _ctaLabel.text = @"more";
    _ctaLabel.textAlignment = NSTextAlignmentCenter;
    
    if (_offerModel.crtType == ATOfferCrtTypeOneImage) {
        [self addSubview:_mainImageView];
        [self addSubview:_skipButton];
        [self addSubview:_sponsorImageView];
        [self addSubview:_ctaBackgroundImageView];
        [_ctaBackgroundImageView addSubview:_ctaLabel];
    } else {
        [self addSubview:_backgroundImageView];
        [self addSubview:_blurView];
        [self addSubview:_textLabel];
        [self addSubview:_mainImageView];
        [self addSubview:_sponsorImageView];
        [self addSubview:_iconImageView];
        
        if(_isPortrait) {
            //Portrait
            [self addSubview:_starView];
            [self addSubview:_titleLabel];
            [self addSubview:_ctaBackgroundImageView];
            [self addSubview:_ctaLabel];
        }else{
            //landscape
            CGFloat radius = 4.0f;
            CGFloat trailing = _containerView != nil?CGRectGetHeight(_containerView.frame):0.0f;
            _bottomImageView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, 0, 0)];
            _bottomImageView.layer.cornerRadius = radius;
            _bottomImageView.layer.masksToBounds = YES;
            _bottomImageView.translatesAutoresizingMaskIntoConstraints = NO;
            [_bottomImageView addSubview:_starView];
            [_bottomImageView addSubview:_titleLabel];
            [_bottomImageView addSubview:_ctaBackgroundImageView];
            [_bottomImageView addSubview:_ctaLabel];
            
            [self addSubview:_bottomImageView];
        }
        
        [self addSubview:_skipButton];
    }
    
    CGFloat left = [UIScreen safeAreaInsets].left;
    CGFloat top = [UIScreen safeAreaInsets].top <= 0 ? CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) : [UIScreen safeAreaInsets].top;
    CGFloat width = _isPortrait ? 40.0f : 58.0f;
    CGFloat height = _isPortrait ? 22.0f : 20.0f;
    CGFloat radius = 4.0f;
    
    _adNoteLabel = [[UILabel alloc] initWithFrame:_isPortrait ? CGRectMake(left + 5.0f, 5.0f + (top > 20.0f ? .0f : top), width, height): CGRectMake(left + 5.0f, 5.0f + top, width, height)];
    _adNoteLabel.textColor = [UIColor whiteColor];
    _adNoteLabel.textAlignment = NSTextAlignmentCenter;
    _adNoteLabel.font = [UIFont systemFontOfSize:14.0f];
    _adNoteLabel.backgroundColor = _isPortrait ? [[UIColor whiteColor] colorWithAlphaComponent:.3f] : [[UIColor grayColor] colorWithAlphaComponent:.6f];
    _adNoteLabel.layer.cornerRadius = radius;
    _adNoteLabel.layer.masksToBounds = YES;
    _adNoteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _adNoteLabel.text = @"AD";
    _adNoteLabel.hidden = [ATAPI adLogoVisible];
    [self addSubview:_adNoteLabel];
    
    if(_containerView != nil){
        _containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_containerView];
    }
}

-(void) makeConstraintsForSubviews {
    UIEdgeInsets safeAreaInsets = [UIScreen safeAreaInsets];
    CGFloat top = safeAreaInsets.top <= 0 ? CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) : safeAreaInsets.top;
    CGFloat bottom = safeAreaInsets.bottom;
    CGFloat left = safeAreaInsets.left;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    if (_offerModel.crtType == ATOfferCrtTypeOneImage) {
        if (_isPortrait) {
            NSDictionary *viewsDict = _containerView ? NSDictionaryOfVariableBindings(_skipButton, _mainImageView, _containerView, _adNoteLabel,_sponsorImageView) : NSDictionaryOfVariableBindings(_skipButton, _mainImageView, _adNoteLabel,_sponsorImageView);
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_adNoteLabel(20)]" options:0 metrics:@{@"top":@(top>20.0f?(top + 5.0f):20.0f)} views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-left-[_adNoteLabel(40)]" options:0 metrics:@{@"left":@(-left)} views:viewsDict];
            
            CGFloat containerHeight = self.containerView.frame.size.height;
            if(_containerView != nil){
                [self internal_addConstraintsWithVisualFormat:@"H:|-0-[_containerView]-0-|" options:0 metrics:nil views:viewsDict];
                [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_containerView]-0-|" options:0 metrics:@{@"top":@(height- containerHeight)} views:viewsDict];
            }
            
            _skipButtonWidthConstraint = [self internal_addConstraintsWithVisualFormat:@"[_skipButton(90)]-10-|" options:0 metrics:nil views:viewsDict][0];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_skipButton(28)]" options:0 metrics:@{@"top":@(20 + (top > 20.0f ? top : 0.0f))} views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:|-0-[_mainImageView]-0-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-0-[_mainImageView]-0-|" options:0 metrics:nil views:viewsDict];
            [_mainImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
            [self internal_addConstraintsWithVisualFormat:@"[_sponsorImageView]|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:[_sponsorImageView]|" options:0 metrics:nil views:viewsDict];
           
        }else {
            NSDictionary *viewsDict = _containerView ? NSDictionaryOfVariableBindings(_skipButton, _mainImageView, _containerView, _adNoteLabel,_sponsorImageView) : NSDictionaryOfVariableBindings(_skipButton, _mainImageView, _adNoteLabel,_sponsorImageView);
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_adNoteLabel]" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-top-[_adNoteLabel]" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
            
            CGFloat trailing = self.containerView.frame.size.width;
            trailing = MIN(200, trailing);
            if(_containerView != nil){
                [self internal_addConstraintsWithVisualFormat:@"H:|-left-[_containerView]-0-|" options:0 metrics:@{@"left":@(width - trailing)} views:viewsDict];
                [self internal_addConstraintsWithVisualFormat:@"V:|-0-[_containerView]-0-|" options:0 metrics:nil views:viewsDict];
            }
            
            [self internal_addConstraintsWithVisualFormat:@"H:[_skipButton(90)]-right-|" options:0 metrics:@{@"right":@(10 + trailing)} views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_skipButton(28)]" options:0 metrics:@{@"top":@(10 + (top > 20.0f ? .0f : top))} views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:|-0-[_mainImageView]-0-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-0-[_mainImageView]-0-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"[_sponsorImageView]|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:[_sponsorImageView]|" options:0 metrics:nil views:viewsDict];
        }
        
        // cta
        [self addCTA];
    }else {
        if (_isPortrait) {
            
            NSDictionary *viewsDict = _containerView ? NSDictionaryOfVariableBindings(_iconImageView, _blurView, _skipButton, _starView, _titleLabel, _mainImageView, _textLabel, _ctaLabel, _ctaBackgroundImageView, _sponsorImageView, _containerView, _adNoteLabel) : NSDictionaryOfVariableBindings(_iconImageView, _blurView, _skipButton, _starView, _titleLabel, _mainImageView, _textLabel, _ctaLabel, _ctaBackgroundImageView, _sponsorImageView, _adNoteLabel);
            
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_adNoteLabel(20)]" options:0 metrics:@{@"top":@(top>20.0f?(top + 5.0f):20.0f)} views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-left-[_adNoteLabel(40)]" options:0 metrics:@{@"left":@(-left + 10)} views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"|[_blurView]|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_blurView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"|[_backgroundImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundImageView)];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_backgroundImageView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:NSDictionaryOfVariableBindings(_backgroundImageView)];
            
            CGFloat containerHeight = self.containerView.frame.size.height;
            
            if(_containerView != nil){
                [self internal_addConstraintsWithVisualFormat:@"H:|-0-[_containerView]-0-|" options:0 metrics:nil views:viewsDict];
                [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_containerView]-0-|" options:0 metrics:@{@"top":@(height- containerHeight)} views:viewsDict];
            }
            
            _skipButtonWidthConstraint = [self internal_addConstraintsWithVisualFormat:@"[_skipButton(90)]-10-|" options:0 metrics:nil views:viewsDict][0];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_skipButton(28)]" options:0 metrics:@{@"top":@(20 + (top > 20.0f ? top : 0.0f))} views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:[_sponsorImageView]-5-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:[_sponsorImageView]-containerHeight-|" options:0 metrics:@{@"containerHeight":@(containerHeight + 5.0f)} views:viewsDict];
            
            [self internal_addConstraintWithItem:_iconImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_mainImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_iconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:_offerModel.iconURL.length ? 110 : 0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_iconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0]];

            
            [self internal_addConstraintsWithVisualFormat:@"|-10-[_mainImageView]-10-|" options:0 metrics:nil views:viewsDict];
//            [self internal_addConstraintsWithVisualFormat:@"|-33-[_titleLabel]-33-|" options:0 metrics:nil views:viewsDict];
//            [self internal_addConstraintsWithVisualFormat:@"|-20-[_textLabel]-20-|" options:0 metrics:nil views:viewsDict];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:33]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-33]];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:20]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-20]];
            
            [self internal_addConstraintsWithVisualFormat:@"V:|-48-[_iconImageView]-12-[_titleLabel]-12-[_starView]-10-[_mainImageView]-10-[_textLabel(55)]-10-[_ctaLabel(50)]->=bottom-|" options:NSLayoutFormatAlignAllCenterX metrics:@{@"bottom":@(bottom + containerHeight + 10.0f)} views:viewsDict];
            if ([Utilities isEmpty:self.offerModel.CTA] == false) {
                [_ctaLabel internal_addConstraintsWithVisualFormat:@"[_ctaLabel(200)]" options:0 metrics:nil views:viewsDict];
                [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_ctaLabel attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
                [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_ctaLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
                [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:222.0f];
                [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:58.f];
            }else {
                [_ctaLabel setHidden:YES];
            }
            [_mainImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
            
            
        } else {
            NSDictionary *viewsDict = _containerView ? NSDictionaryOfVariableBindings(_iconImageView, _blurView, _skipButton, _starView, _titleLabel, _mainImageView, _textLabel, _ctaLabel, _ctaBackgroundImageView, _sponsorImageView, _containerView, _bottomImageView, _adNoteLabel) : NSDictionaryOfVariableBindings(_iconImageView, _blurView, _skipButton, _starView, _titleLabel, _mainImageView, _textLabel, _ctaLabel, _ctaBackgroundImageView, _sponsorImageView, _bottomImageView, _adNoteLabel);
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_adNoteLabel]" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-top-[_adNoteLabel]" options:0 metrics:@{@"top":@(-top + 10), @"bottom":@(-bottom)} views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"|[_blurView]|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_blurView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"|[_backgroundImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundImageView)];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_backgroundImageView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:NSDictionaryOfVariableBindings(_backgroundImageView)];
            CGFloat trailing = self.containerView.frame.size.width;
            trailing = MIN(200, trailing);
            
            if(_containerView != nil){
                [self internal_addConstraintsWithVisualFormat:@"H:|-left-[_containerView]-0-|" options:0 metrics:@{@"left":@(width - trailing)} views:viewsDict];
                [self internal_addConstraintsWithVisualFormat:@"V:|-0-[_containerView]-0-|" options:0 metrics:nil views:viewsDict];
            }
            
            [self internal_addConstraintsWithVisualFormat:@"H:[_skipButton(90)]-right-|" options:0 metrics:@{@"right":@(10 + trailing)} views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_skipButton(28)]" options:0 metrics:@{@"top":@(10 + (top > 20.0f ? .0f : top))} views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"V:[_sponsorImageView]-5-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:[_sponsorImageView]-trailing-|" options:0 metrics:@{@"trailing":@(trailing + 5.0f)} views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:|-leading-[_mainImageView]-trailing-|" options:0 metrics:@{@"leading":@(left+40.0f), @"trailing":@(trailing + 40.0f + 250)} views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_mainImageView]-bottom-|" options:0 metrics:@{@"top":@(top>20.0f?(top+40.0f):60.0f),@"bottom":@(top>20.0f?(top+40.0f):60.0f)} views:viewsDict];

//            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_bottomImageView]-bottom-|" options:0 metrics:@{@"top":@(top + 90), @"bottom": @(bottom + 90)} views:viewsDict];
            //        [self internal_addConstraintsWithVisualFormat:@"[_iconImageView]-10-[_titleLabel]" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:[_mainImageView]-10-[_bottomImageView]-right-|" options:0 metrics:@{@"right":@(trailing + 10)} views:viewsDict];
            self.textLabel.hidden = YES;
            
            // icon view
            [self internal_addConstraintWithItem:_iconImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bottomImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
            [self internal_addConstraintWithItem:_iconImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomImageView attribute:NSLayoutAttributeTop multiplier:1.0f constant:10];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_iconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:_offerModel.iconURL.length ? 92 : 0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_iconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0]];
            
            // title label
            [self internal_addConstraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_iconImageView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
            [self internal_addConstraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_iconImageView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10];

            // start view
            [self internal_addConstraintWithItem:_starView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10];
            [self internal_addConstraintWithItem:_starView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];

//            [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            
            if ([Utilities isEmpty:self.offerModel.CTA]) {
                _ctaLabel.hidden = YES;
                [self internal_addConstraintWithItem:_starView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomImageView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-10];
                [self internal_addConstraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_mainImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];


            }else {
                _ctaLabel.hidden = NO;
                
                [self internal_addConstraintsWithVisualFormat:@"[_ctaBackgroundImageView(160)]" options:0 metrics:nil views:viewsDict];
                [self internal_addConstraintsWithVisualFormat:@"V:[_ctaBackgroundImageView(71)]" options:0 metrics:nil views:viewsDict];
                // cta backgroud image view
                [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_starView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
                [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_starView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10];
                
                // cta label
                [self internal_addConstraintWithItem:_ctaLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
                [self internal_addConstraintWithItem:_ctaLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];

                [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:_bottomImageView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-10];
                
                [self internal_addConstraintWithItem:_bottomImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_mainImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];


            }
            
        }
    }
}

- (void)addCTA {
    
    UIEdgeInsets safeAreaInsets = [Utilities safeAreaInsets];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-10-safeAreaInsets.bottom];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:222];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:58];
    [self addConstraints:@[centerX,bottom,width,height]];
    
    NSLayoutConstraint *centerX_ctaLabel = [NSLayoutConstraint constraintWithItem:_ctaLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerY_ctaLabel = [NSLayoutConstraint constraintWithItem:_ctaLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *width_ctaLabel = [NSLayoutConstraint constraintWithItem:_ctaLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200];
    NSLayoutConstraint *height_ctaLabel = [NSLayoutConstraint constraintWithItem:_ctaLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50];
    [_ctaBackgroundImageView addConstraints:@[centerX_ctaLabel,centerY_ctaLabel,width_ctaLabel,height_ctaLabel]];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
