//
//  ATMyofferSplashSharedDelegate.m
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferSplashSharedDelegate.h"
#import "UIViewController+PresentationAndDismissalSwizzling.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATMyOfferOfferManager.h"
#import "ATMyOfferTracker.h"
#import "ATMyOfferCapsManager.h"
#import "ATPlacementSettingManager.h"
#import "ATMyOfferResourceManager.h"
#import "ATMyOfferSplashSharedDelegate.h"

NSString *const kATMyOfferSplashShowingExtraCTAButtonBackgroundColorKey = @"cta_button_bg_color";
NSString *const kATMyOfferSplashShowingExtraCTAButtonTitleColorKey = @"cta_btn_title_color";
NSString *const kATMyOfferSplashShowingExtraContainerViewKey = @"container_view";
NSString *const kATMyOfferSplashShowingExtraCountdownIntervalKey = @"countdown_interval";
NSString *const kATMyOfferSplashShowingExtraStyleKey = @"layout_style";

NSString *const kATMyOfferSplashShowingExtraStylePortrait = @"layout_style_protrait";
NSString *const kATMyOfferSplashShowingExtraStyleLandscape = @"layout_style_landscape";


@interface ATMyOfferSplashSharedDelegate()

+(BOOL) layoutStylePortrait;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, id<ATMyOfferSplashDelegate>> *delegates;
@property(nonatomic, readonly) ATThreadSafeAccessor *delegateStorageAccessor;

@property(nonatomic, readonly) dispatch_queue_t delegates_accessing_queue;
@property(nonatomic) NSMutableDictionary *splashExtra;

@property (nonatomic , strong)ATMyOfferOfferModel *offerModel;
@property (nonatomic) ATMyOfferSetting *setting;

@end


#pragma mark - UIScreen category
@interface UIScreen(SafeArea)
@end
@implementation UIScreen (SafeArea)

+(UIEdgeInsets)safeAreaInsets {
    return ([[UIApplication sharedApplication].keyWindow respondsToSelector:@selector(safeAreaInsets)] ? [UIApplication sharedApplication].keyWindow.safeAreaInsets : UIEdgeInsetsZero);
}

@end



#pragma mark - rating view
@interface ATMyOfferSplashStarRatingView:UIView
@property(nonatomic, readonly) UIImageView *star0;
@property(nonatomic, readonly) UIImageView *star1;
@property(nonatomic, readonly) UIImageView *star2;
@property(nonatomic, readonly) UIImageView *star3;
@property(nonatomic, readonly) UIImageView *star4;
@end
@implementation ATMyOfferSplashStarRatingView
-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initSubviews];
        [self makeConstraintsForSubviews];
    }
    return self;
}

-(void) initSubviews {
    _star0 = [UIImageView internal_autolayoutView];
    [self addSubview:_star0];
    
    _star1 = [UIImageView internal_autolayoutView];
    [self addSubview:_star1];
    
    _star2 = [UIImageView internal_autolayoutView];
    [self addSubview:_star2];
    
    _star3 = [UIImageView internal_autolayoutView];
    [self addSubview:_star3];
    
    _star4 = [UIImageView internal_autolayoutView];
    [self addSubview:_star4];
}

-(void) makeConstraintsForSubviews {
    [self internal_addConstraintsWithVisualFormat:@"|[_star0(18)]-10-[_star1(18)]-10-[_star2(18)]-10-[_star3(18)]-10-[_star4(18)]" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:0 views:NSDictionaryOfVariableBindings(_star0, _star1, _star2, _star3, _star4)];
    [self internal_addConstraintsWithVisualFormat:@"V:|[_star0(18)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_star0, _star1, _star2, _star3, _star4)];
}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(18.0f * 5.0f + 10.0f * 4.0f, 18.0f);
}

+(void) configureStarView:(ATMyOfferSplashStarRatingView*)starView star:(CGFloat)star {
    NSArray<UIImageView*>* stars = @[starView.star0, starView.star1, starView.star2, starView.star3, starView.star4];
    NSInteger consumedStar = 0;
    CGFloat remainStar = star;
    while (consumedStar < 5) {
        stars[consumedStar++].image = [UIImage anythink_imageWithName:remainStar >= 1.0f ? @"native_splash_star_on" : remainStar > .0f ? @"native_splash_semi_star" : @"native_splash_star_off"];
        remainStar -= remainStar > 1.0f ? 1.0f : remainStar > .0f ? remainStar : .0f;
    }
}
@end


#pragma mark - splash view
@interface ATMyOfferSplashView:UIView
@property(nonatomic, readonly) UIVisualEffectView *blurView;
@property(nonatomic, readonly) UIButton *skipButton;
@property(nonatomic, readonly) NSLayoutConstraint *skipButtonWidthConstraint;

@property(nonatomic, readonly) ATMyOfferSplashStarRatingView *starView;
@property(nonatomic, readonly) UILabel *textLabel;
@property(nonatomic, readonly) UILabel *titleLabel;
@property(nonatomic, readonly) UILabel *ctaLabel;
@property(nonatomic, readonly) UIImageView *mainImageView;
@property(nonatomic, readonly) UIImageView *sponsorImageView;
@property(nonatomic, readonly) UIImageView *backgroundImageView;
@property(nonatomic, readonly) UIImageView *ctaBackgroundImageView;
@property(nonatomic, readonly) UIView *bottomImageView;
@property(nonatomic, readonly) UILabel *adNoteLabel;

@property(nonatomic, readonly) UIView *containerView;


@end

static NSString *const kSkipTextFormatString = @"%lds%@";
@implementation ATMyOfferSplashView

-(instancetype) initWithFrame:(CGRect)frame  containerView:(UIView *)containerView{
    self = [super initWithFrame:frame];
    if (self != nil) {
        _containerView = containerView;
        [self initSubviews];
        [self makeConstraintsForSubviews];
    }
    return self;
}


-(void) initSubviews {
    //    [super initSubviews];
    
    _backgroundImageView = [UIImageView internal_autolayoutView];
    [self addSubview:_backgroundImageView];
    
    self.backgroundColor = [UIColor clearColor];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_blurView];
    
    _textLabel = [UILabel internal_autolayoutLabelFont:[UIFont boldSystemFontOfSize:17.0f] textColor:[UIColor whiteColor]];
    _textLabel.numberOfLines = 2;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
    
    _mainImageView = [UIImageView internal_autolayoutView];
    _mainImageView.backgroundColor = [UIColor clearColor];
    _mainImageView.layer.cornerRadius = 4.0f;
    _mainImageView.layer.masksToBounds = YES;
    _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_mainImageView];
    
    
    
    _skipButton = [UIButton internal_autolayoutButtonWithType:UIButtonTypeCustom];
    [_skipButton setTitleColor:[UIColor colorWithRed:233.0f / 255.0f green:233.0f / 255.0f blue:233.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    _skipButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _skipButton.backgroundColor = [ATMyOfferSplashSharedDelegate layoutStylePortrait] ? [[UIColor whiteColor] colorWithAlphaComponent:.3f] : [[UIColor grayColor] colorWithAlphaComponent:.6f];
    _skipButton.layer.cornerRadius = 14.0f;
    [self addSubview:_skipButton];
    
    _sponsorImageView = [UIImageView internal_autolayoutView];
    [self addSubview:_sponsorImageView];
    
    _starView = [ATMyOfferSplashStarRatingView internal_autolayoutView];
    
    _titleLabel = [UILabel internal_autolayoutLabelFont:[UIFont boldSystemFontOfSize:[ATMyOfferSplashSharedDelegate layoutStylePortrait] ? 23.0f : 16.0f] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    
    _ctaBackgroundImageView = [UIImageView internal_autolayoutView];
    _ctaBackgroundImageView.image = [[UIImage anythink_imageWithName:@"native_splash_cta_btn_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(.0f, 35.0f, .0f, 35.0f) resizingMode:UIImageResizingModeStretch];
    
    
    _ctaLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:[ATMyOfferSplashSharedDelegate layoutStylePortrait] ? 23.0f : 15.0f] textColor:[UIColor whiteColor]];
    _ctaLabel.text = @"more";
    _ctaLabel.textAlignment = NSTextAlignmentCenter;
    
    
    if([ATMyOfferSplashSharedDelegate layoutStylePortrait]) {
        //Portrait
        [self addSubview:_starView];
        [self addSubview:_titleLabel];
        [self addSubview:_ctaBackgroundImageView];
        [self addSubview:_ctaLabel];
    }else{
        //landscape
        CGFloat radius = 4.0f;
        CGFloat trailing = _containerView != nil?CGRectGetHeight(_containerView.frame):0.0f;
        _bottomImageView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth([UIScreen mainScreen].bounds) - trailing + 10, 90.0f)];
        _bottomImageView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.6f];
        _bottomImageView.layer.cornerRadius = radius;
        _bottomImageView.layer.masksToBounds = YES;
        _bottomImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomImageView addSubview:_starView];
        [_bottomImageView addSubview:_titleLabel];
        [_bottomImageView addSubview:_ctaBackgroundImageView];
        [_bottomImageView addSubview:_ctaLabel];
        
        [self addSubview:_bottomImageView];
    }
    
    CGFloat left = [UIScreen safeAreaInsets].left;
    CGFloat top = [UIScreen safeAreaInsets].top <= 0 ? CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) : [UIScreen safeAreaInsets].top;
    CGFloat width = [ATMyOfferSplashSharedDelegate layoutStylePortrait] ? 40.0f : 58.0f;
    CGFloat height = [ATMyOfferSplashSharedDelegate layoutStylePortrait] ? 22.0f : 20.0f;
    CGFloat radius = 4.0f;
    
    _adNoteLabel = [[UILabel alloc] initWithFrame:[ATMyOfferSplashSharedDelegate layoutStylePortrait] ? CGRectMake(left + 5.0f, 5.0f + (top > 20.0f ? .0f : top), width, height): CGRectMake(left + 5.0f, 5.0f + top, width, height)];
    _adNoteLabel.textColor = [UIColor whiteColor];
    _adNoteLabel.textAlignment = NSTextAlignmentCenter;
    _adNoteLabel.font = [UIFont systemFontOfSize:14.0f];
    _adNoteLabel.backgroundColor = [ATMyOfferSplashSharedDelegate layoutStylePortrait] ? [[UIColor whiteColor] colorWithAlphaComponent:.3f] : [[UIColor grayColor] colorWithAlphaComponent:.6f];
    _adNoteLabel.layer.cornerRadius = radius;
    _adNoteLabel.layer.masksToBounds = YES;
    _adNoteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _adNoteLabel.text = @"AD";
    [self addSubview:_adNoteLabel];
    
    
    if(_containerView != nil){
        _containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_containerView];
    }
}

-(NSArray<UIView*>*) clickableViews {
    NSMutableArray <UIView*>* clickableViews = [NSMutableArray<UIView*> array];
    if (self.ctaLabel != nil) { [clickableViews addObject:self.ctaLabel]; }
    if (self.mainImageView != nil) { [clickableViews addObject:self.mainImageView]; }
    if (self.textLabel != nil) { [clickableViews addObject:self.textLabel]; }
    if (self.titleLabel != nil) { [clickableViews addObject:self.titleLabel]; }
    if (self.ctaBackgroundImageView != nil) { [clickableViews addObject:self.ctaBackgroundImageView]; }
    if (self.starView != nil) { [clickableViews addObject:self.starView]; }
    return clickableViews;
}

-(void) makeConstraintsForSubviews {
    UIEdgeInsets safeAreaInsets = [UIScreen safeAreaInsets];
    CGFloat top = safeAreaInsets.top <= 0 ? CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) : safeAreaInsets.top;
    CGFloat bottom = safeAreaInsets.bottom;
    CGFloat left = safeAreaInsets.left;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if ([ATMyOfferSplashSharedDelegate layoutStylePortrait]) {
        NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_blurView, _skipButton, _starView, _titleLabel, _mainImageView, _textLabel, _ctaLabel, _ctaBackgroundImageView, _sponsorImageView, _containerView, _adNoteLabel);
        
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_adNoteLabel(20)]" options:0 metrics:@{@"top":@(top>20.0f?(top + 5.0f):20.0f)} views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"H:|-left-[_adNoteLabel(40)]" options:0 metrics:@{@"left":@(-left)} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"|[_blurView]|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_blurView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"|[_backgroundImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundImageView)];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_backgroundImageView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:NSDictionaryOfVariableBindings(_backgroundImageView)];
        
        CGFloat containerHeight = [((UIView*)[[ATMyOfferSplashSharedDelegate sharedDelegate] valueForKey:@"containerView"]) respondsToSelector:@selector(frame)] ? CGRectGetHeight(((UIView*)[[ATMyOfferSplashSharedDelegate sharedDelegate] valueForKey:@"containerView"]).frame) : .0f;
        
        if(_containerView != nil){
            [self internal_addConstraintsWithVisualFormat:@"H:|-0-[_containerView]-0-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_containerView]-0-|" options:0 metrics:@{@"top":@(height- containerHeight)} views:viewsDict];
        }
        
        _skipButtonWidthConstraint = [self internal_addConstraintsWithVisualFormat:@"[_skipButton(90)]-10-|" options:0 metrics:nil views:viewsDict][0];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_skipButton(28)]" options:0 metrics:@{@"top":@(20 + (top > 20.0f ? top : 0.0f))} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"H:[_sponsorImageView]-5-|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:[_sponsorImageView]-containerHeight-|" options:0 metrics:@{@"containerHeight":@(containerHeight + 5.0f)} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"|-33-[_titleLabel]-33-|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"|-10-[_mainImageView]-10-|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"|-20-[_textLabel]-20-|" options:0 metrics:nil views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"V:|-58-[_titleLabel]-12-[_starView]-30-[_mainImageView]-25-[_textLabel(55)]-20-[_ctaLabel(50)]->=bottom-|" options:NSLayoutFormatAlignAllCenterX metrics:@{@"bottom":@(bottom + containerHeight + 50.0f)} views:viewsDict];
        [_ctaLabel internal_addConstraintsWithVisualFormat:@"[_ctaLabel(200)]" options:0 metrics:nil views:viewsDict];
        [_mainImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_ctaLabel attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_ctaLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:222.0f];
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:71.0f];
    } else {
        NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_blurView, _skipButton, _starView, _titleLabel, _mainImageView, _textLabel, _ctaLabel, _ctaBackgroundImageView, _sponsorImageView, _containerView, _bottomImageView, _adNoteLabel);
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_adNoteLabel]" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"H:|-top-[_adNoteLabel]" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"|[_blurView]|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_blurView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"|[_backgroundImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundImageView)];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_backgroundImageView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:NSDictionaryOfVariableBindings(_backgroundImageView)];
        CGFloat trailing = [((UIView*)[[ATMyOfferSplashSharedDelegate sharedDelegate] valueForKey:@"containerView"]) respondsToSelector:@selector(frame)] ? CGRectGetWidth(((UIView*)[[ATMyOfferSplashSharedDelegate sharedDelegate] valueForKey:@"containerView"]).frame) : .0f;
        trailing = trailing>200.0f?200.0f:trailing;
        
        if(_containerView != nil){
            [self internal_addConstraintsWithVisualFormat:@"H:|-left-[_containerView]-0-|" options:0 metrics:@{@"left":@(width - trailing)} views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-0-[_containerView]-0-|" options:0 metrics:nil views:viewsDict];
        }
        
        [self internal_addConstraintsWithVisualFormat:@"H:[_skipButton(90)]-right-|" options:0 metrics:@{@"right":@(10 + trailing)} views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_skipButton(28)]" options:0 metrics:@{@"top":@(10 + (top > 20.0f ? .0f : top))} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"V:[_sponsorImageView]-5-|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"H:[_sponsorImageView]-trailing-|" options:0 metrics:@{@"trailing":@(trailing + 5.0f)} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"H:|-leading-[_mainImageView]-trailing-|" options:0 metrics:@{@"leading":@(left+80.0f), @"trailing":@(trailing + 80.0f)} views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_mainImageView]-bottom-|" options:0 metrics:@{@"top":@(top>20.0f?(top+40.0f):60.0f),@"bottom":@(top>20.0f?(height - bottom +100.0f ): 100.0f)} views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_bottomImageView]-5-|" options:0 metrics:@{@"top":@(top>20.0f?(bottom-90.0f):(height - 90.0f))} views:viewsDict];
        //        [self internal_addConstraintsWithVisualFormat:@"[_iconImageView]-10-[_titleLabel]" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"H:|-left-[_bottomImageView]-right-|" options:0 metrics:@{@"left":@(-left),@"right":@(trailing)} views:viewsDict];
        self.textLabel.hidden = YES;
        [self internal_addConstraintsWithVisualFormat:@"H:|-leading-[_titleLabel]" options:0 metrics:@{@"leading":@(left + 10.0f)} views:viewsDict];
        //        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_titleLabel]-10-[_starView]-10-|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"H:|-leading-[_starView]" options:0 metrics:@{@"leading":@(left + 10.0f)} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"H:[_ctaBackgroundImageView]-trailing-|" options:0 metrics:@{@"trailing":@(10.0f)} views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:[_ctaBackgroundImageView]-10-|" options:0 metrics:nil views:viewsDict];
        
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_ctaLabel attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_ctaLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        [self internal_addConstraintsWithVisualFormat:@"[_ctaBackgroundImageView(160)]" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:[_ctaBackgroundImageView(71)]" options:0 metrics:nil views:viewsDict];
    }
}
@end

#pragma mark - timer category
@interface NSTimer (WTSKit)
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
@end

static NSString *const kTimerUserInfoBlockKey = @"com.anythink.myoffer_splash_timer_block";
@interface NSObject(NSTimer)
-(void) timerHandler_anythink_myoffer:(NSTimer*)timer;
@end
@implementation NSTimer (ATKit)
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    return [NSTimer scheduledTimerWithTimeInterval:interval target:target selector:@selector(timerHandler_anythink_myoffer:) userInfo:@{kTimerUserInfoBlockKey:[block copy]} repeats:repeats];
}
@end

@implementation NSObject(ATKit)
-(void) timerHandler_anythink_myoffer:(NSTimer *)timer {
    void (^block)(NSTimer*) = timer.userInfo[kTimerUserInfoBlockKey];
    if (block != nil) {
        block(timer);
    }
}
@end


#pragma mark - splash wrapper
@interface ATMyOfferSplashSharedDelegate()

@property(nonatomic) ATMyOfferSplashView *currentSplashView;
@property(nonatomic, weak) UIView *containerView;
@property(nonatomic) NSString *layoutStyle;
@property(nonatomic) BOOL landingPageBeingShown;

@end


@implementation ATMyOfferSplashSharedDelegate
+(instancetype) sharedDelegate {
    static ATMyOfferSplashSharedDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATMyOfferSplashSharedDelegate alloc] init];
    });
    return sharedDelegate;
}

+(BOOL) layoutStylePortrait {
    return [ATMyOfferSplashSharedDelegate sharedDelegate].setting.splashOrientation==1?YES:NO;
}

-(void) initViewResourceWithRemainingTime:(NSTimeInterval)interval {
    if (_currentSplashView != nil && _offerModel != nil) {
        [ATMyOfferSplashStarRatingView configureStarView:_currentSplashView.starView star:5.0f];
        [_currentSplashView.mainImageView setImage:[[ATMyOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
        [_currentSplashView.backgroundImageView setImage:[[ATMyOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
        [_currentSplashView.titleLabel setText:self.offerModel.title];
        [_currentSplashView.textLabel setText:self.offerModel.text];
        [_currentSplashView.ctaLabel setText:self.offerModel.CTA];
        [_currentSplashView.sponsorImageView setImage:[[ATMyOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.logoURL]];
        NSInteger remainingTime = interval + 1;
        [_currentSplashView.skipButton setTitle:[NSString stringWithFormat:kSkipTextFormatString, --remainingTime, _setting.skipable ? [ATMyOfferSplashSharedDelegate skipSubString] : @""] forState:UIControlStateNormal];
        
    }
}


-(void) skipButtonTapped {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([ATMyOfferSplashSharedDelegate sharedDelegate].currentSplashView != nil) {
            [[ATMyOfferSplashSharedDelegate sharedDelegate].currentSplashView removeFromSuperview];
            if([ATMyOfferSplashSharedDelegate sharedDelegate].containerView != nil) [[ATMyOfferSplashSharedDelegate sharedDelegate].containerView removeFromSuperview];
            
            id<ATMyOfferSplashDelegate> delegate = [self delegateForPlacementID:_offerModel.offerID];
            if ([delegate respondsToSelector:@selector(myOfferSplashCloseOffer:)]) {
                [delegate myOfferSplashCloseOffer:_offerModel];
            }
            
            [ATMyOfferSplashSharedDelegate sharedDelegate].currentSplashView = nil;
        }
    });
    
}

-(void) adViewTapped {
    [ATLogger logMessage:@"ATMyOfferSplashSharedDelegate::adViewTapped" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferSplashDelegate> delegate = [weakSelf delegateForPlacementID:_offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:_offerModel] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:_offerModel setting:_setting extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventClick offerModel:_offerModel extra:trackerExtra];
        
        if ([delegate respondsToSelector:@selector(myOfferSplashClickOffer:)]) { [delegate myOfferSplashClickOffer:_offerModel]; }
        [weakSelf skipButtonTapped];
        
        return nil;
    }];
}


-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _delegateStorageAccessor = [ATThreadSafeAccessor new];
        _delegates_accessing_queue = dispatch_queue_create("myofferSplashDelegatesAccessingQueue.com.anythink", DISPATCH_QUEUE_CONCURRENT);
        _delegates = [NSMutableDictionary<NSString*, id<ATMyOfferSplashDelegate>> dictionary];
        [UIViewController swizzleMethods];
        [[NSNotificationCenter defaultCenter] addObserverForName:kATUIViewControllerPresentationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [ATMyOfferSplashSharedDelegate sharedDelegate].landingPageBeingShown = YES;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kATUIViewControllerDismissalNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [ATMyOfferSplashSharedDelegate sharedDelegate].landingPageBeingShown = NO;
            [[ATMyOfferSplashSharedDelegate sharedDelegate] skipButtonTapped];
        }];
        _splashExtra = [NSMutableDictionary dictionary];
    }
    return self;
}

static NSString *kLanguageConfigurationSkip = @"skip";
+(NSDictionary*) languageConfiguration {
    static NSDictionary *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = @{@"skip":@{@"zh":@" 跳过", @"ja":@" スキップ", @"en":@" Skip"}};
    });
    return config;
}

+(NSString*)skipSubString {
    return [[ATMyOfferSplashSharedDelegate languageConfiguration][kLanguageConfigurationSkip][[[Utilities language] componentsSeparatedByString:@"-"][0]] length] > 0 ? [ATMyOfferSplashSharedDelegate languageConfiguration][kLanguageConfigurationSkip][[[Utilities language] componentsSeparatedByString:@"-"][0]] : @" Skip";
}

-(void) startCountdown:(NSTimeInterval)interval {
    __block NSInteger remainingTime = interval;
    __weak typeof(self) weakSelf = self;
    [NSTimer timerWithTimeInterval:1.0f target:self repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        if (weakSelf.currentSplashView != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (remainingTime == 0) {
                    [timer invalidate];
                    [ATMyOfferSplashSharedDelegate sharedDelegate].landingPageBeingShown = NO;
                    [[ATMyOfferSplashSharedDelegate sharedDelegate] skipButtonTapped];
                    
                } else {
                    [weakSelf.currentSplashView.skipButton setTitle:[NSString stringWithFormat:kSkipTextFormatString, --remainingTime, weakSelf.setting.skipable ? [ATMyOfferSplashSharedDelegate skipSubString] : @""] forState:UIControlStateNormal];
                    if(weakSelf.setting.skipable){
                        [weakSelf.currentSplashView.skipButton addTarget:weakSelf action:@selector(skipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
                    }
                }
            });
        } else {
            [timer invalidate];
        }
    }];
}

-(void) setCurrentSplashViewWithOfferModel:(ATMyOfferOfferModel *) offerModel window:(UIWindow *)window containerView:(UIView *)containerView remainingTime:(NSTimeInterval)remainingTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        //show splash with window
        
        if([ATMyOfferSplashSharedDelegate sharedDelegate].currentSplashView != nil)[[ATMyOfferSplashSharedDelegate sharedDelegate].currentSplashView removeFromSuperview];
        if([ATMyOfferSplashSharedDelegate sharedDelegate].containerView != nil)[[ATMyOfferSplashSharedDelegate sharedDelegate].containerView removeFromSuperview];
        [ATMyOfferSplashSharedDelegate sharedDelegate].containerView = containerView;
        ATMyOfferSplashView* splashView = [[ATMyOfferSplashView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)) containerView:containerView];
        [ATMyOfferSplashSharedDelegate sharedDelegate].currentSplashView = splashView;
        [self initViewResourceWithRemainingTime:remainingTime];
        NSArray<UIView*>* clickableViews = [[ATMyOfferSplashSharedDelegate sharedDelegate].currentSplashView clickableViews];
        
        for (UIView *clickableView in clickableViews) {
            UITapGestureRecognizer *tapsAd = [[UITapGestureRecognizer alloc]initWithTarget:[ATMyOfferSplashSharedDelegate sharedDelegate] action:@selector(adViewTapped)];
            tapsAd.numberOfTouchesRequired = 1;
            tapsAd.numberOfTapsRequired = 1;
            clickableView.userInteractionEnabled = YES;
            [clickableView addGestureRecognizer:tapsAd];
        }
        
        [[ATMyOfferSplashSharedDelegate sharedDelegate] startCountdown:(remainingTime>0)?remainingTime : _setting.splashCountDownTime];
        [window addSubview:_currentSplashView];
        
    });
    
    
}

-(void) setDelegate:(id<ATMyOfferSplashDelegate>)delegate forPlacementID:(NSString*)placementID {
    if (delegate != nil && placementID != nil) { dispatch_barrier_async(_delegates_accessing_queue, ^{ self->_delegates[placementID] = delegate; }); }
}

-(void) removeDelegateForPlacementID:(NSString*)placementID {
    if (placementID != nil) { dispatch_barrier_async(_delegates_accessing_queue, ^{ [self->_delegates removeObjectForKey:placementID]; }); }
}

-(id<ATMyOfferSplashDelegate>)delegateForPlacementID:(NSString*)placementID {
    id<ATMyOfferSplashDelegate> __block delegate = nil;
    dispatch_sync(_delegates_accessing_queue, ^{ delegate = self->_delegates[placementID]; });
    return delegate;
}

- (void)showSplashInKeyWindow:(UIWindow *)window containerView:(UIView *)containerView offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting  delegate:(id<ATMyOfferSplashDelegate>)delegate {
    _setting = setting;
    _offerModel = offerModel;
    
    if ([[ATMyOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
        if ([[ATMyOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.fullScreenImageURL] != nil) {
            __weak typeof(self) weakSelf = self;
            [_delegateStorageAccessor writeWithBlock:^{
                [weakSelf setDelegate:delegate forPlacementID:offerModel.offerID];
                
            }];
            [weakSelf setCurrentSplashViewWithOfferModel:offerModel window:window containerView:containerView remainingTime:_setting.splashCountDownTime/1000];
            
            id<ATMyOfferSplashDelegate> delegate = [self delegateForPlacementID:offerModel.offerID];
            NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:_offerModel] : @"";
            [[ATMyOfferTracker sharedTracker] impressionOfferWithOfferModel:_offerModel extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
            NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
            [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventImpression offerModel:_offerModel extra:trackerExtra];
            if ([delegate respondsToSelector:@selector(myOfferSplashShowOffer:)]) { [delegate myOfferSplashShowOffer:offerModel]; }
            
            [[ATMyOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
            [[ATMyOfferCapsManager shareManager] increaseCapForOfferModel:offerModel];
            if ([[ATMyOfferCapsManager shareManager] validateCapsForOfferModel:offerModel]) {
                [[ATPlacementSettingManager sharedManager] removeCappedMyOfferID:offerModel.offerID];
            } else {
                [[ATPlacementSettingManager sharedManager] addCappedMyOfferID:offerModel.offerID];
            }
        } else {
            if ([delegate respondsToSelector:@selector(myOfferSplashFailToShowOffer:error:)]) { [delegate myOfferSplashFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.MyOfferSplashShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to show interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Interstitial's not ready for video URL:%@", offerModel.videoURL]}]]; }
        }
    } else {
        if ([delegate respondsToSelector:@selector(myOfferSplashFailToShowOffer:error:)]) { [delegate myOfferSplashFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.MyOfferSplashShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to show interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Interstitial's not ready for offerID:%@", offerModel.offerID]}]]; }
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
    
   //TODO something when storeit is close
    
}


@end
