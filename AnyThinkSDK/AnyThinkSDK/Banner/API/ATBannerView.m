//
//  ATBannerView.m
//  AnyThinkBanner
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerView.h"
#import "ATCapsManager.h"
#import "ATBannerDelegate.h"
#import "ATBannerCustomEvent.h"
#import "ATBanner.h"
#import "ATTracker.h"
#import "ATAPI+Internal.h"
#import "ATAdManager+Internal.h"
#import "Utilities.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATBannerManager.h"
#import "ATBannerAdapter.h"
#import <objc/runtime.h>
#import "ATPlacementSettingManager.h"
#import "ATAdManager+Banner.h"

@interface ATAdManager(BannerImp)
-(BOOL) bannerReadyForPlacementID:(NSString*)placementID caller:(ATAdManagerReadyAPICaller)caller banner:(ATBanner*__strong*)banner;
@end
@interface ATBanner(RefreshFlag)
@property(nonatomic, getter=isForRefresh) BOOL forRefresh;
@end
static NSString *const kBannerRefreshKey = @"for_refresh";
@implementation ATBanner (RefreshFlag)
-(void) setForRefresh:(BOOL)forRefresh {
    objc_setAssociatedObject(self, (__bridge_retained void*)kBannerRefreshKey, @(forRefresh), OBJC_ASSOCIATION_RETAIN);
}

-(BOOL) isForRefresh {
    return [objc_getAssociatedObject(self, (__bridge_retained void*)kBannerRefreshKey) boolValue];
}
@end

@interface ATBannerView()
@property(nonatomic) ATBanner *banner;
@property(nonatomic, readonly) BOOL removedFromWindow;
@end

static NSUInteger kUnderlineBannerViewTag = 20181208;
@implementation ATBannerView
-(void) dealloc {
    [ATLogger logMessage:@"ATBannerView::ATBannerView dealloc" type:ATLogTypeInternal];
    [[ATAdManager sharedManager] clearAdBeingShownFlagForPlacementID:_banner.placementModel.placementID];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype) initWithFrame:(CGRect)frame banner:(ATBanner*)banner {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.clipsToBounds = YES;
        self.banner = banner;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleModalViewControllerPresentationNotification:) name:kBannerPresentModalViewControllerNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleModalViewControllerDismissalNotification:) name:kBannerDismissModalViewControllerNotification object:nil];
        
        
    }
    return self;
}

-(void) handleModalViewControllerPresentationNotification:(NSNotification*)notification {
    if ([notification.userInfo[kBannerNotificationUserInfoRequestIDKey] isEqualToString:_banner.requestID]) {
        [self terminateAutorefreshProcess];
    }
}

-(void) handleModalViewControllerDismissalNotification:(NSNotification*)notification {
    if ([notification.userInfo[kBannerNotificationUserInfoRequestIDKey] isEqualToString:_banner.requestID]) {
        [self terminateAutorefreshProcess];
        [self startAutorefreshProcessIfNeeded];
    }
}

-(void) setBanner:(ATBanner*)banner {
    if (banner != nil && ![banner.requestID isEqualToString:_banner.requestID]) {
        [ATLogger logMessage:@"ATBannerView::New banner received & will replace previous one" type:ATLogTypeInternal];
        BOOL refresh = banner.isForRefresh;
        if ([self viewWithTag:kUnderlineBannerViewTag] != nil) {
            [ATLogger logMessage:@"Underlieing banner found, will be removed" type:ATLogTypeInternal];
        } else {
            [ATLogger logMessage:@"Underlieing banner not found." type:ATLogTypeInternal];
        }
        [[self viewWithTag:kUnderlineBannerViewTag] removeFromSuperview];
        _banner = banner;
        [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:_banner.placementModel.placementID];
        _banner.customEvent.bannerView = self;
        _banner.customEvent.delegate = _delegate;
        if ([_banner.bannerView isKindOfClass:[UIView class]]) {
            [self addSubview:_banner.bannerView];
            _banner.bannerView.frame = CGRectMake((_banner.customEvent.size.width - CGRectGetWidth(_banner.bannerView.frame)) / 2.0f, (_banner.customEvent.size.height - CGRectGetHeight(_banner.bannerView.frame)) / 2.0f, CGRectGetWidth(_banner.bannerView.frame), CGRectGetHeight(_banner.bannerView.frame));
            _banner.bannerView.tag = kUnderlineBannerViewTag;
        }
        /*
         For some networks(Flurry, for example), banner ad requires special showing method.
         */
        if ([_banner.unitGroup.adapterClass respondsToSelector:@selector(showBanner:inView:presentingViewController:)]) {
            UIView *bannerContainerView = nil;
            if ([self viewWithTag:kUnderlineBannerViewTag] == nil) {
                bannerContainerView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
                bannerContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                bannerContainerView.tag = kUnderlineBannerViewTag;
                [self addSubview:bannerContainerView];
            }
            [_banner.unitGroup.adapterClass showBanner:_banner inView:bannerContainerView presentingViewController:[[_banner.customEvent class] rootViewControllerWithPlacementID:_banner.placementModel.placementID requestID:_banner.requestID]];
        }
        
        //Delegate
        if (refresh) {
            [[ATAdManager sharedManager] bannerReadyForPlacementID:banner.placementModel.placementID caller:ATAdManagerReadyAPICallerShow banner:nil];
            if ([_delegate respondsToSelector:@selector(bannerView:didAutoRefreshWithPlacement:extra:)]) { [_delegate bannerView:self didAutoRefreshWithPlacement:_banner.placementModel.placementID extra:[_banner.customEvent delegateExtra]]; }

        }
        
        [self doADShowingHousekeeping:refresh];
        [[ATBannerManager sharedManager] removeCacheContainingBanner:_banner];
        
        [self startAutorefreshProcessIfNeeded];
    } else {
        [ATLogger logMessage:@"ATBannerView::Banner's the same as the previous one" type:ATLogTypeInternal];
    }
}

-(void) startAutorefreshProcessIfNeeded {
    if (_banner.placementModel.autoRefresh && _banner.placementModel.autoRefreshInterval > .0f) {
        [ATLogger logMessage:[NSString stringWithFormat:@"ATBannerView::AutoRefresh is switched on & will refresh after %ld seconds", (NSInteger)_banner.placementModel.autoRefreshInterval] type:ATLogTypeInternal];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadNext) object:nil];
        [self performSelector:@selector(loadNext) withObject:nil afterDelay:_banner.placementModel.autoRefreshInterval];
    } else {
        [ATLogger logMessage:[NSString stringWithFormat:@"ATBannerView::AutoRefresh is switched off or refresh interval invalid:(%ld)", (NSInteger)_banner.placementModel.autoRefreshInterval] type:ATLogTypeInternal];
    }
}

-(void) terminateAutorefreshProcess {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadNext) object:nil];
}

-(void) handleApplicationDidEnterBackgroundNotification:(NSNotification*)notification {
    [ATLogger logMessage:@"ATBannerView::handleApplicationDidEnterBackgroundNotification:" type:ATLogTypeInternal];
    [self terminateAutorefreshProcess];
}

-(void) handleApplicationDidBecomeActiveNotification:(NSNotification*)notification {
    [ATLogger logMessage:@"ATBannerView::handleApplicationDidBecomeActiveNotification:" type:ATLogTypeInternal];
    [self terminateAutorefreshProcess];
    [self startAutorefreshProcessIfNeeded];
}

-(void) handleLoadNotification:(NSNotification*)noti {
    [ATLogger logMessage:@"ATBannerView::handleLoadNotification:" type:ATLogTypeInternal];
    ATPlacementModel *placementModel = noti.userInfo[kATADLoadingNotificationUserInfoPlacementKey];
    NSDictionary *extra = noti.userInfo[kATADLoadingNotificationUserInfoExtraKey];
    if ([placementModel.placementID isEqualToString:_banner.placementModel.placementID] && (extra == nil || ![extra containsObjectForKey:kAdLoadingExtraRefreshFlagKey])) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadNext) object:nil];
    }
}

-(void) handleLoadSuccessNotification:(NSNotification*)noti {
    [ATLogger logMessage:@"ATBannerView::handleLoadSuccessNotification:" type:ATLogTypeInternal];
    ATBanner *banner = [[ATAdManager sharedManager] offerWithPlacementID:_banner.placementModel.placementID error:nil refresh:NO];
    banner.forRefresh = [noti.userInfo isKindOfClass:[NSDictionary class]] && [noti.userInfo[kAdLoadingExtraRefreshFlagKey] boolValue];
    if (banner != nil && !banner.forRefresh) {
        if ([_delegate respondsToSelector:@selector(bannerView:didShowAdWithPlacementID:extra:)]) { [_delegate bannerView:self didShowAdWithPlacementID:banner.placementModel.placementID extra:[_banner.customEvent delegateExtra]]; }
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{ weakSelf.banner = banner; });
}

-(void) handleLoadFailureNotification:(NSNotification*)noti {
    __weak typeof(self) weakSelf = self;
    [ATLogger logMessage:@"ATBannerView::handleLoadFailureNotification:" type:ATLogTypeInternal];
    ATPlacementModel *placementModel = noti.userInfo[kATADLoadingNotificationUserInfoPlacementKey];
    if ([placementModel.placementID isEqualToString:_banner.placementModel.placementID]) {
        if (_banner.placementModel.autoRefresh && _banner.placementModel.autoRefreshInterval > .0f) {
            [ATLogger logMessage:[NSString stringWithFormat:@"ATBannerView::AutoRefresh is switched on & will refresh after %ld seconds", (NSInteger)_banner.placementModel.autoRefreshInterval] type:ATLogTypeInternal];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(loadNext) withObject:nil afterDelay:weakSelf.banner.placementModel.autoRefreshInterval];
            });
        }
        if (_banner != nil) {
            if ([noti.userInfo[kAdLoadingExtraRefreshFlagKey] boolValue]) {
                if ([_delegate respondsToSelector:@selector(bannerView:failedToAutoRefreshWithPlacementID:error:)]) {
                    [_delegate bannerView:self failedToAutoRefreshWithPlacementID:placementModel.placementID error:noti.userInfo[kATADLoadingNotificationUserInfoErrorKey]];
                }
            }
        }
    }
}

-(void) loadNext {
    [ATLogger logMessage:@"ATBannerView::loadNext" type:ATLogTypeInternal];
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@1, kAdLoadingExtraRefreshFlagKey, [NSValue valueWithCGSize:_banner.customEvent.size], kATAdLoadingExtraBannerAdSizeKey, nil];
    extra[kATAdLoadingExtraBannerSizeAdjustKey] = @(_banner.customEvent.adjustAdSize);
    if (_banner.customEvent.loadingParameters != nil) { extra[kATBannerLoadingExtraParameters] = _banner.customEvent.loadingParameters; }
    if (_banner.customEvent.admobAdSizeValue != nil) { extra[kATAdLoadingExtraAdmobBannerSizeKey] = _banner.customEvent.admobAdSizeValue; }
    extra[kATAdLoadingExtraAdmobAdSizeFlagsKey] = @(_banner.customEvent.admobAdSizeFlags);
    [[ATAdManager sharedManager] loadADWithPlacementID:_banner.placementModel.placementID extra:extra delegate:nil];
}

-(void) loadNextWithoutRefresh {
    [ATLogger logMessage:@"ATBannerView::loadNext" type:ATLogTypeInternal];
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGSize:_banner.customEvent.size], kATAdLoadingExtraBannerAdSizeKey, nil];
    extra[kATAdLoadingExtraBannerSizeAdjustKey] = @(_banner.customEvent.adjustAdSize);
    if (_banner.customEvent.loadingParameters != nil) { extra[kATBannerLoadingExtraParameters] = _banner.customEvent.loadingParameters; }
    if (_banner.customEvent.admobAdSizeValue != nil) { extra[kATAdLoadingExtraAdmobBannerSizeKey] = _banner.customEvent.admobAdSizeValue; }
    extra[kATAdLoadingExtraAdmobAdSizeFlagsKey] = @(_banner.customEvent.admobAdSizeFlags);
    [[ATAdManager sharedManager] loadADWithPlacementID:_banner.placementModel.placementID extra:extra delegate:nil];
}

-(CGSize) intrinsicContentSize {
    return _banner.customEvent.size;
}

-(void) willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow != nil) {
        if (_removedFromWindow) {
            [self handleApplicationDidBecomeActiveNotification:nil];
            _removedFromWindow = NO;
        } else {
            if ([_delegate respondsToSelector:@selector(bannerView:didShowAdWithPlacementID:extra:)]) { [_delegate bannerView:self didShowAdWithPlacementID:_banner.placementModel.placementID extra:[_banner.customEvent delegateExtra]]; }

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadSuccessNotification:) name:kATADLoadingOfferSuccessfullyLoadedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadNotification:) name:kATADLoadingStartLoadNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadFailureNotification:) name:kATADLoadingFailedToLoadNotification object:nil];
        }
    } else {
        _removedFromWindow = YES;
        [ATLogger logMessage:@"ATBannerView::BannerView's being removed from its super view." type:ATLogTypeInternal];
        [self handleApplicationDidEnterBackgroundNotification:nil];
    }
}

-(void) setDelegate:(id<ATBannerDelegate>)delegate {
    _delegate = delegate;
    _banner.customEvent.delegate = _delegate;
}

-(void) setImpressionFlagForRequestID:(NSString*)requestID {
    objc_setAssociatedObject(self, (__bridge_retained void*)(requestID.md5), @YES, OBJC_ASSOCIATION_RETAIN);
}

-(BOOL) impressionFlagForRequestID:(NSString*)requestID {
    return requestID != nil && [objc_getAssociatedObject(self, (__bridge_retained void*)(requestID.md5)) boolValue];
}

-(void) doADShowingHousekeeping:(BOOL)refresh {
    if (_banner != nil && ![self impressionFlagForRequestID:_banner.requestID]) {
        [self setImpressionFlagForRequestID:_banner.requestID];
        _banner.showTimes++;
        self.banner.customEvent.sdkTime = [Utilities normalizedTimeStamp];
        [[ATCapsManager sharedManager] increaseCapWithPlacementID:_banner.placementModel.placementID unitGroupID:_banner.unitGroup.unitGroupID requestID:_banner.requestID];
        [[ATCapsManager sharedManager] setLastShowTimeWithPlacementID:_banner.placementModel.placementID unitGroupID:_banner.unitGroup.unitGroupID];
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(refresh), kATTrackerExtraRefreshFlagKey, @NO, kATTrackerExtraAutoloadFlagKey, @NO, kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.banner requestID:self.banner.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.banner.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.banner.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(self.banner.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey,self.banner.customEvent.sdkTime,kATTrackerExtraAdShowSDKTimeKey, nil];
        if (self.banner.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
        [[ATTracker sharedTracker] trackWithPlacementID:self.banner.placementModel.placementID requestID:self.banner.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];

        [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:_banner event:ATGeneralAdAgentEventTypeImpression extra:refresh ? @{kAdLoadingExtraRefreshFlagKey:@1} : nil error:nil]] type:ATLogTypeTemporary];
    }
}
@end
