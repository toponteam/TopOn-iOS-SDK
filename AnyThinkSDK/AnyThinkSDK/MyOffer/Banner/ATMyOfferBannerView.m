//
//  ATMyOfferBannerView.m
//  AnyThinkMyOffer
//
//  Created by stephen on 8/3/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferBannerView.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferModel.h"
#import "ATMyOfferOfferManager.h"
#import "ATMyOfferTracker.h"
#import "ATOfferResourceManager.h"
#import "UIViewController+PresentationAndDismissalSwizzling.h"

@interface ATMyOfferBannerView()
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


@property (nonatomic , strong) ATMyOfferOfferModel *offerModel;
@property (nonatomic) ATMyOfferSetting *setting;
@property (nonatomic) BOOL hasSendImpression;
@property (nonatomic , weak) UIViewController *viewController;

@end
@implementation ATMyOfferBannerView


-(instancetype) initWithFrame:(CGRect)frame offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting delegate:(id<ATMyOfferBannerDelegate>)delegate viewController:(UIViewController *)viewController {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.clipsToBounds = YES;
        _delegate = delegate;
        _offerModel = offerModel;
        _setting = setting;
        _viewController = viewController;
        _hasSendImpression = NO;
    }
    return self;
}

-(void) initMyOfferBannerView {
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
    
    _homeImageView = [UIImageView internal_autolayoutView];
    _homeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_homeImageView];
    
    _iconImageView = [UIImageView internal_autolayoutView];
    _iconImageView.layer.cornerRadius = 4.0f;
    _iconImageView.layer.masksToBounds = YES;
    [self addSubview:_iconImageView];
    
    _titleLabel = [UILabel internal_autolayoutLabelFont:[UIFont boldSystemFontOfSize:13.0f] textColor:[UIColor blackColor]];
    [self addSubview:_titleLabel];
    
    _textLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:12.0f] textColor:[UIColor blackColor]];
    [self addSubview:_textLabel];
    
    _ctaLabel = [UILabel internal_autolayoutLabelFont:[UIFont systemFontOfSize:12.0f] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter];
    _ctaLabel.backgroundColor = [UIColor colorWithRed:234.0f / 255.0f green:64.0f / 255.0f blue:72.0f / 255.0f alpha:1.0f];
    _ctaLabel.layer.masksToBounds = YES;
    [self addSubview:_ctaLabel];
    
    _mainImageView = [UIImageView internal_autolayoutView];
    _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_mainImageView];
    
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
    [self addSubview:_adNoteLabel];
    
    _sponsorImageView = [UIImageView internal_autolayoutView];
    [self addSubview:_sponsorImageView];
    
}

-(void) makeConstraintsForSubviews {
    //constraintsfor diferent size
    NSDictionary *viewsDict = nil;
    if(_offerModel.bannerImageUrl != nil && _offerModel.bannerImageUrl.length > 0 && [_setting.bannerSize isEqualToString:kATMyOfferBannerSize320_50] || _offerModel.bannerBigImageUrl != nil && _offerModel.bannerBigImageUrl.length > 0 && [_setting.bannerSize isEqualToString:kATMyOfferBannerSize320_90] || _offerModel.rectangleImageUrl != nil && _offerModel.rectangleImageUrl.length > 0 && [_setting.bannerSize isEqualToString:kATMyOfferBannerSize300_250] || _offerModel.homeImageUrl != nil && _offerModel.homeImageUrl.length > 0 && [_setting.bannerSize isEqualToString:kATMyOfferBannerSize728_90]){
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
        if([_setting.bannerSize isEqualToString:kATMyOfferBannerSize320_50]){
            _mainImageView.hidden = YES;
            viewsDict = NSDictionaryOfVariableBindings(_iconImageView, _titleLabel, _textLabel, _ctaLabel, _sponsorImageView, _adNoteLabel);
            [self internal_addConstraintsWithVisualFormat:@"H:|-10-[_iconImageView(38)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-6-[_iconImageView(38)]-6-|" options:0 metrics:nil views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:|-50-[_titleLabel]-100-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-50-[_textLabel]-100-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-7-[_titleLabel]-8-[_textLabel]-7-|" options:0 metrics:nil views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:[_ctaLabel(80)]-20-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_ctaLabel(30)]-10-|" options:0 metrics:nil views:viewsDict];
            
        }else if([_setting.bannerSize isEqualToString:kATMyOfferBannerSize320_90]){
            viewsDict = NSDictionaryOfVariableBindings(_mainImageView, _iconImageView, _titleLabel, _textLabel, _ctaLabel, _sponsorImageView, _adNoteLabel);
            [self internal_addConstraintsWithVisualFormat:@"H:|-10-[_mainImageView(128)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-8-[_mainImageView(72)]-8-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-148-[_iconImageView(34)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-8-[_iconImageView(34)]" options:0 metrics:nil views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:|-190-[_titleLabel]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-190-[_textLabel]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-8-[_titleLabel]-8-[_textLabel]-43-|" options:0 metrics:nil views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:[_ctaLabel(160)]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:[_ctaLabel(24)]-17-|" options:0 metrics:nil views:viewsDict];
            
        }else if([_setting.bannerSize isEqualToString:kATMyOfferBannerSize300_250]){
            viewsDict = NSDictionaryOfVariableBindings(_mainImageView, _iconImageView, _titleLabel, _textLabel, _ctaLabel, _sponsorImageView, _adNoteLabel);
            [self internal_addConstraintsWithVisualFormat:@"H:|-10-[_mainImageView(280)]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_mainImageView(155)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-8-[_iconImageView(34)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-170-[_iconImageView(34)]" options:0 metrics:nil views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:|-50-[_titleLabel]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-50-[_textLabel]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-170-[_titleLabel]-8-[_textLabel]-43-|" options:0 metrics:nil views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:|-10-[_ctaLabel(280)]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:[_ctaLabel(24)]-16-|" options:0 metrics:nil views:viewsDict];
        }else if([_setting.bannerSize isEqualToString:kATMyOfferBannerSize728_90]){
            //728*90
            viewsDict = NSDictionaryOfVariableBindings(_mainImageView, _iconImageView, _titleLabel, _textLabel, _ctaLabel, _sponsorImageView, _adNoteLabel);
            [self internal_addConstraintsWithVisualFormat:@"H:|-22-[_mainImageView(128)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_mainImageView(72)]-10-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-175-[_iconImageView(72)]" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-10-[_iconImageView(72)]-10-|" options:0 metrics:nil views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:|-255-[_titleLabel]-180-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"H:|-255-[_textLabel]-180-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-15-[_titleLabel]-16-[_textLabel]-15-|" options:0 metrics:nil views:viewsDict];
            
            [self internal_addConstraintsWithVisualFormat:@"H:[_ctaLabel(120)]-46-|" options:0 metrics:nil views:viewsDict];
            [self internal_addConstraintsWithVisualFormat:@"V:|-15-[_ctaLabel(45)]-28-|" options:0 metrics:nil views:viewsDict];
        }
    }
    
    if(_setting.bannerSize != nil){
        [self internal_addConstraintsWithVisualFormat:@"H:|[_adNoteLabel(15)]" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:|[_adNoteLabel(8)]" options:0 metrics:nil views:viewsDict];
        
        [self internal_addConstraintsWithVisualFormat:@"H:[_sponsorImageView(32)]-6-|" options:0 metrics:nil views:viewsDict];
        [self internal_addConstraintsWithVisualFormat:@"V:[_sponsorImageView(9)]-2-|" options:0 metrics:nil views:viewsDict];
    }
    
}

-(NSArray<UIView*>*) clickableViews {
    NSMutableArray <UIView*>* clickableViews = [NSMutableArray<UIView*> array];
    if (self.ctaLabel != nil) { [clickableViews addObject:self.ctaLabel]; }
    if (self.mainImageView != nil) { [clickableViews addObject:self.mainImageView]; }
    if (self.textLabel != nil) { [clickableViews addObject:self.textLabel]; }
    if (self.titleLabel != nil) { [clickableViews addObject:self.titleLabel]; }
    if (self.homeImageView != nil) { [clickableViews addObject:self.homeImageView]; }
    
    return clickableViews;
}

-(void) initBannerResourceWithOfferModel:(ATMyOfferOfferModel *)offerModel {
    [self.sponsorImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.logoURL]];
    if([_setting.bannerSize isEqualToString:kATMyOfferBannerSize320_50]){
        if(offerModel.bannerImageUrl != nil && offerModel.bannerImageUrl.length > 0){
            [self.homeImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.bannerImageUrl]];
            [self.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.bannerImageUrl]];
        }else{
            [self.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL]];
            [self.titleLabel setText:self.offerModel.title];
            [self.textLabel setText:self.offerModel.text];
            [self.ctaLabel setText:self.offerModel.CTA];
        }
    }else if([_setting.bannerSize isEqualToString:kATMyOfferBannerSize320_90]){
        if(offerModel.bannerBigImageUrl != nil && offerModel.bannerBigImageUrl.length > 0){
            [self.homeImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.bannerBigImageUrl]];
            [self.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.bannerBigImageUrl]];
        }else{
            [self.mainImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
            [self.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL]];
            [self.titleLabel setText:self.offerModel.title];
            [self.textLabel setText:self.offerModel.text];
            [self.ctaLabel setText:self.offerModel.CTA];
        }
        
    }else if([_setting.bannerSize isEqualToString:kATMyOfferBannerSize300_250]){
        if(offerModel.rectangleImageUrl != nil && offerModel.rectangleImageUrl.length > 0){
            [self.homeImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.rectangleImageUrl]];
            [self.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.rectangleImageUrl]];
        }else{
            [self.mainImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
            [self.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL]];
            [self.titleLabel setText:self.offerModel.title];
            [self.textLabel setText:self.offerModel.text];
            [self.ctaLabel setText:self.offerModel.CTA];
        }
    }else if([_setting.bannerSize isEqualToString:kATMyOfferBannerSize728_90]){
        //728*90
        if(offerModel.homeImageUrl != nil && offerModel.homeImageUrl.length > 0){
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
    NSArray<UIView*>* clickableViews = [self clickableViews];
    
    for (UIView *clickableView in clickableViews) {
        UITapGestureRecognizer *tapsAd = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(adViewTapped)];
        tapsAd.numberOfTouchesRequired = 1;
        tapsAd.numberOfTapsRequired = 1;
        clickableView.userInteractionEnabled = YES;
        [clickableView addGestureRecognizer:tapsAd];
    }
    
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
        NSString *lifeCircleID = [_delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [_delegate lifeCircleIDForOffer:_offerModel] : @"";
        [[ATMyOfferTracker sharedTracker] impressionOfferWithOfferModel:_offerModel extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventImpression offerModel:_offerModel extra:trackerExtra];
        if ([_delegate respondsToSelector:@selector(myOfferBannerShowOffer:)]) { [_delegate myOfferBannerShowOffer:_offerModel]; }
        [[ATMyOfferTracker sharedTracker] preloadStorekitForOfferModel:_offerModel setting:_setting viewController:_viewController circleId:lifeCircleID skDelegate:self];
        
    }
}


-(void) closeButtonTapped {
    if ([_delegate respondsToSelector:@selector(myOfferBannerCloseOffer:)]) {
        [_delegate myOfferBannerCloseOffer:_offerModel];
    }
}

-(void) adViewTapped {
    [ATLogger logMessage:@"ATMyOfferBannerView::adViewTapped" type:ATLogTypeExternal];
    NSString *lifeCircleID = [_delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [_delegate lifeCircleIDForOffer:_offerModel] : @"";
    NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
    BOOL openStorekit = _setting.storekitTime != ATATLoadStorekitTimeNone;
    [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:_offerModel setting:_setting extra:trackerExtra skDelegate:self viewController:_viewController circleId:lifeCircleID];
    [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventClick offerModel:_offerModel extra:trackerExtra];
    if ([_delegate respondsToSelector:@selector(myOfferBannerClickOffer:)]) { [_delegate myOfferBannerClickOffer:_offerModel]; }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
    
   //TODO something when storeit is close
    
}
@end


