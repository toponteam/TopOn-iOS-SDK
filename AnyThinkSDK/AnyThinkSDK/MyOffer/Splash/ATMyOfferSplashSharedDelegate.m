//
//  ATMyofferSplashSharedDelegate.m
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferSplashSharedDelegate.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATMyOfferOfferManager.h"
#import "ATMyOfferTracker.h"
#import "ATMyOfferCapsManager.h"
#import "ATPlacementSettingManager.h"
#import "ATOfferResourceManager.h"
#import "ATOfferSplashView.h"
#import "NSObject+KAKit.h"

@interface ATMyOfferSplashSharedDelegate()

@property(nonatomic, readonly) NSMutableDictionary<NSString*, id<ATMyOfferSplashDelegate>> *delegates;
@property(nonatomic, readonly) ATThreadSafeAccessor *delegateStorageAccessor;

@property(nonatomic, readonly) dispatch_queue_t delegates_accessing_queue;
@property(nonatomic) NSMutableDictionary *splashExtra;

@property (nonatomic , strong)ATMyOfferOfferModel *offerModel;
@property (nonatomic) ATMyOfferSetting *setting;

@end

#pragma mark - splash wrapper
@interface ATMyOfferSplashSharedDelegate()

@property(nonatomic) ATOfferSplashView *currentSplashView;
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

-(void) initViewResourceWithRemainingTime:(NSTimeInterval)interval {
    if (_currentSplashView != nil && _offerModel != nil) {
        if (_offerModel.rating) {
            [_currentSplashView setStarts:_offerModel.rating];
        }
        [_currentSplashView.iconImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.iconURL]];
        [_currentSplashView.mainImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
        [_currentSplashView.backgroundImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.fullScreenImageURL]];
        [_currentSplashView.titleLabel setText:self.offerModel.title];
        [_currentSplashView.textLabel setText:self.offerModel.text];
        
        _currentSplashView.ctaLabel.hidden = _currentSplashView.ctaBackgroundImageView.hidden = self.offerModel.CTA.length == 0;
        [_currentSplashView.ctaLabel setText:self.offerModel.CTA];

        [_currentSplashView.sponsorImageView setImage:[[ATOfferResourceManager sharedManager]imageForOfferModel:self.offerModel resourceURL:self.offerModel.logoURL]];
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
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:_offerModel setting:_setting extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID];
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
        ATOfferSplashView* splashView = [[ATOfferSplashView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)) containerView:containerView  offerModel:offerModel isPortrait:self.setting.splashOrientation == 1];
        [ATMyOfferSplashSharedDelegate sharedDelegate].currentSplashView = splashView;
        [self initViewResourceWithRemainingTime:remainingTime];
        
        for (UIView *clickableView in splashView.clickableViews) {

            UITapGestureRecognizer *tapsAd = [[UITapGestureRecognizer alloc]initWithTarget:[ATMyOfferSplashSharedDelegate sharedDelegate] action:@selector(adViewTapped)];
            tapsAd.numberOfTouchesRequired = 1;
            tapsAd.numberOfTapsRequired = 1;
            clickableView.userInteractionEnabled = YES;
            [clickableView addGestureRecognizer:tapsAd];
        }
        
        [[ATMyOfferSplashSharedDelegate sharedDelegate] startCountdown:(remainingTime>0)?remainingTime : self->_setting.splashCountDownTime];
        [window addSubview:self->_currentSplashView];
    });
}

- (NSArray<UIView *> *)restrictedClickableViews {
    NSMutableArray *views = [NSMutableArray array];
    
    if (_currentSplashView.iconImageView.image) {
        [views addObject:_currentSplashView.iconImageView];
    }
    if (_currentSplashView.mainImageView.image) {
        [views addObject:_currentSplashView.mainImageView];
    }
    if (_currentSplashView.backgroundImageView.image) {
        [views addObject:_currentSplashView.backgroundImageView];
    }
    if (_currentSplashView.sponsorImageView.image) {
        [views addObject:_currentSplashView.sponsorImageView];
    }
    
    if (_currentSplashView.titleLabel.text) {
        [views addObject:_currentSplashView.titleLabel];
    }
    if (_currentSplashView.textLabel.text) {
        [views addObject:_currentSplashView.textLabel];
    }
    if (_currentSplashView.ctaLabel.text) {
        [views addObject:_currentSplashView.ctaLabel];
    }
    return views;
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
    
    if ([[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
        if ([[ATOfferResourceManager sharedManager] resourcePathForOfferModel:offerModel resourceURL:offerModel.fullScreenImageURL] != nil) {
            __weak typeof(self) weakSelf = self;
            [_delegateStorageAccessor writeWithBlock:^{
                [weakSelf setDelegate:delegate forPlacementID:offerModel.offerID];
                
            }];
            [weakSelf setCurrentSplashViewWithOfferModel:offerModel window:window containerView:containerView remainingTime:_setting.splashCountDownTime/1000];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                CGRect adRect = self.currentSplashView.frame;
                CGRect windowRect = [UIApplication sharedApplication].keyWindow.frame;
                CGRect intersection = CGRectIntersection(adRect, windowRect);
                CGFloat interSize = intersection.size.width * intersection.size.height;
                CGFloat adSize = adRect.size.width * adRect.size.height;
                if (interSize > adSize * 0.75) {
                    //to do
                    id<ATMyOfferSplashDelegate> kdelegate = [self delegateForPlacementID:offerModel.offerID];
                    if (kdelegate == nil) {
                        kdelegate = delegate;
                    }
                    NSString *lifeCircleID = [kdelegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [kdelegate lifeCircleIDForOffer:self->_offerModel] : @"";
                    [[ATMyOfferTracker sharedTracker] impressionOfferWithOfferModel:self->_offerModel extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
                    NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
                    [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventImpression offerModel:self->_offerModel extra:trackerExtra];
                    if ([kdelegate respondsToSelector:@selector(myOfferSplashShowOffer:)]) {
                        [kdelegate myOfferSplashShowOffer:offerModel];
                        
                    }
                }
                [[ATOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
                [[ATMyOfferCapsManager shareManager] increaseCapForOfferModel:offerModel];
                if ([[ATMyOfferCapsManager shareManager] validateCapsForOfferModel:offerModel]) {
                    [[ATPlacementSettingManager sharedManager] removeCappedMyOfferID:offerModel.offerID];
                } else {
                    [[ATPlacementSettingManager sharedManager] addCappedMyOfferID:offerModel.offerID];
                }
            });
            

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
