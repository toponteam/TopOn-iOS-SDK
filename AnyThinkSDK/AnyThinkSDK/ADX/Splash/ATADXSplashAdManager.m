//
//  ATADXSplashAdManager.m
//  AnyThinkSDK
//
//  Created by Topon on 10/21/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXSplashAdManager.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATADXTracker.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
#import "ATOfferSplashView.h"
#import "NSObject+KAKit.h"
#import "ATBidInfoManager.h"
#import "ATADXSplashCustomEvent.h"
#import "ATADXLoader.h"

#pragma mark - splash wrapper
@interface ATADXSplashAdManager()
@property(nonatomic) ATOfferSplashView *currentSplashView;
@property(nonatomic, weak) UIView *containerView;
@property(nonatomic) NSString *layoutStyle;
@property(nonatomic) BOOL landingPageBeingShown;
//@property(nonatomic) NSMutableDictionary *splashExtra;

@end

@implementation ATADXSplashAdManager
+(instancetype) sharedManager {
    static ATADXSplashAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATADXSplashAdManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

-(void) initViewResourceWithRemainingTime:(NSTimeInterval)interval {
    if (_currentSplashView != nil && self.offerModel != nil) {
        [_currentSplashView setStarts:5.0f];
        [_currentSplashView.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL]];
        [_currentSplashView.mainImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
        [_currentSplashView.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
        [_currentSplashView.titleLabel setText:self.offerModel.title];
        [_currentSplashView.textLabel setText:self.offerModel.text];
        [_currentSplashView.ctaLabel setText:self.offerModel.CTA];

        _currentSplashView.ctaLabel.hidden = _currentSplashView.ctaBackgroundImageView.hidden = [Utilities isEmpty:self.offerModel.CTA] ? YES : NO;
        [_currentSplashView.sponsorImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.logoURL]];
        NSInteger remainingTime = interval + 1;
        [_currentSplashView.skipButton setTitle:[NSString stringWithFormat:kSkipTextFormatString, --remainingTime, self.setting.skipable ? [ATADXSplashAdManager skipSubString] : @""] forState:UIControlStateNormal];
    }
}

-(void) skipButtonTapped {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([ATADXSplashAdManager sharedManager].currentSplashView != nil) {
            [[ATADXSplashAdManager sharedManager].currentSplashView removeFromSuperview];
            if([ATADXSplashAdManager sharedManager].containerView != nil) [[ATADXSplashAdManager sharedManager].containerView removeFromSuperview];
            __weak typeof(self) weakSelf = self;
            [self.delegateStorageAccessor readWithBlock:^id{
                id<ATADXSplashDelegate> delegate = [weakSelf.delegateStorage AT_weakObjectForKey:weakSelf.offerModel.offerID];
                if ([delegate respondsToSelector:@selector(adxSplashCloseOffer:)]) {
                    [delegate adxSplashCloseOffer:weakSelf.offerModel];
                }
                return nil;
            }];
            [ATADXSplashAdManager sharedManager].currentSplashView = nil;
        }
    });
}

-(void) adViewTapped:(UITapGestureRecognizer *)tap {
    [ATLogger logMessage:@"ATAdxSplashSharedDelegate::adViewTapped" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [self.delegateStorageAccessor readWithBlock:^id{
        CGPoint relativePoint = [tap locationInView:self.currentSplashView];
        CGPoint point = [tap.view convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
        relativePoint = point;
        [weakSelf handleRelativePoint:relativePoint pointToWindow:point viewSize:tap.view.frame.size];
        return nil;
    }];
}

- (void)handleRelativePoint:(CGPoint)relativePoint pointToWindow:(CGPoint)point viewSize:(CGSize)size {
    id<ATADXSplashDelegate> delegate = [self.delegateStorage AT_weakObjectForKey:self.offerModel.offerID];
    NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:self.offerModel] : @"";
    NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
    [[ATADXTracker sharedTracker] clickOfferWithOfferModel:self.offerModel setting:self.setting extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID clickCallbackHandler:^(BOOL success) {
        if ([delegate respondsToSelector:@selector(adxSplashDeepLinkOrJumpResult:offer:)]) {
            [delegate adxSplashDeepLinkOrJumpResult:success offer:self.offerModel];
        }
    }];
    
    NSDictionary *dic = @{kATOfferTrackerGDTDownX: @(point.x),
                          kATOfferTrackerGDTDownY: @(point.y),
                          kATOfferTrackerGDTUpX:   @(point.x),
                          kATOfferTrackerGDTUpY:   @(point.y),
                          kATOfferTrackerGDTWidth: @([UIScreen mainScreen].nativeScale * size.width),
                          kATOfferTrackerGDTHeight:@([UIScreen mainScreen].nativeScale * size.height),
                          kATOfferTrackerGDTRequestWidth: @([UIScreen mainScreen].nativeScale * size.width),
                          kATOfferTrackerGDTRequestHeight:@([UIScreen mainScreen].nativeScale * size.height),
                          kATOfferTrackerRelativeDownX:   @(relativePoint.x),
                          kATOfferTrackerRelativeDownY:   @(relativePoint.y),
                          kATOfferTrackerRelativeUpX:     @(relativePoint.x),
                          kATOfferTrackerRelativeUpY:     @(relativePoint.y)
    };
    [trackerExtra addEntriesFromDictionary:dic];

    [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventClick offerModel:self.offerModel extra:trackerExtra];
    
    if ([delegate respondsToSelector:@selector(adxSplashClickOffer:)]) { [delegate adxSplashClickOffer:self.offerModel]; }
    [self skipButtonTapped];
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
    return [[ATADXSplashAdManager languageConfiguration][kLanguageConfigurationSkip][[[Utilities language] componentsSeparatedByString:@"-"][0]] length] > 0 ? [ATADXSplashAdManager languageConfiguration][kLanguageConfigurationSkip][[[Utilities language] componentsSeparatedByString:@"-"][0]] : @" Skip";
}

-(void) startCountdown:(NSTimeInterval)interval {
    __block NSInteger remainingTime = interval;
    __weak typeof(self) weakSelf = self;
    [NSTimer timerWithTimeInterval:1.0f target:self repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.currentSplashView != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (remainingTime == 0) {
                    [timer invalidate];
                    [ATADXSplashAdManager sharedManager].landingPageBeingShown = NO;
                    [[ATADXSplashAdManager sharedManager] skipButtonTapped];
                } else {
                    [weakSelf.currentSplashView.skipButton setTitle:[NSString stringWithFormat:kSkipTextFormatString, --remainingTime, weakSelf.setting.skipable ? [ATADXSplashAdManager skipSubString] : @""] forState:UIControlStateNormal];
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

-(void) setCurrentSplashViewWithOfferModel:(ATADXOfferModel *) offerModel window:(UIWindow *)window containerView:(UIView *)containerView remainingTime:(NSTimeInterval)remainingTime {

    dispatch_async(dispatch_get_main_queue(), ^{
        //show splash with window
        if([ATADXSplashAdManager sharedManager].currentSplashView != nil) {
            [[ATADXSplashAdManager sharedManager].currentSplashView removeFromSuperview];
        }
        if([ATADXSplashAdManager sharedManager].containerView != nil) {
            [[ATADXSplashAdManager sharedManager].containerView removeFromSuperview];
        }
        [ATADXSplashAdManager sharedManager].containerView = containerView;

        ATOfferSplashView *splashView = [[ATOfferSplashView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)) containerView:containerView offerModel:offerModel isPortrait:self.setting.splashOrientation == 1];
        self.currentSplashView = splashView;
        [self initViewResourceWithRemainingTime:remainingTime];
        
        for (UIView *clickableView in splashView.clickableViews) {
            UITapGestureRecognizer *tapsAd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped:)];
            tapsAd.numberOfTouchesRequired = 1;
            tapsAd.numberOfTapsRequired = 1;
            clickableView.userInteractionEnabled = YES;
            [clickableView addGestureRecognizer:tapsAd];
        }
        
        [[ATADXSplashAdManager sharedManager] startCountdown:(remainingTime>0)?remainingTime : self.setting.splashCountDownTime];
        [window addSubview:self.currentSplashView];
    });
}

- (void)clickAdxSplash:(UIButton *)btn event:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint relativePoint = [touch locationInView:btn];
    CGPoint point = [btn convertPoint:relativePoint toView:[UIApplication sharedApplication].keyWindow];
    [self handleRelativePoint:relativePoint pointToWindow:point viewSize:btn.frame.size];
}

- (void)showSplashInKeyWindow:(UIWindow *)window containerView:(UIView *)containerView offerModel:(ATADXOfferModel*)offerModel setting:(ATADXPlacementSetting*)setting  delegate:(id<ATADXSplashDelegate>)delegate {
    self.setting = setting;
    self.offerModel = offerModel;
    
    if ([[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
        if ([[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.fullScreenImageURL] != nil) {
            __weak typeof(self) weakSelf = self;
            [self.delegateStorageAccessor writeWithBlock:^{
                [weakSelf.delegateStorage AT_setWeakObject:delegate forKey:offerModel.offerID];
            }];
            
            [weakSelf setCurrentSplashViewWithOfferModel:offerModel window:window containerView:containerView remainingTime:self.setting.splashCountDownTime];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

                if (self.currentSplashView != nil) {
                    CGRect adRect = self.currentSplashView.frame;
                    CGRect windowRect = [UIApplication sharedApplication].keyWindow.frame;
                    CGRect intersection = CGRectIntersection(adRect, windowRect);
                    CGFloat interSize = intersection.size.width * intersection.size.height;
                    CGFloat adSize = adRect.size.width * adRect.size.height;
                    if (interSize > adSize * 0.75) {
                        [self.delegateStorageAccessor readWithBlock:^id{
                            id<ATADXSplashDelegate> kdelegate = [weakSelf.delegateStorage AT_weakObjectForKey:weakSelf.offerModel.offerID];
                            if (kdelegate == nil) {
                                kdelegate = delegate;
                            }
                            NSString *lifeCircleID = [kdelegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [kdelegate lifeCircleIDForOffer:weakSelf.offerModel] : @"";
                            NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
                            [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventImpression offerModel:weakSelf.offerModel extra:trackerExtra];
                            if ([kdelegate respondsToSelector:@selector(adxSplashShowOffer:)]) { [kdelegate adxSplashShowOffer:offerModel]; }
                            return nil;
                        }];
                    }
                    
                }
                if ([delegate isKindOfClass:[ATADXSplashCustomEvent class]]) {
                    ATADXSplashCustomEvent *event = (ATADXSplashCustomEvent *)delegate;
                    [[ATADXLoader sharedLoader] removeOfferModel:self.offerModel];
                    [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:setting.placementID unitGroupModel:event.unitGroupModel requestID:event.requestID];
                }

                [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
            });
        } else {
            if ([delegate respondsToSelector:@selector(adxSplashFailToShowOffer:error:)]) { [delegate adxSplashFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.ADXSplashShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"ADX has failed to show Splash", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Splash's not ready for fullScreenImage URL:%@", offerModel.fullScreenImageURL]}]]; }
        }
    } else {
        if ([delegate respondsToSelector:@selector(adxSplashFailToShowOffer:error:)]) { [delegate adxSplashFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.ADXSplashShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"ADX has failed to show Splash", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Splash's not ready for offerID:%@", offerModel.offerID]}]]; }
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

@end
