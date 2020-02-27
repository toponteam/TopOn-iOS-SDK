//
//  ATNativeBannerWrapper.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2019/4/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNativeBannerWrapper.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATNativeADView.h"
#import "ATNativeADConfiguration.h"
#import "ATAdManager+Internal.h"
#import "ATAdManager+Native.h"
#import "UIViewController+PresentationAndDismissalSwizzling.h"

NSString *const kATNativeBannerAdShowingExtraBackgroundColorKey = @"bckground_color";
NSString *const kATNativeBannerAdShowingExtraAdSizeKey = @"ad_size";
NSString *const kATNativeBannerAdShowingExtraAutorefreshIntervalKey = @"autorefresh_interval";
NSString *const kATNativeBannerAdShowingExtraHideCloseButtonFlagKey = @"hide_close_button_flag";
NSString *const kATNativeBannerAdShowingExtraCTAButtonBackgroundColorKey = @"cta_button_background_color";
NSString *const kATNativeBannerAdShowingExtraCTAButtonTitleFontKey = @"cta_button_title_font";
NSString *const kATNativeBannerAdShowingExtraCTAButtonTitleColorKey = @"cta_button_title_color";
NSString *const kATNativeBannerAdShowingExtraTitleFontKey = @"title_font";
NSString *const kATNativeBannerAdShowingExtraTitleColorKey = @"title_color";
NSString *const kATNativeBannerAdShowingExtraTextFontKey = @"text_font";
NSString *const kATNativeBannerAdShowingExtraTextColorKey = @"text_color";
NSString *const kATNativeBannerAdShowingExtraAdvertiserTextFontKey = @"sponsor_text_font";
NSString *const kATNativeBannerAdShowingExtraAdvertiserTextColorKey = @"spnosor_text_color";

extern NSString *const kNativeAdAutorefreshConfigurationSwitchKey;//BOOL wrapped in NSNumber
extern NSString *const kNativeAdAutorefreshConfigurationRefreshIntervalKey;//NSTimeInterval wrapped in NSNumber
@interface ATAdManager (BannerRefresh)
-(NSDictionary*) autoRefreshConfigurationForPlacementID:(NSString*)placementID;
@end

@interface ATNativeBannerWrapper(SemiInternal)
-(NSDictionary*)loadingExtraForPlacementID:(NSString*)placementID;
-(void) setNativeBannerView:(ATNativeBannerView*)bannerView forPlacementID:(NSString*)placementID;
-(void) removeNativeBannerViewWithPlacementID:(NSString*)placementID;
-(void) setShowingExtra:(NSDictionary*)extra forPlacementID:(NSString*)placementID;
-(void) removeShowingExtraForPlacementID:(NSString*)placementID;
-(NSDictionary*)showingExtraForPlacementID:(NSString*)placementID;
@end

#pragma mark - rating view
@interface ATStarRatingView:UIView
@property(nonatomic, readonly) UIImageView *star0;
@property(nonatomic, readonly) UIImageView *star1;
@property(nonatomic, readonly) UIImageView *star2;
@property(nonatomic, readonly) UIImageView *star3;
@property(nonatomic, readonly) UIImageView *star4;
@end
static CGFloat kStarDimension = 12.0f;
@implementation ATStarRatingView
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
    [self internal_addConstraintsWithVisualFormat:@"|[_star0(width)]-10-[_star1(width)]-10-[_star2(width)]-10-[_star3(width)]-10-[_star4(width)]" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:@{@"width":@(kStarDimension)} views:NSDictionaryOfVariableBindings(_star0, _star1, _star2, _star3, _star4)];
    [self internal_addConstraintsWithVisualFormat:@"V:|[_star0(width)]|" options:0 metrics:@{@"width":@(kStarDimension)} views:NSDictionaryOfVariableBindings(_star0, _star1, _star2, _star3, _star4)];
}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(kStarDimension * 5.0f + 10.0f * 4.0f, kStarDimension);
}

+(void) configureStarView:(ATStarRatingView*)starView star:(CGFloat)star {
    if (starView.star0 != nil && starView.star1 != nil && starView.star2 != nil && starView.star3 != nil && starView.star4 != nil) {
        NSArray<UIImageView*>* stars = @[starView.star0, starView.star1, starView.star2, starView.star3, starView.star4];
        NSInteger consumedStar = 0;
        CGFloat remainStar = star;
        while (consumedStar < 5) {
            stars[consumedStar++].image = [UIImage anythink_imageWithName:remainStar >= 1.0f ? @"native_banner_star_on" : remainStar > .0f ? @"native_banner_semi_star" : @"native_banner_star_off"];
            remainStar -= remainStar > 1.0f ? 1.0f : remainStar > .0f ? remainStar : .0f;
        }
    }
}
@end

@interface ATNativeBannerInternalNativeView:ATNativeADView
@property(nonatomic, readonly) ATStarRatingView *starRatingView;
@property(nonatomic, readonly) UILabel *advertiserLabel;
@property(nonatomic, readonly) UILabel *textLabel;
@property(nonatomic, readonly) UILabel *titleLabel;
@property(nonatomic, readonly) UILabel *ctaLabel;
@property(nonatomic, readonly) UILabel *ratingLabel;
@property(nonatomic, readonly) UIImageView *iconImageView;
@property(nonatomic, readonly) UIImageView *mainImageView;
@property(nonatomic, readonly) UIImageView *sponsorImageView;
@end
@implementation ATNativeBannerInternalNativeView
-(void) initSubviews {
    [super initSubviews];
    _iconImageView = [UIImageView internal_autolayoutView];
    _iconImageView.layer.cornerRadius = 4.0f;
    _iconImageView.layer.masksToBounds = YES;
    [self addSubview:_iconImageView];
    
    _titleLabel = [UILabel internal_autolayoutLabelFont:[UIFont boldSystemFontOfSize:13.0f] textColor:[UIColor blackColor]];
    [self addSubview:_titleLabel];
    
    _textLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:12.0f] textColor:[UIColor blackColor]];
    [self addSubview:_textLabel];
    
    _starRatingView = [ATStarRatingView internal_autolayoutView];
    [self addSubview:_starRatingView];
    _starRatingView.hidden = YES;
    
    _ctaLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:12.0f] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter];
    _ctaLabel.backgroundColor = [UIColor colorWithRed:234.0f / 255.0f green:64.0f / 255.0f blue:72.0f / 255.0f alpha:1.0f];
    _ctaLabel.layer.masksToBounds = YES;
    [self addSubview:_ctaLabel];
    
    _advertiserLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:8.0f] textColor:[UIColor blackColor]];
    _advertiserLabel.text = @"Sponsored";
    [self addSubview:_advertiserLabel];
    
    _mainImageView = [UIImageView internal_autolayoutView];
    _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_mainImageView];
}

-(NSArray<UIView*>*)clickableViews {
    NSMutableArray<UIView*> *clickableViews = [NSMutableArray<UIView*> arrayWithObjects:_iconImageView, _titleLabel, _textLabel, _ctaLabel, _advertiserLabel, _mainImageView, nil];
    if (self.mediaView != nil) { [clickableViews addObject:self.mediaView]; }
    return clickableViews;
}

-(void) makeConstraintsForSubviews {
    [super makeConstraintsForSubviews];
    UIView *hAnchoringView = self.nativeAd.mainImage != nil ? _mainImageView : _iconImageView;
    _iconImageView.hidden = self.nativeAd.mainImage != nil;
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(hAnchoringView, _iconImageView, _mainImageView, _titleLabel, _textLabel, _ctaLabel, _starRatingView, _advertiserLabel);
    [self internal_addConstraintsWithVisualFormat:@"|[_mainImageView(width)]" options:0 metrics:@{@"width":@(CGRectGetHeight(self.bounds) * 8.0f / 5.0f)} views:viewsDict];
    [self internal_addConstraintsWithVisualFormat:@"V:|[_mainImageView]|" options:0 metrics:nil views:viewsDict];
    [self internal_addConstraintWithItem:_mainImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
    [self internal_addConstraintsWithVisualFormat:@"|-15-[_iconImageView]" options:0 metrics:nil views:viewsDict];
    [self internal_addConstraintsWithVisualFormat:@"V:|-5-[_iconImageView]-5-|" options:0 metrics:nil views:viewsDict];
    [self internal_addConstraintWithItem:_iconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_iconImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:.0f];
    
    [self internal_addConstraintsWithVisualFormat:@"[_titleLabel]->=5-[_ctaLabel(76)]-22-|" options:0 metrics:nil views:viewsDict];
    [self internal_addConstraintsWithVisualFormat:@"V:[_ctaLabel(28)]" options:0 metrics:nil views:viewsDict];
    [self internal_addConstraintWithItem:_ctaLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
    _ctaLabel.layer.cornerRadius = 14.0f;
    _ctaLabel.hidden = [self.nativeAd.ctaText length] == 0;
    [self internal_addConstraintsWithVisualFormat:@"[hAnchoringView]-15-[_textLabel]" options:0 metrics:nil views:viewsDict];
    [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_titleLabel]" options:0 metrics:nil views:viewsDict];
    [self internal_addConstraintsWithVisualFormat:[NSString stringWithFormat:@"[_textLabel]-spacing-%@", [self.nativeAd.ctaText length] > 0 ? @"[_ctaLabel]" : @"|"] options:0 metrics:@{@"spacing":@([self.nativeAd.ctaText length] > 0 ? 5.0f : 22.0f)} views:viewsDict];
    [self internal_addConstraintsWithVisualFormat:@"[_advertiserLabel]->=5-[_ctaLabel]" options:0 metrics:nil views:viewsDict];
    
    NSMutableArray<UIView*> *vViews = [NSMutableArray arrayWithObjects:_textLabel, nil];
    if ([self.nativeAd.advertiser length] > 0) { [vViews addObject:_advertiserLabel]; }
    __block UIView *anchoringView = _titleLabel;
    [vViews enumerateObjectsUsingBlock:^(UIView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self internal_addConstraintsWithVisualFormat:@"V:[anchoringView]-5-[obj]" options:NSLayoutFormatAlignAllLeading metrics:0 views:NSDictionaryOfVariableBindings(anchoringView, obj)];
        anchoringView = obj;
    }];
}

-(void) layoutMediaView {
    if (self.mediaView != nil && self.mainImageView != nil) {
        self.mediaView.translatesAutoresizingMaskIntoConstraints = NO;
        [self internal_addConstraintWithItem:self.mediaView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.mainImageView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
        [self internal_addConstraintWithItem:self.mediaView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.mainImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        [self internal_addConstraintWithItem:self.mediaView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.mainImageView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:.0f];
        [self internal_addConstraintWithItem:self.mediaView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mainImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:.0f];
    }
}

+(void) configureAdView:(ATNativeBannerInternalNativeView*)adView withExtra:(NSDictionary*)extra {
    if ([extra isKindOfClass:[NSDictionary class]]) {
        if ([extra[kATNativeBannerAdShowingExtraCTAButtonBackgroundColorKey] isKindOfClass:[UIColor class]]) {
            [adView embededAdView].ctaLabel.backgroundColor = extra[kATNativeBannerAdShowingExtraCTAButtonBackgroundColorKey];
        }
        if ([extra[kATNativeBannerAdShowingExtraCTAButtonTitleColorKey] isKindOfClass:[UIColor class]]) {
            [adView embededAdView].ctaLabel.textColor = extra[kATNativeBannerAdShowingExtraCTAButtonTitleColorKey];
        }
        if ([extra[kATNativeBannerAdShowingExtraCTAButtonTitleFontKey] isKindOfClass:[UIFont class]]) {
            [adView embededAdView].ctaLabel.font = extra[kATNativeBannerAdShowingExtraCTAButtonTitleFontKey];
        }
        
        if ([extra[kATNativeBannerAdShowingExtraTitleFontKey] isKindOfClass:[UIFont class]]) {
            [adView embededAdView].titleLabel.font = extra[kATNativeBannerAdShowingExtraTitleFontKey];
        }
        if ([extra[kATNativeBannerAdShowingExtraTitleColorKey] isKindOfClass:[UIColor class]]) {
            [adView embededAdView].titleLabel.textColor = extra[kATNativeBannerAdShowingExtraTitleColorKey];
        }
        
        if ([extra[kATNativeBannerAdShowingExtraTextFontKey] isKindOfClass:[UIFont class]]) {
            [adView embededAdView].textLabel.font = extra[kATNativeBannerAdShowingExtraTextFontKey];
        }
        if ([extra[kATNativeBannerAdShowingExtraTextColorKey] isKindOfClass:[UIColor class]]) {
            [adView embededAdView].textLabel.textColor = extra[kATNativeBannerAdShowingExtraTextColorKey];
        }
        
        if ([extra[kATNativeBannerAdShowingExtraAdvertiserTextFontKey] isKindOfClass:[UIFont class]]) {
            [adView embededAdView].advertiserLabel.font = extra[kATNativeBannerAdShowingExtraAdvertiserTextFontKey];
        }
        if ([extra[kATNativeBannerAdShowingExtraAdvertiserTextColorKey] isKindOfClass:[UIColor class]]) {
            [adView embededAdView].advertiserLabel.textColor = extra[kATNativeBannerAdShowingExtraAdvertiserTextColorKey];
        }
    }
}
@end

@interface ATNativeBannerView()<ATNativeADDelegate>
@property(nonatomic, readonly) NSString *placementID;
@property(nonatomic) ATNativeBannerInternalNativeView *internalNativeAdView;
@property(nonatomic) NSTimeInterval autoRefreshInterval;
@property(atomic) BOOL shouldNotifyShow;
@end
@implementation ATNativeBannerView
-(NSString*)description {
    return [NSString stringWithFormat:@"ATNativeBannerView:: placement_%@", _placementID];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) removeFromSuperview {
    [self cancelScheduledLoad];
    [[ATNativeBannerWrapper sharedWrapper] removeNativeBannerViewWithPlacementID:_placementID];
    [super removeFromSuperview];
}

-(void) willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow != nil) {
        [[ATNativeBannerWrapper sharedWrapper] setNativeBannerView:self forPlacementID:_placementID];
        if (self.superview != nil) {
            [self scheduleNextLoad];
        }
    } else {
        [[ATNativeBannerWrapper sharedWrapper] removeNativeBannerViewWithPlacementID:_placementID];
        [self cancelScheduledLoad];
    }
}

-(void) handleApplicationDidBecomeActiveNotification:(NSNotification*)notification {
    [self scheduleNextLoad];
}

-(void) handleApplicationWillResignActiveNotification:(NSNotification*)notification {
    [self cancelScheduledLoad];
}

-(instancetype) initWithFrame:(CGRect)frame delegate:(id<ATNativeBannerDelegate>)delegate placementID:(NSString*)placementID {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.clipsToBounds = YES;
        _delegate = delegate;
        _placementID = placementID;
        _shouldNotifyShow = YES;
        [self configureAccessoryViews];
        [self attachNewInternalNativeAdView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        NSDictionary *extra = [[ATNativeBannerWrapper sharedWrapper] showingExtraForPlacementID:_placementID];
        if ([extra[kATNativeBannerAdShowingExtraBackgroundColorKey] isKindOfClass:[UIColor class]]) { self.backgroundColor = extra[kATNativeBannerAdShowingExtraBackgroundColorKey]; }
    }
    return self;
}

-(void) configureAccessoryViews {
    if (![[[ATNativeBannerWrapper sharedWrapper] showingExtraForPlacementID:_placementID][kATNativeBannerAdShowingExtraHideCloseButtonFlagKey] boolValue]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        button.frame = CGRectMake(CGRectGetWidth(self.bounds) - 17.0f, 3.0f, 14.0f, 14.0f);
        [button setImage:[UIImage anythink_imageWithName:@"native_banner_close"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(.0f, .0f, 24.0f, 11.0f)];
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    label.text = @"AD";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:8];
    label.layer.cornerRadius = 2.0f;
    [self addSubview:label];
}

-(void) closeButtonTapped {
    if ([_delegate respondsToSelector:@selector(didClickCloseButtonInNativeBannerAdView:placementID:)]) { [_delegate didClickCloseButtonInNativeBannerAdView:self placementID:_placementID]; }
}

-(void) attachNewInternalNativeAdView {
    ATNativeADConfiguration *config = [[ATNativeADConfiguration alloc] init];
    config.ADFrame = self.bounds;
    config.delegate = self;
    config.renderingViewClass = [ATNativeBannerInternalNativeView class];
    config.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    ATNativeBannerInternalNativeView *nativeAdView = [[ATAdManager sharedManager] retriveAdViewWithPlacementID:_placementID configuration:config];
    if (nativeAdView != nil) {
        [ATNativeBannerInternalNativeView configureAdView:nativeAdView withExtra:[[ATNativeBannerWrapper sharedWrapper] showingExtraForPlacementID:_placementID]];
        self.internalNativeAdView = nativeAdView;
    }
}

-(void) setInternalNativeAdView:(ATNativeBannerInternalNativeView *)internalNativeAdView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_internalNativeAdView removeFromSuperview];
        _internalNativeAdView = internalNativeAdView;
        [self insertSubview:_internalNativeAdView atIndex:0];
        [self scheduleNextLoad];
    });
}

-(void) cancelScheduledLoad {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadNext) object:nil];
    });
}

-(void) scheduleNextLoad {
    if (_autoRefreshInterval > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadNext) object:nil];
            [self performSelector:@selector(loadNext) withObject:nil afterDelay:_autoRefreshInterval];
        });
    }
}

-(void) loadNext {
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:[[ATNativeBannerWrapper sharedWrapper] loadingExtraForPlacementID:_placementID]];
    if (extra == nil) {
        extra = [NSMutableDictionary dictionaryWithObject:@YES forKey:kAdLoadingExtraRefreshFlagKey];
    } else {
        extra[kAdLoadingExtraRefreshFlagKey] = @YES;
    }
    [[ATAdManager sharedManager] loadADWithPlacementID:_placementID extra:extra delegate:self];
}

#pragma mark - ad loading delegate
-(void) didFinishLoadingADWithPlacementID:(NSString *)placementID {
    if (self.superview != nil) { [self attachNewInternalNativeAdView]; }
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID error:(NSError*)error {
    if ([_delegate respondsToSelector:@selector(didFailToAutorefreshNativeBannerAdInView:placementID:error:)]) { [_delegate didFailToAutorefreshNativeBannerAdInView:self placementID:placementID error:error]; }
    [self scheduleNextLoad];
}

-(void) didStartPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID {
}

-(void) didEndPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID {
}

-(void) didClickNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID {
    if ([_delegate respondsToSelector:@selector(didClickNativeBannerAdInView:placementID:)]) { [_delegate didClickNativeBannerAdInView:self placementID:placementID]; }
}

-(void) didShowNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID {
    adView.mainImageView.image = adView.nativeAd.mainImage;
    if (self.shouldNotifyShow) {
        if ([_delegate respondsToSelector:@selector(didShowNativeBannerAdInView:placementID:)]) {
            self.shouldNotifyShow = NO;
            [_delegate didShowNativeBannerAdInView:self placementID:placementID];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(didAutorefreshNativeBannerAdInView:placementID:)]) { [_delegate didAutorefreshNativeBannerAdInView:self placementID:placementID]; }
    }
}
#pragma mark - ad loading delegate with networkID and adsouceID
-(void) didStartPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
}

-(void) didEndPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
}
-(void) didClickNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    if ([_delegate respondsToSelector:@selector(didClickNativeBannerAdInView:placementID:)]) { [_delegate didClickNativeBannerAdInView:self placementID:placementID]; }
    if ([_delegate respondsToSelector:@selector(didClickNativeBannerAdInView:placementID: extra:)]) { [_delegate didClickNativeBannerAdInView:self placementID:placementID extra:extra]; }
}

-(void) didShowNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    adView.mainImageView.image = adView.nativeAd.mainImage;
    if (self.shouldNotifyShow) {
        if ([_delegate respondsToSelector:@selector(didShowNativeBannerAdInView:placementID: extra:)]) {
            self.shouldNotifyShow = NO;
            [_delegate didShowNativeBannerAdInView:self placementID:placementID extra:extra];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(didAutorefreshNativeBannerAdInView:placementID:extra:)]) { [_delegate didAutorefreshNativeBannerAdInView:self placementID:placementID extra:extra]; }
    }
}

@end

@interface ATNativeBannerWrapper()<ATAdLoadingDelegate>
@property(nonatomic, readonly) NSMutableDictionary *delegates;
@property(nonatomic, readonly) dispatch_queue_t delegates_accessing_queue;
@property(nonatomic, readonly) NSMutableDictionary *banners;
@property(nonatomic, readonly) dispatch_queue_t banners_accessing_queue;
@property(nonatomic, readonly) NSMutableDictionary *loadingExtras;
@property(nonatomic, readonly) dispatch_queue_t loadingExtras_accessing_control_queue;
@property(nonatomic, readonly) NSMutableDictionary *showingExtras;
@property(nonatomic, readonly) dispatch_queue_t showing_extra_accessing_control_queue;
@end
@implementation ATNativeBannerWrapper
+(instancetype) sharedWrapper {
    static ATNativeBannerWrapper *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATNativeBannerWrapper alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        [UIViewController swizzleMethods];
        [[NSNotificationCenter defaultCenter] addObserverForName:kATUIViewControllerPresentationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) { [_banners enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) { [((ATNativeBannerView*)obj) cancelScheduledLoad]; }]; }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kATUIViewControllerDismissalNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) { [_banners enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) { [((ATNativeBannerView*)obj) scheduleNextLoad]; }]; }];
        
        _delegates = [NSMutableDictionary new];
        _delegates_accessing_queue = dispatch_queue_create("com.anythink.delegateAccessingControlQueue", DISPATCH_QUEUE_CONCURRENT);
        
        _banners = [NSMutableDictionary new];
        _banners_accessing_queue = dispatch_queue_create("com.anythink.bannersAccessingControlQueue", DISPATCH_QUEUE_CONCURRENT);;
        
        _loadingExtras = [NSMutableDictionary dictionary];
        _loadingExtras_accessing_control_queue = dispatch_queue_create("com.anythink.NativeBannerLoadingExtra", DISPATCH_QUEUE_CONCURRENT);
        
        _showingExtras = [NSMutableDictionary dictionary];
        _showing_extra_accessing_control_queue = dispatch_queue_create("com.anythink.NativeBannerShowingExtra", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(void) setShowingExtra:(NSDictionary*)extra forPlacementID:(NSString*)placementID {
    dispatch_barrier_async(_showing_extra_accessing_control_queue, ^{
        [_showingExtras removeObjectForKey:placementID];
        if ([extra count] > 0) { _showingExtras[placementID] = extra; }
    });
    
}

-(void) removeShowingExtraForPlacementID:(NSString*)placementID {
    dispatch_barrier_async(_showing_extra_accessing_control_queue, ^{
        [_showingExtras removeObjectForKey:placementID];
    });
}

-(NSDictionary*)showingExtraForPlacementID:(NSString*)placementID {
    __block NSDictionary *extra = nil;
    dispatch_sync(_showing_extra_accessing_control_queue, ^{
        extra = _showingExtras[placementID];
    });
    return extra;
}

-(void) removeNativeBannerViewWithPlacementID:(NSString*)placementID {
    dispatch_barrier_async(_banners_accessing_queue, ^{
        [_banners removeObjectForKey:placementID];
    });
}

-(void) setNativeBannerView:(ATNativeBannerView*)bannerView forPlacementID:(NSString*)placementID {
    dispatch_barrier_async(_banners_accessing_queue, ^{
        _banners[placementID] = bannerView;
    });
}

-(ATNativeBannerView*)nativeBannerViewForPlacementID:(NSString*)placementID {
    __block ATNativeBannerView *bannerView = nil;
    dispatch_sync(_banners_accessing_queue, ^{
        bannerView = _banners[placementID];
    });
    return bannerView;
}

-(void) setDelegate:(id<ATNativeBannerDelegate>)delegate forPlacementID:(NSString*)placementID {
    dispatch_barrier_async(_delegates_accessing_queue, ^{
        _delegates[placementID] = delegate;
    });
}

-(void) removeDelegateForPlacementID:(NSString*)placementID {
    dispatch_barrier_async(_delegates_accessing_queue, ^{
        [_delegates removeObjectForKey:placementID];
    });
}

-(id<ATNativeBannerDelegate>)delegateForPlacementID:(NSString*)placementID {
    __block id<ATNativeBannerDelegate> delegate = nil;
    dispatch_sync(_delegates_accessing_queue, ^{
        delegate = _delegates[placementID];
    });
    return delegate;
}

-(void) setLoadingExtra:(NSDictionary*)extra forPlacementID:(NSString*)placementID {
    dispatch_barrier_async(_loadingExtras_accessing_control_queue, ^{
        _loadingExtras[placementID] = extra;
    });
}

-(NSDictionary*)loadingExtraForPlacementID:(NSString*)placementID {
    __block NSDictionary *extra = nil;
    dispatch_sync(_loadingExtras_accessing_control_queue, ^{
        extra = _loadingExtras[placementID];
    });
    return extra;
}

+(void) loadNativeBannerAdWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATNativeBannerDelegate>)delegate {
    NSMutableDictionary *localExtra = [NSMutableDictionary dictionaryWithDictionary:@{kExtraInfoNativeAdTypeKey:@(ATGDTNativeAdTypeSelfRendering), kATExtraNativeImageSizeKey:kATExtraNativeImageSize690_388}];
    if ([extra isKindOfClass:[NSDictionary class]] && [extra count] > 0) { [localExtra addEntriesFromDictionary:extra]; }
    [[ATNativeBannerWrapper sharedWrapper] setLoadingExtra:localExtra forPlacementID:placementID];
    [[ATNativeBannerWrapper sharedWrapper] setDelegate:delegate forPlacementID:placementID];
    [[[ATNativeBannerWrapper sharedWrapper] nativeBannerViewForPlacementID:placementID] cancelScheduledLoad];
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:localExtra delegate:[ATNativeBannerWrapper sharedWrapper]];
}

+(ATNativeBannerView*) retrieveNativeBannerAdViewWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra delegate:(id<ATNativeBannerDelegate>)delegate {
    if ([self nativeBannerAdReadyForPlacementID:placementID]) {
        NSMutableDictionary *extraToBeSaved = [NSMutableDictionary dictionaryWithDictionary:extra];
        if (extraToBeSaved[kATNativeBannerAdShowingExtraAutorefreshIntervalKey] == nil) {
            NSDictionary *placementConfig = [[ATAdManager sharedManager] autoRefreshConfigurationForPlacementID:placementID];
            if ([placementConfig[kNativeAdAutorefreshConfigurationSwitchKey] boolValue] && [placementConfig[kNativeAdAutorefreshConfigurationRefreshIntervalKey] doubleValue] > 0) {
                extraToBeSaved[kATNativeBannerAdShowingExtraAutorefreshIntervalKey] = placementConfig[kNativeAdAutorefreshConfigurationRefreshIntervalKey];
            }
        }
        [[ATNativeBannerWrapper sharedWrapper] setShowingExtra:extraToBeSaved forPlacementID:placementID];
        CGSize size = extraToBeSaved[kATNativeBannerAdShowingExtraAdSizeKey] != nil ? [extraToBeSaved[kATNativeBannerAdShowingExtraAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 80.0f);
        ATNativeBannerView *bannerView = [[ATNativeBannerView alloc] initWithFrame:CGRectMake(.0f, .0f, size.width, size.height) delegate:delegate placementID:placementID];
        if ([extraToBeSaved[kATNativeBannerAdShowingExtraAutorefreshIntervalKey] respondsToSelector:@selector(doubleValue)] && [extraToBeSaved[kATNativeBannerAdShowingExtraAutorefreshIntervalKey] doubleValue] > 0) {
            bannerView.autoRefreshInterval = [extraToBeSaved[kATNativeBannerAdShowingExtraAutorefreshIntervalKey] doubleValue];
        }
        [[ATNativeBannerWrapper sharedWrapper].banners setObject:bannerView forKey:placementID];
        return bannerView;
    } else {
        return nil;
    }
}

+(BOOL) nativeBannerAdReadyForPlacementID:(NSString*)placementID {
    return [[ATAdManager sharedManager] nativeAdReadyForPlacementID:placementID];
}

#pragma mark - native delegate(s)
-(void) didFinishLoadingADWithPlacementID:(NSString *)placementID {
    ATNativeBannerView *bannerView = [self nativeBannerViewForPlacementID:placementID];
    bannerView.shouldNotifyShow = YES;
    [bannerView attachNewInternalNativeAdView];
    
    if (bannerView == nil) {
        id<ATNativeBannerDelegate> delegate = [self delegateForPlacementID:placementID];
        if ([delegate respondsToSelector:@selector(didFinishLoadingNativeBannerAdWithPlacementID:)]) { [delegate didFinishLoadingNativeBannerAdWithPlacementID:placementID]; }

    }
    [self removeDelegateForPlacementID:placementID];
    
}

-(void) didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    id<ATNativeBannerDelegate> delegate = [self delegateForPlacementID:placementID];
    if ([delegate respondsToSelector:@selector(didFailToLoadNativeBannerAdWithPlacementID:error:)]) { [delegate didFailToLoadNativeBannerAdWithPlacementID:placementID error:error]; }

    [self removeDelegateForPlacementID:placementID];
}
@end
