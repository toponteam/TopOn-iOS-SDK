//
//  ATOfferBannerView.m
//  AnyThinkSDK
//
//  Created by Topon on 10/28/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOfferBannerView.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATOfferResourceManager.h"
#import "UIViewController+PresentationAndDismissalSwizzling.h"
#import "ATOnlineApiTracker.h"
#import "ATAPI+Internal.h"

@interface ATOfferBannerView()
@property(nonatomic, readonly) UILabel *textLabel;
@property(nonatomic, readonly) UILabel *titleLabel;
@property(nonatomic, readonly) UILabel *ctaLabel;
@property(nonatomic, readonly) UIImageView *iconImageView;
@property(nonatomic, readonly) UIImageView *mainImageView;
@property(nonatomic, readonly) UIImageView *sponsorImageView;
@property(nonatomic, readonly) UIImageView *homeImageView;
@property(nonatomic, readonly) UIImageView *backgroundImageView;
@property(nonatomic, readonly) UIVisualEffectView *blurView;
@property(nonatomic, readonly) UILabel *adNoteLabel;

@property (nonatomic , strong) ATOfferModel *offerModel;
@property (nonatomic) ATOfferSetting *setting;
@property (nonatomic) BOOL hasSendImpression;

@property (nonatomic) CGPoint touchStartPoint;
@end
@implementation ATOfferBannerView

-(instancetype) initWithFrame:(CGRect)frame offerModel:(ATOfferModel*)offerModel setting:(ATOfferSetting*)setting {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.clipsToBounds = YES;
        _offerModel = offerModel;
        _setting = setting;
        _hasSendImpression = NO;
    }
    return self;
}

-(void) initOfferBannerView {
    [self initSubviews];
    [self makeConstraintsForSubviews];
    [self initBannerResourceWithOfferModel:_offerModel];
    [self setClickAction];
}

-(void) initSubviews {
    self.backgroundColor = [UIColor whiteColor];
    _backgroundImageView = [UIImageView internal_autolayoutView];
    [self addSubview:_backgroundImageView];
    
    _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_blurView];
    
    _sponsorImageView = [UIImageView internal_autolayoutView];
    [self addSubview:_sponsorImageView];
    
    _homeImageView = [UIImageView internal_autolayoutView];
    _homeImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _iconImageView = [UIImageView internal_autolayoutView];
    _iconImageView.layer.cornerRadius = 4.0f;
    _iconImageView.layer.masksToBounds = YES;
    
    _titleLabel = [UILabel internal_autolayoutLabelFont:[UIFont boldSystemFontOfSize:13.0f] textColor:[UIColor blackColor]];
    
    _textLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:12.0f] textColor:[UIColor blackColor]];
    
    _ctaLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:12.0f] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter];
    _ctaLabel.backgroundColor = [UIColor colorWithRed:234.0f / 255.0f green:64.0f / 255.0f blue:72.0f / 255.0f alpha:1.0f];
    _ctaLabel.layer.masksToBounds = YES;
    _ctaLabel.layer.cornerRadius = 2;
    
    _mainImageView = [UIImageView internal_autolayoutView];
    _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (_offerModel.crtType == ATOfferCrtTypeOneImage) {
        [self addSubview:_homeImageView];
    }else {
        [self addSubview:_homeImageView];
        [self addSubview:_iconImageView];
        [self addSubview:_titleLabel];
        [self addSubview:_textLabel];
        [self addSubview:_ctaLabel];
        [self addSubview:_mainImageView];
    }
    
    CGFloat radius = 4.0f;
    
    _adNoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 40.0f, 20.0f)];
    _adNoteLabel.textColor = [UIColor whiteColor];
    _adNoteLabel.textAlignment = NSTextAlignmentCenter;
    _adNoteLabel.font = [UIFont systemFontOfSize:6.0f];
    _adNoteLabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.3f];
    _adNoteLabel.layer.cornerRadius = radius;
    _adNoteLabel.layer.masksToBounds = YES;
    _adNoteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _adNoteLabel.text = @"AD";
    _adNoteLabel.hidden = [ATAPI adLogoVisible];
    [self addSubview:_adNoteLabel];
}

-(void) makeConstraintsForSubviews {
    //constraintsfor diferent size
    NSDictionary *viewsDict = nil;
    if(self.offerModel.crtType == ATOfferCrtTypeOneImage){
        viewsDict = NSDictionaryOfVariableBindings(_homeImageView, _sponsorImageView, _adNoteLabel,_backgroundImageView,_blurView);
        [self internal_addConstraintsWithVisualFormat:@"|[_homeImageView]|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|[_homeImageView]|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"|[_backgroundImageView]|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|[_backgroundImageView]|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"|[_blurView]|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|[_blurView]|" options:0 metrics:nil views:viewsDict];
        _iconImageView.hidden = YES;
        _titleLabel.hidden = YES;
        _textLabel.hidden = YES;
        _ctaLabel.hidden = YES;
        _mainImageView.hidden = YES;
    }else{
        _homeImageView.hidden = YES;
        _backgroundImageView.hidden = YES;
        _blurView.hidden = YES;
        BOOL hideCta = [Utilities isEmpty:self.offerModel.CTA];
        if([_setting.bannerSize isEqualToString:kATOfferBannerSize320_50]){
            _mainImageView.hidden = YES;
            viewsDict = NSDictionaryOfVariableBindings(_iconImageView, _titleLabel, _textLabel, _ctaLabel, _sponsorImageView, _adNoteLabel);
            [self internal_addConstraintsWithVisualFormat:@"H:|-10-[_iconImageView(38)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-6-[_iconImageView(38)]-6-|" options:0 metrics:nil views:viewsDict];
            
//            NSString *titleLayout_h = hideCta ? @"H:|-50-[_titleLabel]-15-|" : @"H:|-50-[_titleLabel]-100-|";
//            NSString *textLayout_h = hideCta ? @"H:|-50-[_textLabel]-15-|" : @"H:|-50-[_textLabel]-100-|";
//            [self internal_addConstraintsWithVisualFormat:titleLayout_h options:0 metrics:nil views:viewsDict];
//            [self internal_addConstraintsWithVisualFormat:textLayout_h options:0 metrics:nil views:viewsDict];
            [self layoutLabelWithOffsetX:50];
            [self internal_addConstraintsWithVisualFormat:@"V:|-7-[_titleLabel]-8-[_textLabel]-7-|" options:0 metrics:nil views:viewsDict];
            
            NSString *layoutFormatter = hideCta ? @"H:[_ctaLabel(0)]-0-|" : @"H:[_ctaLabel(80)]-20-|";
            [self internal_addConstraintsWithVisualFormat:layoutFormatter options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_ctaLabel(30)]-10-|" options:0 metrics:nil views:viewsDict];
            
        }else if([_setting.bannerSize isEqualToString:kATOfferBannerSize320_90]){
            viewsDict = NSDictionaryOfVariableBindings(_mainImageView, _iconImageView, _titleLabel, _textLabel, _ctaLabel, _sponsorImageView, _adNoteLabel);
            [self internal_addConstraintsWithVisualFormat:@"H:|-10-[_mainImageView(128)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-8-[_mainImageView(72)]-8-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-148-[_iconImageView(34)]" options:0 metrics:nil views:viewsDict];
            NSString *icon_v = hideCta ? @"V:|-25-[_iconImageView(34)]" : @"V:|-8-[_iconImageView(34)]";
            [self internal_addConstraintsWithVisualFormat:icon_v options:0 metrics:nil views:viewsDict];

            NSString *formatter_v = hideCta ? @"V:|-25-[_titleLabel]-8-[_textLabel]-25-|" : @"V:|-8-[_titleLabel]-8-[_textLabel]-43-|";
//            [self internal_addConstraintsWithVisualFormat:@"H:|-190-[_titleLabel]-10-|" options:0 metrics:nil views:viewsDict];
//            [self internal_addConstraintsWithVisualFormat:@"H:|-190-[_textLabel]-10-|" options:0 metrics:nil views:viewsDict];
            [self layoutLabelWithOffsetX:190];
            [self internal_addConstraintsWithVisualFormat:formatter_v options:0 metrics:nil views:viewsDict];
            
            NSString *layoutFormatter = hideCta ? @"H:[_ctaLabel(0)]-0-|" : @"H:[_ctaLabel(160)]-10-|";
            [self internal_addConstraintsWithVisualFormat:layoutFormatter options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:[_ctaLabel(24)]-17-|" options:0 metrics:nil views:viewsDict];
            
        }else if([_setting.bannerSize isEqualToString:kATOfferBannerSize300_250]){
            viewsDict = NSDictionaryOfVariableBindings(_mainImageView, _iconImageView, _titleLabel, _textLabel, _ctaLabel, _sponsorImageView, _adNoteLabel);
            [self internal_addConstraintsWithVisualFormat:@"H:|-10-[_mainImageView(280)]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_mainImageView(155)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-8-[_iconImageView(34)]" options:0 metrics:nil views:viewsDict];
            NSString *icon_v = hideCta ? @"V:|-191-[_iconImageView(34)]" : @"V:|-170-[_iconImageView(34)]";

            [self internal_addConstraintsWithVisualFormat:icon_v options:0 metrics:nil views:viewsDict];
            
            NSString *formatter_v = hideCta ? @"V:|-191-[_titleLabel]-8-[_textLabel]-22-|" : @"V:|-170-[_titleLabel]-8-[_textLabel]-43-|";

//            [self internal_addConstraintsWithVisualFormat:@"H:|-50-[_titleLabel]-10-|" options:0 metrics:nil views:viewsDict];
//            [self internal_addConstraintsWithVisualFormat:@"H:|-50-[_textLabel]-10-|" options:0 metrics:nil views:viewsDict];
            [self layoutLabelWithOffsetX:50];
            [self internal_addConstraintsWithVisualFormat:formatter_v options:0 metrics:nil views:viewsDict];
            
            NSString *layoutFormatter = hideCta ? @"H:|-10-[_ctaLabel(0)]-0-|" : @"H:|-10-[_ctaLabel(280)]-10-|";
            [self internal_addConstraintsWithVisualFormat:layoutFormatter options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:[_ctaLabel(24)]-16-|" options:0 metrics:nil views:viewsDict];
        }else if([_setting.bannerSize isEqualToString:kATOfferBannerSize728_90]){
            //728*90
            viewsDict = NSDictionaryOfVariableBindings(_mainImageView, _iconImageView, _titleLabel, _textLabel, _ctaLabel, _sponsorImageView, _adNoteLabel);
            [self internal_addConstraintsWithVisualFormat:@"H:|-22-[_mainImageView(128)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_mainImageView(72)]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-175-[_iconImageView(72)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_iconImageView(72)]-10-|" options:0 metrics:nil views:viewsDict];
            
//            NSString *titleLayout_h = hideCta ? @"H:|-255-[_titleLabel]-15-|" : @"H:|-255-[_titleLabel]-180-|";
//            NSString *textLayout_h = hideCta ? @"H:|-255-[_textLabel]-15-|" : @"H:|-255-[_textLabel]-180-|";
//
//            [self internal_addConstraintsWithVisualFormat:titleLayout_h options:0 metrics:nil views:viewsDict];
//            [self internal_addConstraintsWithVisualFormat:textLayout_h options:0 metrics:nil views:viewsDict];
            [self layoutLabelWithOffsetX:255];
            [self internal_addConstraintsWithVisualFormat:@"V:|-15-[_titleLabel]-16-[_textLabel]-15-|" options:0 metrics:nil views:viewsDict];
            
            NSString *layoutFormatter = hideCta ? @"H:[_ctaLabel(0)]-0-|" : @"H:[_ctaLabel(120)]-46-|";
            [self internal_addConstraintsWithVisualFormat:layoutFormatter options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-15-[_ctaLabel(45)]-28-|" options:0 metrics:nil views:viewsDict];
        }
    }
    
    if(_setting.bannerSize != nil){
        [self internal_addConstraintsWithVisualFormat:@"H:|[_adNoteLabel(15)]" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|[_adNoteLabel(8)]" options:0 metrics:nil views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"H:[_sponsorImageView(28)]-0-|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:[_sponsorImageView(9)]-0-|" options:0 metrics:nil views:viewsDict];
    }
    
    [_titleLabel sizeToFit];
    [_textLabel sizeToFit];
}

-(NSArray<UIView*>*) clickableViews {
//    NSMutableArray <UIView*>* clickableViews = [NSMutableArray<UIView*> array];
//    if (self.ctaLabel != nil) { [clickableViews addObject:self.ctaLabel]; }
//    if (self.mainImageView != nil) { [clickableViews addObject:self.mainImageView]; }
//    if (self.textLabel != nil) { [clickableViews addObject:self.textLabel]; }
//    if (self.titleLabel != nil) { [clickableViews addObject:self.titleLabel]; }
//    if (self.homeImageView != nil) { [clickableViews addObject:self.homeImageView]; }
    NSMutableArray *views = [NSMutableArray array];
    
    if (self.homeImageView.image) {
        [views addObject:self.homeImageView];
    }
    if (self.backgroundImageView.image) {
        [views addObject:self.backgroundImageView];
    }
    if (self.mainImageView.image) {
        [views addObject:self.mainImageView];
    }
    if (self.iconImageView.image) {
        [views addObject:self.iconImageView];
    }
    
    if (self.titleLabel.text) {
        [views addObject:self.titleLabel];
    }
    if (self.textLabel.text) {
        [views addObject:self.textLabel];
    }
    if (self.ctaLabel.text) {
        [views addObject:self.ctaLabel];
    }
    return views;
    
//    return clickableViews;
}

-(void) initBannerResourceWithOfferModel:(ATOfferModel *)offerModel {
    [self.sponsorImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.logoURL]];

    // adx,onlineApi oneImage, without myOffer
    if (offerModel.crtType == ATOfferCrtTypeOneImage && offerModel.offerModelType != ATOfferModelMyOffer) {
        NSString *url = [Utilities isEmpty:self.offerModel.bannerImageUrl] ? self.offerModel.fullScreenImageURL : self.offerModel.bannerImageUrl;
        UIImage *image = [[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:url];
        [self.backgroundImageView setImage:image];
        [self.homeImageView setImage:image];
        return;
    }
    
    if([_setting.bannerSize isEqualToString:kATOfferBannerSize320_50]){
        // myOffer oneImage
        if(offerModel.crtType == ATOfferCrtTypeOneImage && [Utilities isEmpty:offerModel.bannerImageUrl] == NO){
            [self.homeImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.bannerImageUrl]];
            [self.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.bannerImageUrl]];
        }else{
            [self.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL]];
            [self.titleLabel setText:self.offerModel.title];
            [self.textLabel setText:self.offerModel.text];
            [self.ctaLabel setText:self.offerModel.CTA];
        }
    }else if([_setting.bannerSize isEqualToString:kATOfferBannerSize320_90]){
        // myOffer oneImage
        if(offerModel.crtType == ATOfferCrtTypeOneImage && [Utilities isEmpty:offerModel.bannerBigImageUrl] == NO){
            [self.homeImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.bannerBigImageUrl]];
            [self.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.bannerBigImageUrl]];
        }else{
            [self.mainImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
            [self.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL]];
            [self.titleLabel setText:self.offerModel.title];
            [self.textLabel setText:self.offerModel.text];
            [self.ctaLabel setText:self.offerModel.CTA];
        }
    }else if([_setting.bannerSize isEqualToString:kATOfferBannerSize300_250]){
        // myOffer oneImage
        if(offerModel.crtType == ATOfferCrtTypeOneImage && [Utilities isEmpty:offerModel.rectangleImageUrl] == NO){
            [self.homeImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.rectangleImageUrl]];
            [self.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.rectangleImageUrl]];
        }else{
            [self.mainImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
            [self.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL]];
            [self.titleLabel setText:self.offerModel.title];
            [self.textLabel setText:self.offerModel.text];
            [self.ctaLabel setText:self.offerModel.CTA];
        }
    }else if([_setting.bannerSize isEqualToString:kATOfferBannerSize728_90]){
        // myOffer oneImage
        if(offerModel.crtType == ATOfferCrtTypeOneImage && [Utilities isEmpty:offerModel.homeImageUrl] == NO){
            [self.homeImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.homeImageUrl]];
            [self.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.homeImageUrl]];
        }else{
            [self.mainImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
            [self.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL]];
            [self.titleLabel setText:self.offerModel.title];
            [self.textLabel setText:self.offerModel.text];
            [self.ctaLabel setText:self.offerModel.CTA];
        }
    }
}

-(void) setClickAction {
    if(_setting.showBannerCloseBtn){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        button.frame = CGRectMake(CGRectGetWidth(self.bounds) - 17.0f, 3.0f, 14.0f, 14.0f);
        [button setImage:[UIImage anythink_imageWithName:@"native_banner_close"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

//父视图已更改
- (void)didMoveToWindow {
    if(!_hasSendImpression){
        _hasSendImpression = YES;
        [self checkSizeAfterOneSecond];
    }
}

-(void) closeButtonTapped {
    if ([_delegate respondsToSelector:@selector(offerBannerCloseOffer:)]) {
        [_delegate offerBannerCloseOffer:_offerModel];
    }
}

-(void) adViewTapped {
    if ([_delegate respondsToSelector:@selector(offerBannerClickOffer:)]) {
        [_delegate offerBannerClickOffer:_offerModel];
    }
}

- (void)checkSizeAfterOneSecond {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect adRect = self.frame;
        CGRect windowRect = [UIApplication sharedApplication].keyWindow.frame;
        CGRect intersection = CGRectIntersection(adRect, windowRect);
        CGFloat interSize = intersection.size.width * intersection.size.height;
        CGFloat adSize = adRect.size.width * adRect.size.height;
        if (interSize > adSize/2) {
            [self offerBannerShowOfferCallback];
        }
    });
}

- (void)offerBannerShowOfferCallback {
    if ([_delegate respondsToSelector:@selector(offerBannerShowOffer:)]) {
        [_delegate offerBannerShowOffer:_offerModel];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.allObjects.firstObject;
    CGPoint point = [touch locationInView:self];

    self.touchStartPoint = point;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self trackEvent:touches];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self trackEvent:touches];
}

- (void)trackEvent:(NSSet<UITouch *> *)touches {
    UITouch *touch = touches.allObjects.firstObject;
    CGPoint relativePoint = [touch locationInView:self];
    
    if (self.offerModel.interActableArea == ATOfferInterActableAreaVisibleItems) {
        BOOL found = NO;
        for (UIView *view in [self clickableViews]) {
            if (CGRectContainsPoint(view.frame, relativePoint)) {
                found = YES;
                break;
            }
        }
        if (found == NO) {
            return;
        }
    }
    CGPoint point = [self convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
//    NSDictionary *ky_absolute = @{@"down_x":@(relativePoint.x),
//                                  @"down_y":@(relativePoint.y),
//                                  @"up_x":  @(relativePoint.x),
//                                  @"up_y":  @(relativePoint.y)
//    };
//    CGFloat width = self.frame.size.width;
//    CGFloat height = self.frame.size.height;
//
//    NSDictionary *ky_relative = @{@"down_x":@(relativePoint.x/width  * 1000),
//                                  @"down_y":@(relativePoint.y/height * 1000),
//                                  @"up_x":  @(relativePoint.x/width  * 1000),
//                                  @"up_y":  @(relativePoint.y/height * 1000)
//    };
    _offerModel.tapInfoDict = @{kATOfferTrackerGDTDownX: @(self.touchStartPoint.x),
                                kATOfferTrackerGDTDownY: @(self.touchStartPoint.y),
                                kATOfferTrackerGDTUpX:   @(point.x),
                                kATOfferTrackerGDTUpY:   @(point.y),
                                kATOfferTrackerGDTWidth: @([UIScreen mainScreen].nativeScale * self.frame.size.width),
                                kATOfferTrackerGDTHeight:@([UIScreen mainScreen].nativeScale * self.frame.size.height),
                                kATOfferTrackerGDTRequestWidth: @([UIScreen mainScreen].nativeScale * self.frame.size.width),
                                kATOfferTrackerGDTRequestHeight:@([UIScreen mainScreen].nativeScale * self.frame.size.height),
                               
                                kATOfferTrackerRelativeDownX:   @(relativePoint.x),
                                kATOfferTrackerRelativeDownY:   @(relativePoint.y),
                                kATOfferTrackerRelativeUpX:     @(relativePoint.x),
                                kATOfferTrackerRelativeUpY:     @(relativePoint.y),
//                                kATOfferTrackerKYAbsoluteCoord: ky_absolute,
//                                kATOfferTrackerKYRelativeCoord: ky_relative
    };
    [self adViewTapped];
    
}

- (void)layoutLabelWithOffsetX:(CGFloat)offset {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:offset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:offset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];
}

@end
