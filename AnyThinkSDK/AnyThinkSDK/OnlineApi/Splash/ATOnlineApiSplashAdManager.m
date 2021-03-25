//
//  ATOnlineApiSplashAdManager.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiSplashAdManager.h"
#import <StoreKit/StoreKit.h>
#import "ATOfferResourceManager.h"
#import "ATOnlineApiOfferModel.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATOnlineApiSplashDelegate.h"
#import "ATThreadSafeAccessor.h"
#import "NSDictionary+KAKit.h"
#import "Utilities.h"
#import "ATOfferSplashView.h"
#import "NSObject+KAKit.h"
#import "ATOnlineApiTracker.h"
#import "ATOnlineApiLoader.h"

// MARK:- ATOnlineApiSplashAdManager
@interface ATOnlineApiSplashAdManager ()<SKStoreProductViewControllerDelegate>
@property(nonatomic) ATOfferSplashView *currentSplashView;
@property(nonatomic) UIView *containerView;
@property(nonatomic) BOOL landingPageBeingShown;
@end

@implementation ATOnlineApiSplashAdManager

// MARK:- initializaiton

+ (instancetype)sharedManager {
    static ATOnlineApiSplashAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATOnlineApiSplashAdManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

// MARK:- function claimed is .h
- (void)showSplashInKeyWindow:(UIWindow *)window containerView:(UIView *)containerView offerModel:(ATOnlineApiOfferModel *)offerModel setting:(ATOnlineApiPlacementSetting *)setting delegate:(id<ATOnlineApiSplashDelegate>)delegate {
    self.model = offerModel;
    self.setting = setting;
    
    ATOfferResourceManager *manager = [ATOfferResourceManager sharedManager];
    ATOfferResourceModel *resource = [manager retrieveResourceModelWithResourceID:offerModel.localResourceID];
    
    if (resource == nil) {
        [self errorCallbackWith:offerModel delegate:delegate];
        return;
    }
    
    NSString *path = [manager resourcePathForOfferModel:offerModel resourceURL:offerModel.fullScreenImageURL];
    if (path == nil) {
        [self errorCallbackWith:offerModel delegate:delegate];
        return;
    }
    
    [self.delegateStorageAccessor writeWithBlock:^{
        [self.delegateStorage AT_setWeakObject:delegate forKey:offerModel.offerID];
    }];
    
    [self setCurrentSplashViewWithOfferModel:offerModel window:window containerView:containerView remainingTime:self.setting.splashCountDownTime];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect adRect = self.currentSplashView.frame;
        CGRect windowRect = [UIApplication sharedApplication].keyWindow.frame;
        CGRect intersection = CGRectIntersection(adRect, windowRect);
        CGFloat interSize = intersection.size.width * intersection.size.height;
        CGFloat adSize = adRect.size.width * adRect.size.height;
        if (interSize > adSize * 0.75) {
            [self.delegateStorageAccessor readWithBlock:^id{
                id<ATOnlineApiSplashDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:weakSelf.model.offerID];
                NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:weakSelf.model] : @"";
                NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
                [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventImpression offerModel:weakSelf.model extra:trackerExtra];
                if ([delegate respondsToSelector:@selector(onlineApiSplashShowOffer:)]) { [delegate onlineApiSplashShowOffer:offerModel]; }
                [[ATOnlineApiLoader sharedLoader] recordShownAdWithOfferID:offerModel.offerID unitID:offerModel.unitID];

                return nil;
            }];
        }
        [[ATOnlineApiLoader sharedLoader] removeOfferModel:offerModel];
        [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
    });
    
}

// MARK:- private methods

- (void)errorCallbackWith:(ATOnlineApiOfferModel *)model delegate:(id<ATOnlineApiSplashDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(onlineApiSplashFailToShowOffer:error:)]) {
        NSError *error = [NSError errorWithDomain:@"com.anythink.OnlineApiSplashShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"OnlineApi has failed to show Splash", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Splash's not ready for offerID:%@", model.offerID]}];
        [delegate onlineApiSplashFailToShowOffer:model error:error];
    }
}

- (void)setCurrentSplashViewWithOfferModel:(ATOnlineApiOfferModel *) offerModel window:(UIWindow *)window containerView:(UIView *)containerView remainingTime:(NSTimeInterval)remainingTime {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //show splash with window
        if(self.currentSplashView) {
            [self.currentSplashView removeFromSuperview];
        }
        if(self.containerView) {
            [self.containerView removeFromSuperview];
        }
        self.containerView = containerView;
        ATOfferSplashView *splashView = [[ATOfferSplashView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)) containerView:containerView offerModel:offerModel isPortrait:self.setting.splashOrientation == 1];
        self.currentSplashView = splashView;
        [weakSelf initViewResourceWithRemainingTime:remainingTime];
        NSArray<UIView*>* clickableViews = [self.currentSplashView clickableViews];
        
        for (UIView *clickableView in clickableViews) {
            UITapGestureRecognizer *tapsAd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped:)];
            tapsAd.numberOfTouchesRequired = 1;
            tapsAd.numberOfTapsRequired = 1;
            clickableView.userInteractionEnabled = YES;
            [clickableView addGestureRecognizer:tapsAd];
        }
        
        [self startCountdown:(remainingTime>0)?remainingTime : weakSelf.setting.splashCountDownTime];
        [window addSubview:weakSelf.currentSplashView];
    });
}

-(void) startCountdown:(NSTimeInterval)interval {
    __block NSInteger remainingTime = interval;
    __weak typeof(self) weakSelf = self;
    [NSTimer timerWithTimeInterval:1.0f target:self repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.currentSplashView != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (remainingTime == 0) {
                    [timer invalidate];
                    weakSelf.landingPageBeingShown = NO;
                    [weakSelf skipButtonTapped];
                } else {
                    [weakSelf.currentSplashView.skipButton setTitle:[NSString stringWithFormat:kSkipTextFormatString, --remainingTime, weakSelf.setting.skipable ? [weakSelf skipSubString] : @""] forState:UIControlStateNormal];
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

- (void) skipButtonTapped {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.currentSplashView != nil) {
            [self.currentSplashView removeFromSuperview];
            if(self.containerView != nil) [self.containerView removeFromSuperview];
            __weak typeof(self) weakSelf = self;
            [self.delegateStorageAccessor readWithBlock:^id{
                id<ATOnlineApiSplashDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:weakSelf.model.offerID];
                if ([delegate respondsToSelector:@selector(onlineApiSplashCloseOffer:)]) {
                    [delegate onlineApiSplashCloseOffer:weakSelf.model];
                }
                return nil;
            }];
            self.currentSplashView = nil;
        }
    });
}

- (void)adViewTapped:(UITapGestureRecognizer *)tap {
    [ATLogger logMessage:@"ATOnlineApiSplash::adViewTapped" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        
        CGPoint relativePoint = [tap locationInView:self.currentSplashView];
        CGPoint point = [tap.view convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
        relativePoint = point;
        
        id<ATOnlineApiSplashDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:weakSelf.model.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:weakSelf.model] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        NSDictionary *dic = @{kATOfferTrackerGDTDownX: @(point.x),
                              kATOfferTrackerGDTDownY: @(point.y),
                              kATOfferTrackerGDTUpX:   @(point.x),
                              kATOfferTrackerGDTUpY:   @(point.y),
                              kATOfferTrackerGDTWidth: @([UIScreen mainScreen].nativeScale * tap.view.frame.size.width),
                              kATOfferTrackerGDTHeight:@([UIScreen mainScreen].nativeScale * tap.view.frame.size.height),
                              kATOfferTrackerGDTRequestWidth: @([UIScreen mainScreen].nativeScale * tap.view.frame.size.width),
                              kATOfferTrackerGDTRequestHeight:@([UIScreen mainScreen].nativeScale * tap.view.frame.size.height),
                              kATOfferTrackerRelativeDownX:   @(relativePoint.x),
                              kATOfferTrackerRelativeDownY:   @(relativePoint.y),
                              kATOfferTrackerRelativeUpX:     @(relativePoint.x),
                              kATOfferTrackerRelativeUpY:     @(relativePoint.y)
        };
        [trackerExtra addEntriesFromDictionary:dic];
        [[ATOnlineApiTracker sharedTracker] clickOfferWithOfferModel:weakSelf.model setting:self.setting circleID:lifeCircleID delegate:self viewController:[UIApplication sharedApplication].keyWindow.rootViewController extra:trackerExtra clickCallbackHandler:^(BOOL success) {
            if ([delegate respondsToSelector:@selector(onlineApiSplashDeepLinkOrJumpResult:offer:)]) {
                [delegate onlineApiSplashDeepLinkOrJumpResult:success offer:weakSelf.model];
            }
        }];
        [[ATOnlineApiTracker sharedTracker] trackEvent:ATOnlineApiTrackerEventClick offerModel:weakSelf.model extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(onlineApiSplashClickOffer:)]) { [delegate onlineApiSplashClickOffer:weakSelf.model]; }
        [weakSelf skipButtonTapped];
        return nil;
    }];
}

- (NSString *)skipSubString {
    
    NSString *string = [self languageConfiguration][kLanguageConfigurationSkip][[[Utilities language] componentsSeparatedByString:@"-"][0]];
    return [Utilities isEmpty:string] ? @"Skip" : string;
}

static NSString *kLanguageConfigurationSkip = @"skip";
- (NSDictionary *)languageConfiguration {
    static NSDictionary *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = @{@"skip":@{@"zh":@" 跳过", @"ja":@" スキップ", @"en":@" Skip"}};
    });
    return config;
}

-(void) initViewResourceWithRemainingTime:(NSTimeInterval)interval {
    if (_currentSplashView != nil && self.model != nil) {
        [_currentSplashView setStarts:5.0f];
        [_currentSplashView.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.model resourceURL:self.model.iconURL]];
        [_currentSplashView.mainImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.model resourceURL:self.model.fullScreenImageURL]];
        [_currentSplashView.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.model resourceURL:self.model.fullScreenImageURL]];
        [_currentSplashView.titleLabel setText:self.model.title];
        [_currentSplashView.textLabel setText:self.model.text];
        [_currentSplashView.ctaLabel setText:self.model.CTA];
        
        _currentSplashView.ctaLabel.hidden = _currentSplashView.ctaBackgroundImageView.hidden = [Utilities isEmpty:self.model.CTA] ? YES : NO;
        [_currentSplashView.sponsorImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.model resourceURL:self.model.logoURL]];
        NSInteger remainingTime = interval + 1;
        [_currentSplashView.skipButton setTitle:[NSString stringWithFormat:kSkipTextFormatString, --remainingTime, self.setting.skipable ? [self skipSubString] : @""] forState:UIControlStateNormal];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

@end
