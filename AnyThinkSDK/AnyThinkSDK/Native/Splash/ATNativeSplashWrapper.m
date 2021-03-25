//
//  ATNativeSplashWrapper.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2019/3/19.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNativeSplashWrapper.h"
#import "UIViewController+PresentationAndDismissalSwizzling.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATNativeADView.h"
#import "ATNativeADConfiguration.h"
#import "ATAdManager+Internal.h"
#import "ATAdManager+Native.h"
#import "ATPlacementModel.h"
#import "ATPlacementSettingManager.h"
#import "UIViewController+PresentationAndDismissalSwizzling.h"
#import "ATNativeADDelegate.h"

NSString *const kATNativeSplashShowingExtraCTAButtonBackgroundColorKey = @"cta_button_bg_color";
NSString *const kATNativeSplashShowingExtraCTAButtonTitleColorKey = @"cta_btn_title_color";
NSString *const kATNativeSplashShowingExtraContainerViewKey = @"container_view";
NSString *const kATNativeSplashShowingExtraCountdownIntervalKey = @"countdown_interval";
NSString *const kATNatievSplashShowingExtraStyleKey = @"layout_style";

NSString *const kATNativeSplashShowingExtraStylePortrait = @"layout_style_protrait";
NSString *const kATNativeSplashShowingExtraStyleLandscape = @"layout_style_landscape";

@interface ATNativeSplashWrapper(Layout)
@end
@implementation ATNativeSplashWrapper (Layout)

+(BOOL) layoutStylePortrait {
    return [kATNativeSplashShowingExtraStylePortrait isEqualToString:[[ATNativeSplashWrapper sharedWrapper] valueForKey:@"layoutStyle"]];
}

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
@interface ATSplashNativeStarRatingView:UIView
@property(nonatomic, readonly) UIImageView *star0;
@property(nonatomic, readonly) UIImageView *star1;
@property(nonatomic, readonly) UIImageView *star2;
@property(nonatomic, readonly) UIImageView *star3;
@property(nonatomic, readonly) UIImageView *star4;
@end
@implementation ATSplashNativeStarRatingView
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

+(void) configureStarView:(ATSplashNativeStarRatingView*)starView star:(CGFloat)star {
    NSArray<UIImageView*>* stars = @[starView.star0, starView.star1, starView.star2, starView.star3, starView.star4];
    NSInteger consumedStar = 0;
    CGFloat remainStar = star;
    while (consumedStar < 5) {
        stars[consumedStar++].image = [UIImage anythink_imageWithName:remainStar >= 1.0f ? @"native_splash_cta_star_on" : remainStar > .0f ? @"native_splash_cta_semi_star" : @"native_splash_cta_star_off"];
        remainStar -= remainStar > 1.0f ? 1.0f : remainStar > .0f ? remainStar : .0f;
    }
}
@end

#pragma mark - splash view
@interface ATNativeSplashView:ATNativeADView
@property(nonatomic, readonly) UIVisualEffectView *blurView;
@property(nonatomic, readonly) UIButton *skipButton;
@property(nonatomic, readonly) NSLayoutConstraint *skipButtonWidthConstraint;

@property(nonatomic, readonly) ATSplashNativeStarRatingView *starView;
@property(nonatomic, readonly) UILabel *advertiserLabel;
@property(nonatomic, readonly) UILabel *textLabel;
@property(nonatomic, readonly) UILabel *titleLabel;
@property(nonatomic, readonly) UILabel *ctaLabel;
@property(nonatomic, readonly) UILabel *ratingLabel;
@property(nonatomic, readonly) UIImageView *iconImageView;
@property(nonatomic, readonly) UIImageView *mainImageView;
@property(nonatomic, readonly) UIImageView *sponsorImageView;
@property(nonatomic, readonly) UIImageView *backgroundImageView;
@property(nonatomic, readonly) UIImageView *ctaBackgroundImageView;

@property(nonatomic, readonly) UILabel *adNoteLabel;
@end

static NSString *const kSkipTextFormatString = @"%lds%@";
@implementation ATNativeSplashView
-(void) initSubviews {
    [super initSubviews];
    _backgroundImageView = [UIImageView internal_autolayoutView];
    [self addSubview:_backgroundImageView];
    
    self.backgroundColor = [UIColor clearColor];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_blurView];
    
    _advertiserLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:11.0f] textColor:[UIColor whiteColor]];
    [self addSubview:_advertiserLabel];
    _advertiserLabel.hidden = YES;
    
    _iconImageView = [UIImageView internal_autolayoutView];
    _iconImageView.layer.cornerRadius = 8.0f;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_iconImageView];
    _iconImageView.hidden = [ATNativeSplashWrapper layoutStylePortrait];
    
    _titleLabel = [UILabel internal_autolayoutLabelFont:[UIFont boldSystemFontOfSize:[ATNativeSplashWrapper layoutStylePortrait] ? 23.0f : 16.0f] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _textLabel = [UILabel internal_autolayoutLabelFont:[UIFont boldSystemFontOfSize:17.0f] textColor:[UIColor whiteColor]];
    _textLabel.numberOfLines = 2;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
    _textLabel.hidden = ![ATNativeSplashWrapper layoutStylePortrait];
    
    _starView = [ATSplashNativeStarRatingView internal_autolayoutView];
    [self addSubview:_starView];
    
    _mainImageView = [UIImageView internal_autolayoutView];
    _mainImageView.backgroundColor = [UIColor clearColor];
    _mainImageView.layer.cornerRadius = 4.0f;
    _mainImageView.layer.masksToBounds = YES;
    _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_mainImageView];
    
    _ctaBackgroundImageView = [UIImageView internal_autolayoutView];
    _ctaBackgroundImageView.image = [[UIImage anythink_imageWithName:@"native_splash_cta_btn_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(.0f, 35.0f, .0f, 35.0f) resizingMode:UIImageResizingModeStretch];
    [self addSubview:_ctaBackgroundImageView];
    
    _ctaLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:[ATNativeSplashWrapper layoutStylePortrait] ? 23.0f : 15.0f] textColor:[UIColor whiteColor]];
    _ctaLabel.text = @"了解理多";
    _ctaLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_ctaLabel];
    
    CGFloat left = [UIScreen safeAreaInsets].left;
    CGFloat top = [UIScreen safeAreaInsets].top <= 0 ? CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) : [UIScreen safeAreaInsets].top;
    CGFloat width = [ATNativeSplashWrapper layoutStylePortrait] ? 40.0f : 58.0f;
    CGFloat height = [ATNativeSplashWrapper layoutStylePortrait] ? 22.0f : 20.0f;
    CGFloat radius = 4.0f;
    
    _adNoteLabel = [[UILabel alloc] initWithFrame:[ATNativeSplashWrapper layoutStylePortrait] ? CGRectMake(left + 10.0f, 10.0f + (top > 20.0f ? .0f : top), width, height): CGRectMake(left + 20.0f, 20.0f + top, width, height)];
    _adNoteLabel.textColor = [UIColor whiteColor];
    _adNoteLabel.textAlignment = NSTextAlignmentCenter;
    _adNoteLabel.font = [UIFont systemFontOfSize:14.0f];
    _adNoteLabel.backgroundColor = [ATNativeSplashWrapper layoutStylePortrait] ? [[UIColor whiteColor] colorWithAlphaComponent:.3f] : [[UIColor grayColor] colorWithAlphaComponent:.6f];
    _adNoteLabel.layer.cornerRadius = radius;
    _adNoteLabel.layer.masksToBounds = YES;
    _adNoteLabel.text = @"AD";
    [self addSubview:_adNoteLabel];
    
    _skipButton = [UIButton internal_autolayoutButtonWithType:UIButtonTypeCustom];
    [_skipButton setTitleColor:[UIColor colorWithRed:233.0f / 255.0f green:233.0f / 255.0f blue:233.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    _skipButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _skipButton.backgroundColor = [ATNativeSplashWrapper layoutStylePortrait] ? [[UIColor whiteColor] colorWithAlphaComponent:.3f] : [[UIColor grayColor] colorWithAlphaComponent:.6f];
    _skipButton.layer.cornerRadius = 14.0f;
    [self addSubview:_skipButton];
}

-(NSArray<UIView*>*) clickableViews {
    NSMutableArray <UIView*>* clickableViews = [NSMutableArray<UIView*> array];
    if (self.mediaView != nil) { [clickableViews addObject:self.mediaView]; }
    if (self.ctaLabel != nil) { [clickableViews addObject:self.ctaLabel]; }
    if (self.mainImageView != nil) { [clickableViews addObject:self.mainImageView]; }
    if (self.iconImageView != nil) { [clickableViews addObject:self.iconImageView]; }
    return clickableViews;
}

-(CGFloat) calculateMediaHeight {
    UIEdgeInsets safeAreaInsets = [UIScreen safeAreaInsets];
    CGFloat bottom = safeAreaInsets.bottom;
    
    CGFloat containerHeight = [((UIView*)[[ATNativeSplashWrapper sharedWrapper] valueForKey:@"containerView"]) respondsToSelector:@selector(frame)] ? CGRectGetHeight(((UIView*)[[ATNativeSplashWrapper sharedWrapper] valueForKey:@"containerView"]).frame) : .0f;
    
    return CGRectGetHeight(self.bounds) - 58.0f - ([ATNativeSplashWrapper layoutStylePortrait] ? 23.0f : 16.0f) - 12.0f - 18.0f - 30.0f - 25.0f - 55.0f - 20.0f - 50.0f - (bottom + containerHeight + 50.0f);
}

-(void) makeConstraintsForSubviews {
    UIEdgeInsets safeAreaInsets = [UIScreen safeAreaInsets];
    CGFloat top = safeAreaInsets.top <= 0 ? CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) : safeAreaInsets.top;
    CGFloat bottom = safeAreaInsets.bottom;
    CGFloat left = safeAreaInsets.left;
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_blurView, _skipButton, _iconImageView, _starView, _titleLabel, _mainImageView, _textLabel, _ctaLabel, _ctaBackgroundImageView);
    
    [self internal_addConstraintsWithVisualFormat:@"|[_blurView]|" options:0 metrics:nil views:viewsDict];
    [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_blurView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:viewsDict];
    
    [self internal_addConstraintsWithVisualFormat:@"|[_backgroundImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundImageView)];
    [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_backgroundImageView]-bottom-|" options:0 metrics:@{@"top":@(-top), @"bottom":@(-bottom)} views:NSDictionaryOfVariableBindings(_backgroundImageView)];
    
    if ([ATNativeSplashWrapper layoutStylePortrait]) {
        CGFloat containerHeight = [((UIView*)[[ATNativeSplashWrapper sharedWrapper] valueForKey:@"containerView"]) respondsToSelector:@selector(frame)] ? CGRectGetHeight(((UIView*)[[ATNativeSplashWrapper sharedWrapper] valueForKey:@"containerView"]).frame) : .0f;
        _skipButtonWidthConstraint = [self internal_addConstraintsWithVisualFormat:@"[_skipButton(90)]-10-|" options:0 metrics:nil views:viewsDict][0];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_skipButton(28)]" options:0 metrics:@{@"top":@(10 + (top > 20.0f ? .0f : top))} views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"|-33-[_titleLabel]-33-|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"|-10-[_mainImageView]-10-|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"|-20-[_textLabel]-20-|" options:0 metrics:nil views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"V:|-58-[_titleLabel]-12-[_starView]-30-[_mainImageView]-25-[_textLabel(55)]-20-[_ctaLabel(50)]->=bottom-|" options:NSLayoutFormatAlignAllCenterX metrics:@{@"bottom":@(bottom + containerHeight + 50.0f)} views:viewsDict];
        [_iconImageView internal_addConstraintWithItem:_iconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_iconImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:.0f];
        [_ctaLabel internal_addConstraintsWithVisualFormat:@"[_ctaLabel(200)]" options:0 metrics:nil views:viewsDict];
        [_mainImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_ctaLabel attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_ctaLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:222.0f];
        [self internal_addConstraintWithItem:_ctaBackgroundImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:71.0f];
    } else {
        CGFloat trailing = [((UIView*)[[ATNativeSplashWrapper sharedWrapper] valueForKey:@"containerView"]) respondsToSelector:@selector(frame)] ? CGRectGetWidth(((UIView*)[[ATNativeSplashWrapper sharedWrapper] valueForKey:@"containerView"]).frame) : .0f;
        _skipButtonWidthConstraint = [self internal_addConstraintsWithVisualFormat:@"[_skipButton(70)]-trailing-|" options:0 metrics:@{@"trailing":@(20.0f + trailing)} views:viewsDict][0];
        [self internal_addConstraintsWithVisualFormat:@"V:|-20-[_skipButton(28)]" options:0 metrics:nil views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"|-leading-[_mainImageView]-trailing-|" options:0 metrics:@{@"leading":@(left > 0 ? left : 15.0f), @"trailing":@(trailing + 15.0f)} views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|-top-[_mainImageView]-10-[_iconImageView(53)]-15-|" options:NSLayoutFormatAlignAllLeading metrics:@{@"top":@(top + 15.0f)} views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"[_iconImageView]-10-[_titleLabel]" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDict];
        [self internal_addConstraintWithItem:_iconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_iconImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:.0f];
        [self internal_addConstraintsWithVisualFormat:@"[_titleLabel]->=10-[_ctaBackgroundImageView]-trailing-|" options:0 metrics:@{@"trailing":@(trailing + 5.0f)} views:viewsDict];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self internal_addConstraintsWithVisualFormat:@"V:[_titleLabel]-10-[_starView]" options:NSLayoutFormatAlignAllLeading metrics:nil views:viewsDict];
        [self internal_addConstraintWithItem:_iconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_ctaBackgroundImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        
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

static NSString *const kTimerUserInfoBlockKey = @"com.anythink.timer_block";
@interface NSObject(NSTimer)
-(void) timerHandler_anythink:(NSTimer*)timer;
@end
@implementation NSTimer (ATKit)
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    return [NSTimer scheduledTimerWithTimeInterval:interval target:target selector:@selector(timerHandler_anythink:) userInfo:@{kTimerUserInfoBlockKey:[block copy]} repeats:repeats];
}
@end

@implementation NSObject(ATKit)
-(void) timerHandler_anythink:(NSTimer *)timer {
    void (^block)(NSTimer*) = timer.userInfo[kTimerUserInfoBlockKey];
    if (block != nil) {
        block(timer);
    }
}
@end

#pragma mark - splash wrapper
@interface ATNativeSplashWrapper()<ATNativeADDelegate>
@property(nonatomic, readonly) dispatch_queue_t delegates_accessing_queue;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, id<ATNativeSplashDelegate>> *delegates;
@property(nonatomic) ATNativeSplashView *currentSplashView;
@property(nonatomic, weak) UIView *containerView;
@property(nonatomic) NSString *layoutStyle;
@property(nonatomic) BOOL landingPageBeingShown;
@property(nonatomic) NSMutableDictionary *splashExtra;
@end
@implementation ATNativeSplashWrapper
+(instancetype) sharedWrapper {
    static ATNativeSplashWrapper *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATNativeSplashWrapper alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _delegates_accessing_queue = dispatch_queue_create("nativeSplashDelegatesAccessingQueue.com.anythink", DISPATCH_QUEUE_CONCURRENT);
        _delegates = [NSMutableDictionary<NSString*, id<ATNativeSplashDelegate>> dictionary];
        [UIViewController swizzleMethods];
        [[NSNotificationCenter defaultCenter] addObserverForName:kATUIViewControllerPresentationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [ATNativeSplashWrapper sharedWrapper].landingPageBeingShown = YES;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kATUIViewControllerDismissalNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [ATNativeSplashWrapper sharedWrapper].landingPageBeingShown = NO;
            [[ATNativeSplashWrapper sharedWrapper] skipButtonTapped];
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
    return [[ATNativeSplashWrapper languageConfiguration][kLanguageConfigurationSkip][[[Utilities language] componentsSeparatedByString:@"-"][0]] length] > 0 ? [ATNativeSplashWrapper languageConfiguration][kLanguageConfigurationSkip][[[Utilities language] componentsSeparatedByString:@"-"][0]] : @" Skip";
}

-(void) startCountdown:(NSTimeInterval)interval {
    __block NSInteger remainingTime = interval;
    __weak typeof(self) weakSelf = self;
    [NSTimer timerWithTimeInterval:1.0f target:self repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.currentSplashView != nil) {
            ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:[[weakSelf.currentSplashView embededAdView] valueForKey:@"placementID"]];
            if (remainingTime == 0) {
                [weakSelf.currentSplashView.skipButton setTitle:nil forState:UIControlStateNormal];
                [weakSelf.currentSplashView.skipButton setImage:[UIImage anythink_imageWithName:@"native_splash_close_btn"] forState:UIControlStateNormal];
                weakSelf.currentSplashView.skipButtonWidthConstraint.constant = 28.0f;
                [weakSelf.currentSplashView.skipButton addTarget:self action:@selector(skipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
                [timer invalidate];
                if (![ATNativeSplashWrapper sharedWrapper].landingPageBeingShown) {
                    if (!placementModel.extra.usesServerSettings || (placementModel.extra.usesServerSettings && placementModel.extra.closeAfterCountdownElapsed)) { [weakSelf skipButtonTapped]; }
                }
            } else {
                [weakSelf.currentSplashView.skipButton setTitle:[NSString stringWithFormat:kSkipTextFormatString, --remainingTime, placementModel.extra.usesServerSettings ? (placementModel.extra.allowsSkip ? [ATNativeSplashWrapper skipSubString] : @"") : [ATNativeSplashWrapper skipSubString]] forState:UIControlStateNormal];
            }
        } else {
            [timer invalidate];
        }
    }];
}

-(void) setCurrentSplashView:(ATNativeSplashView *)currentSplashView {
    [_currentSplashView removeFromSuperview];
    _currentSplashView = currentSplashView;
}

-(void) setDelegate:(id<ATNativeSplashDelegate>)delegate forPlacementID:(NSString*)placementID {
    if (delegate != nil && placementID != nil) { dispatch_barrier_async(_delegates_accessing_queue, ^{ self->_delegates[placementID] = delegate; }); }
}

-(void) removeDelegateForPlacementID:(NSString*)placementID {
    if (placementID != nil) { dispatch_barrier_async(_delegates_accessing_queue, ^{ [self->_delegates removeObjectForKey:placementID]; }); }
}

-(id<ATNativeSplashDelegate>)delegateForPlacementID:(NSString*)placementID {
    id<ATNativeSplashDelegate> __block delegate = nil;
    dispatch_sync(_delegates_accessing_queue, ^{ delegate = self->_delegates[placementID]; });
    return delegate;
}

+(void) loadNativeSplashAdWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATNativeSplashDelegate>)delegate {
    [[ATNativeSplashWrapper sharedWrapper] setDelegate:delegate forPlacementID:placementID];
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:extra delegate:[ATNativeSplashWrapper sharedWrapper]];
}

+(void) handleGADAdViewClick {
    NSArray<UIView*>* subviews = [ATNativeSplashWrapper sharedWrapper].currentSplashView.subviews;
    if ([subviews count] > 0 && [subviews[0] isKindOfClass:NSClassFromString(@"GADUnifiedNativeAdView")]) {
        __block UIVisualEffectView *blurView = nil;
        [subviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"UIVisualEffectView")]) {
                blurView = (UIVisualEffectView*)obj;
                *stop = YES;
            }
        }];
        if (blurView != nil) { [[ATNativeSplashWrapper sharedWrapper].currentSplashView insertSubview:subviews[0] aboveSubview:blurView]; }
    }
}

+(void) showNativeSplashAdWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra delegate:(id<ATNativeSplashDelegate>)delegate {
    [ATNativeSplashWrapper sharedWrapper].containerView = extra[kATNativeSplashShowingExtraContainerViewKey];
    [ATNativeSplashWrapper sharedWrapper].layoutStyle = extra[kATNatievSplashShowingExtraStyleKey] != nil ? extra[kATNatievSplashShowingExtraStyleKey] : kATNativeSplashShowingExtraStylePortrait;
    
    if ([extra[kATNativeSplashShowingExtraCountdownIntervalKey] isKindOfClass:[NSNumber class]]) {
        objc_setAssociatedObject([ATNativeSplashWrapper sharedWrapper], (__bridge_retained void*)kATNativeSplashShowingExtraCountdownIntervalKey, extra[kATNativeSplashShowingExtraCountdownIntervalKey], OBJC_ASSOCIATION_RETAIN);
    }
    ATNativeADConfiguration *config = [[ATNativeADConfiguration alloc] init];
    UIEdgeInsets safeAreaInsets = [UIScreen safeAreaInsets];
    CGFloat top = safeAreaInsets.top;
    CGFloat bottom = safeAreaInsets.bottom;
    config.ADFrame = CGRectMake(.0f, top, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - top - bottom);
    config.delegate = [ATNativeSplashWrapper sharedWrapper];
    config.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    config.context = @{kATNativeAdConfigurationContextAdLogoViewFrameKey:[NSValue valueWithCGRect:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 54.0f - 10.0f, 120.0f + ([ATNativeSplashWrapper layoutStylePortrait] ? 23.0f : 16.0f), 54.0f, 18.0f)], kATNativeAdConfigurationContextAdOptionsViewFrameKey:[NSValue valueWithCGRect:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 43.0f - 10.0f, 118.0f + ([ATNativeSplashWrapper layoutStylePortrait] ? 23.0f : 16.0f), 43.0f, 18.0f)]};
    config.renderingViewClass = [ATNativeSplashView class];
    [ATNativeSplashWrapper sharedWrapper].currentSplashView = [[ATAdManager sharedManager] retriveAdViewWithPlacementID:placementID configuration:config];
    if ([ATNativeSplashWrapper sharedWrapper].currentSplashView != nil) {
        ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
        if (placementModel.extra.usesServerSettings) {
            objc_setAssociatedObject([ATNativeSplashWrapper sharedWrapper], (__bridge_retained void*)kATNativeSplashShowingExtraCountdownIntervalKey, @(placementModel.extra.countdown), OBJC_ASSOCIATION_RETAIN);
            [[ATNativeSplashWrapper sharedWrapper].currentSplashView.skipButton setTitle:[NSString stringWithFormat:kSkipTextFormatString, placementModel.extra.countdown, placementModel.extra.usesServerSettings && placementModel.extra.allowsSkip ? [ATNativeSplashWrapper skipSubString] : @""] forState:UIControlStateNormal];
        } else {
            if ([extra[kATNativeSplashShowingExtraCountdownIntervalKey] isKindOfClass:[NSNumber class]]) {
                objc_setAssociatedObject([ATNativeSplashWrapper sharedWrapper], (__bridge_retained void*)kATNativeSplashShowingExtraCountdownIntervalKey, extra[kATNativeSplashShowingExtraCountdownIntervalKey], OBJC_ASSOCIATION_RETAIN);
                [[ATNativeSplashWrapper sharedWrapper].currentSplashView.skipButton setTitle:[NSString stringWithFormat:kSkipTextFormatString, [extra[kATNativeSplashShowingExtraCountdownIntervalKey] integerValue], [ATNativeSplashWrapper skipSubString]] forState:UIControlStateNormal];
            }
        }
        
        if ([extra[kATNativeSplashShowingExtraCTAButtonBackgroundColorKey] isKindOfClass:[UIColor class]]) {
            [ATNativeSplashWrapper sharedWrapper].currentSplashView.ctaLabel.backgroundColor = extra[kATNativeSplashShowingExtraCTAButtonBackgroundColorKey];
            [ATNativeSplashWrapper sharedWrapper].currentSplashView.ctaBackgroundImageView.hidden = YES;
        }
        
        if ([extra[kATNativeSplashShowingExtraCTAButtonTitleColorKey] isKindOfClass:[UIColor class]]) {
            [ATNativeSplashWrapper sharedWrapper].currentSplashView.ctaLabel.textColor = extra[kATNativeSplashShowingExtraCTAButtonTitleColorKey];
        }
        //Handle admob
        [self handleGADAdViewClick];
        //Handle facebook
        if ([[ATNativeSplashWrapper sharedWrapper].currentSplashView.mediaView isKindOfClass:NSClassFromString(@"FBMediaView")]) {
            UIView *adView = [ATNativeSplashWrapper sharedWrapper].currentSplashView;
            UIView *mediaView = [ATNativeSplashWrapper sharedWrapper].currentSplashView.mediaView;
            mediaView.translatesAutoresizingMaskIntoConstraints = NO;
            UIView *mainImageView = [ATNativeSplashWrapper sharedWrapper].currentSplashView.mainImageView;
            [adView internal_addConstraintWithItem:mediaView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainImageView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
            [adView internal_addConstraintWithItem:mediaView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:mainImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
            [adView internal_addConstraintWithItem:mediaView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:mainImageView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:.0f];
            [adView internal_addConstraintWithItem:mediaView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:mainImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:.0f];
            [adView internal_addConstraintWithItem:mainImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:CGRectGetWidth(adView.bounds) - 20.0f];
            [adView internal_addConstraintWithItem:mainImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:[[ATNativeSplashWrapper sharedWrapper].currentSplashView calculateMediaHeight]];
        } else {
            [ATNativeSplashWrapper sharedWrapper].currentSplashView.mediaView.frame = [ATNativeSplashWrapper sharedWrapper].currentSplashView.mainImageView.frame;
        }
        [ATNativeSplashWrapper sharedWrapper].currentSplashView.mainImageView.hidden = NO;
        if (placementModel.extra.usesServerSettings) {
            if (placementModel.extra.allowsSkip) {
                [[ATNativeSplashWrapper sharedWrapper].currentSplashView.skipButton addTarget:[ATNativeSplashWrapper sharedWrapper] action:@selector(skipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [ATNativeSplashWrapper sharedWrapper].currentSplashView.skipButtonWidthConstraint.constant = 28.0f;
            }
        } else{
            [[ATNativeSplashWrapper sharedWrapper].currentSplashView.skipButton addTarget:[ATNativeSplashWrapper sharedWrapper] action:@selector(skipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        }
        [[ATNativeSplashWrapper sharedWrapper].currentSplashView bringSubviewToFront:[ATNativeSplashWrapper sharedWrapper].currentSplashView.skipButton];
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:[ATNativeSplashWrapper sharedWrapper].currentSplashView];
        [ATSplashNativeStarRatingView configureStarView:[ATNativeSplashWrapper sharedWrapper].currentSplashView.starView star:[[ATNativeSplashWrapper sharedWrapper].currentSplashView.ratingLabel.text floatValue] > .0f ? [[ATNativeSplashWrapper sharedWrapper].currentSplashView.ratingLabel.text floatValue] : 5.0f];
        if ([[ATNativeSplashWrapper sharedWrapper].currentSplashView.ctaLabel.text length] <= 0) {
            [ATNativeSplashWrapper sharedWrapper].currentSplashView.ctaLabel.text = @"了解更多";
        }
        
        if ([extra[kATNativeSplashShowingExtraContainerViewKey] isKindOfClass:[UIView class]]) {
            UIView *view = extra[kATNativeSplashShowingExtraContainerViewKey];
            view.frame = [ATNativeSplashWrapper layoutStylePortrait] ? CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) / 2.0f - CGRectGetMidX(view.bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(view.bounds) - bottom, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)) : CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(view.bounds), CGRectGetHeight([UIScreen mainScreen].bounds) / 2.0f - CGRectGetHeight(view.bounds) / 2.0f, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds));
            [[ATNativeSplashWrapper sharedWrapper].currentSplashView addSubview:view];
        }
        [ATNativeSplashWrapper sharedWrapper].currentSplashView.backgroundImageView.image = [ATNativeSplashWrapper sharedWrapper].currentSplashView.nativeAd.mainImage;
    }
}

+(BOOL) splashNativeAdReadyForPlacementID:(NSString*)placementID {
    return [[ATAdManager sharedManager] nativeAdReadyForPlacementID:placementID];
}

-(void) skipButtonTapped {
    if ([ATNativeSplashWrapper sharedWrapper].currentSplashView != nil) {
        NSString *placementID = [[[ATNativeSplashWrapper sharedWrapper].currentSplashView embededAdView] valueForKeyPath:@"currentOffer.placementModel.placementID"];
        id<ATNativeSplashDelegate> delegate = [self delegateForPlacementID:placementID];
        if ([delegate respondsToSelector:@selector(didCloseNativeSplashAdForPlacementID:)]) {
            [delegate didCloseNativeSplashAdForPlacementID:placementID];
        }
        if ([delegate respondsToSelector:@selector(didCloseNativeSplashAdForPlacementID:extra:)]) {
            [delegate didCloseNativeSplashAdForPlacementID:placementID extra:_splashExtra];
        }

        [ATNativeSplashWrapper sharedWrapper].currentSplashView = nil;
    }
}

#pragma mark - native delegate(s)
-(void) didStartPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID {
    NSLog(@"ATNativeSplashWrapper:: didStartPlayingVideoInAdView:placementID:%@", placementID);
}

-(void) didEndPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID {
    NSLog(@"ATNativeSplashWrapper:: didEndPlayingVideoInAdView:placementID:%@", placementID);
}

-(void) didClickNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID {
    NSLog(@"ATNativeSplashWrapper:: didClickNativeAdInAdView:placementID:%@", placementID);
    id<ATNativeSplashDelegate> delegate = [self delegateForPlacementID:placementID];
    if ([delegate respondsToSelector:@selector(didCloseNativeSplashAdForPlacementID:)]) {
        [delegate didClickNaitveSplashAdForPlacementID:placementID];
    }
}

- (void)didDeepLinkOrJumpInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra result:(BOOL)success {
    
    NSLog(@"ATNativeSplashWrapper:: didDeepLinkOrJumpInAdView:placementID:%@,extra:%@, result:%@", placementID, extra, success ? @"YES":@"NO");

    id<ATNativeSplashDelegate> delegate = [self delegateForPlacementID:placementID];
    if ([delegate respondsToSelector:@selector(didNativeSplashDeeplinkOrJumpForPlacementID:extra:result:)]) {
        [delegate didNativeSplashDeeplinkOrJumpForPlacementID:placementID extra:extra result:success];
    }
}

-(void) didShowNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID {
    NSLog(@"ATNativeSplashWrapper:: didShowNativeAdInAdView:placementID:%@", placementID);
    adView.mainImageView.image = adView.nativeAd.mainImage;
    NSTimeInterval interval = 5.0f;
    if ([objc_getAssociatedObject([ATNativeSplashWrapper sharedWrapper], (__bridge_retained void*)kATNativeSplashShowingExtraCountdownIntervalKey) integerValue] > .0f) {
        interval = [objc_getAssociatedObject([ATNativeSplashWrapper sharedWrapper], (__bridge_retained void*)kATNativeSplashShowingExtraCountdownIntervalKey) integerValue];
    }
    [[ATNativeSplashWrapper sharedWrapper] startCountdown:interval];
    id<ATNativeSplashDelegate> delegate = [self delegateForPlacementID:placementID];
    if ([delegate respondsToSelector:@selector(didShowNativeSplashAdForPlacementID:)]) {
        [delegate didShowNativeSplashAdForPlacementID:placementID];
    }
}

-(void) didFinishLoadingADWithPlacementID:(NSString *)placementID {
    NSLog(@"ATNativeSplashWrapper:: didFinishLoadingADWithPlacementID:%@", placementID);
    id<ATNativeSplashDelegate> delegate = [self delegateForPlacementID:placementID];
    if ([delegate respondsToSelector:@selector(finishLoadingNativeSplashAdForPlacementID:)]) { [delegate finishLoadingNativeSplashAdForPlacementID:placementID]; }

}

-(void) didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    NSLog(@"ATNativeSplashWrapper:: didFailToLoadADWithPlacementID:%@ error:%@", placementID, error);
    id<ATNativeSplashDelegate> delegate = [self delegateForPlacementID:placementID];
    if ([delegate respondsToSelector:@selector(failedToLoadNativeSplashAdForPlacementID:error:)]) { [delegate failedToLoadNativeSplashAdForPlacementID:placementID error:error]; }

}

#pragma mark - native delegate with networkID and adsouceID
-(void) didStartPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATNativeSplashWrapper:: didStartPlayingVideoInAdView:placementID:%@", placementID);
}

-(void) didEndPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATNativeSplashWrapper:: didEndPlayingVideoInAdView:placementID:%@", placementID);
}

-(void) didClickNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATNativeSplashWrapper:: didClickNativeAdInAdView:placementID:%@", placementID);
    id<ATNativeSplashDelegate> delegate = [self delegateForPlacementID:placementID];
    if ([delegate respondsToSelector:@selector(didCloseNativeSplashAdForPlacementID:)]) {
        [delegate didClickNaitveSplashAdForPlacementID:placementID];
    }
    if ([delegate respondsToSelector:@selector(didCloseNativeSplashAdForPlacementID:extra:)]) {
        [delegate didClickNaitveSplashAdForPlacementID:placementID extra:extra];
    }
}

-(void) didShowNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    NSLog(@"ATNativeSplashWrapper:: didShowNativeAdInAdView:placementID:%@", placementID);
    adView.mainImageView.image = adView.nativeAd.mainImage;
    if ([extra[kATNativeDelegateExtraNetworkIDKey] integerValue] == 2) {
        [adView sendSubviewToBack:adView.mediaView];
    }
    NSTimeInterval interval = 5.0f;
    _splashExtra = extra;
    if ([objc_getAssociatedObject([ATNativeSplashWrapper sharedWrapper], (__bridge_retained void*)kATNativeSplashShowingExtraCountdownIntervalKey) integerValue] > .0f) {
        interval = [objc_getAssociatedObject([ATNativeSplashWrapper sharedWrapper], (__bridge_retained void*)kATNativeSplashShowingExtraCountdownIntervalKey) integerValue];
    }
    [[ATNativeSplashWrapper sharedWrapper] startCountdown:interval];
    id<ATNativeSplashDelegate> delegate = [self delegateForPlacementID:placementID];
    if ([delegate respondsToSelector:@selector(didShowNativeSplashAdForPlacementID:)]) {
        [delegate didShowNativeSplashAdForPlacementID:placementID];
    }
    if ([delegate respondsToSelector:@selector(didShowNativeSplashAdForPlacementID:extra:)]) {
        [delegate didShowNativeSplashAdForPlacementID:placementID extra:extra];
    }
}

@end
