//
//  ATNativeADView.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 18/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADView.h"
#import "ATPlacementSettingManager.h"
#import "ATNativeADOfferManager.h"
#import "ATNativeADCache.h"
#import "ATPlacementModel.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATTracker.h"
#import "ATNativeADRenderer.h"
#import "ATNativeADView+Internal.h"
#import "ATNativeADCustomEvent.h"
#import "ATAdManager+Internal.h"
#import "ATNativeADDelegate.h"
#import "ATNativeADConfiguration.h"
#import "ATNativeRenderer.h"
#import "ATCapsManager.h"
#import "ATNativeADDelegate.h"
#import "ATAdManager.h"
#import "ATNativeADOfferManager.h"

NSString const* kATExtraNativeImageSize228_150 = @"image_size_228_150";
NSString const* kATExtraNativeImageSize690_388 = @"image_size_690_388";
NSString *const kATExtraNativeImageSizeKey = @"native_image_size";

@interface ATNativeADView()
@property(nonatomic, readonly) ATNativeADConfiguration *configuration;
@property(nonatomic, readonly) ATNativeRenderer *renderer;
@property(nonatomic, readonly) NSString *placementID;
@property(nonatomic) ATNativeADCache *currentOffer;
@property(nonatomic) BOOL offerHasBeenRefreshed;
@property(nonatomic) NSString *previousImpressionID;
@end
@implementation ATNativeADView
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype) initWithConfiguration:(ATNativeADConfiguration*)configuration placementID:(NSString*)placementID {
    self = [super initWithFrame:configuration.ADFrame];
    if (self != nil) {
        _configuration = configuration;
        _placementID = placementID;
        _delegate = _configuration.delegate;
        NSError *error = nil;
        if (![self updateCurrentCache:&error refresh:NO]) {
            [ATLogger logError:@"Cache not found" type:ATLogTypeInternal];
            [self onLoadingFailure:error];
        } else {
            [ATLogger logMessage:@"Cache updated" type:ATLogTypeInternal];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleADLoadNotification:) name:kATADLoadingOfferSuccessfullyLoadedNotification object:nil];
            
            [self initSubviews];
            [self makeConstraintsForSubviews];
            
            if ([[_currentOffer.unitGroup.adapterClass rendererClass] retrieveRendererWithOffer:_currentOffer] != nil) {
                [ATLogger logMessage:@"Handler mopub" type:ATLogTypeInternal];
                //For Mopub
                _renderer = [[_currentOffer.unitGroup.adapterClass rendererClass] retrieveRendererWithOffer:_currentOffer];
                _renderer.ADView = self;
                [((NSObject*)_renderer) setValue:_configuration forKey:@"configuration"];
                [self attachMediaView];
                return (ATNativeADView*)self.superview;//Cast away the warning but the view being returned might not be an instance of ATNativeADView.
            } else {
                [ATLogger logMessage:@"handle other occations" type:ATLogTypeInternal];
                _renderer = [[[_currentOffer.unitGroup.adapterClass rendererClass] alloc] initWithConfiguraton:_configuration adView:self];
            }
            [self attachMediaView];
        }
    }
    return self;
}

-(ATNativeADView*)embededAdView {
    return self;
}

-(void) initSubviews {
}

-(void) makeConstraintsForSubviews {
}

//Default implementation just layouts the media view so it covers all the ad view's bounds.
-(void) layoutMediaView {
    _mediaView.frame = self.bounds;
}

-(void) attachMediaView {
    [_mediaView removeFromSuperview];
    UIView *mediaView = [_renderer createMediaView];
    if (mediaView != nil) {
        _mediaView = mediaView;
        [self addSubview:mediaView];
        [self layoutMediaView];
        [self.customEvent didAttachMediaView];
    }
}

-(void) onLoadingFailure:(NSError*)error {
    if ([_delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
        [_delegate didFailToLoadADWithPlacementID:_placementID error:error];
    }
}

-(void) handleADLoadNotification:(NSNotification*)notification {
    [ATLogger logMessage:@"Receive ad loaded notification" type:ATLogTypeInternal];
    NSString *newOfferRequestID = notification.userInfo[kATADLoadingNotificationUserInfoRequestIDKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_currentOffer != nil && [newOfferRequestID isEqualToString:_currentOffer.requestID] && self.customEvent != nil) { [self.customEvent willDetachOffer:_currentOffer fromAdView:self]; }
        [ATLogger logMessage:@"handleADLoadNotification" type:ATLogTypeInternal];
        ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:_placementID];
        if ([_currentOffer.requestID isEqualToString:newOfferRequestID] && placementModel.refresh && !_offerHasBeenRefreshed) {
            [ATLogger logMessage:@"need refresh & has not been refreshed" type:ATLogTypeInternal];
            if ([self updateCurrentCache:nil refresh:YES]) {
                [ATLogger logMessage:@"update cache successfully" type:ATLogTypeInternal];
                _offerHasBeenRefreshed = YES;
                
                if ([[_currentOffer.unitGroup.adapterClass rendererClass] retrieveRendererWithOffer:_currentOffer] != nil) {
                    //For Mopub
                    _renderer = [[_currentOffer.unitGroup.adapterClass rendererClass] retrieveRendererWithOffer:_currentOffer];
                    _renderer.ADView = self;
                    [((NSObject*)_renderer) setValue:_configuration forKey:@"configuration"];
                    UIView *superView = self.superview;
                    UIView *adView = [_renderer retriveADView];
                    [superView addSubview:adView];
                    [self.mediaView removeFromSuperview];
                    [self attachMediaView];
                    [_renderer renderOffer:_currentOffer];
                    [self doADShowingHousekeeping:YES];
                } else {
                    _renderer = [[[_currentOffer.unitGroup.adapterClass rendererClass] alloc] initWithConfiguraton:_configuration adView:self];
                    [self attachMediaView];
                    [ATLogger logMessage:[NSString stringWithFormat:@"before rendering offer:%@, renderer:%@", _currentOffer, _renderer] type:ATLogTypeInternal];
                    [_renderer renderOffer:_currentOffer];
                    [self doADShowingHousekeeping:YES];
                }
            }
        } else {
            [ATLogger logMessage:[NSString stringWithFormat:@"no need to refresh, refresh:%@, hasRefreshed:%@", placementModel.refresh ? @"YES" : @"NO", _offerHasBeenRefreshed ? @"YES" : @"NO"] type:ATLogTypeInternal];
        }
    });
}

-(ATNativeAd*)nativeAd {
    return _currentOffer;
}

/**
 * Client -> view.isVideoContents, view -> renderer.isVideoContents, render -> view -> offer/mediaView.isVideoContents
 */
-(BOOL) isVideoContents {
    return [_renderer isVideoContents];
}

/**
 * Return YES if update successfully, otherwise return NO.
 */
-(BOOL) updateCurrentCache:(NSError**)error refresh:(BOOL)refresh {
    [ATLogger logMessage:@"will update current offer" type:ATLogTypeInternal];
    BOOL successful = NO;
    ATNativeADCache *cache = [[ATAdManager sharedManager] offerWithPlacementID:_placementID error:error refresh:refresh];
    [ATLogger logMessage:@"Try to retrieve newly returned offer" type:ATLogTypeInternal];
    if (cache != nil && ![cache.unitGroup.unitGroupID isEqualToString:_currentOffer.unitGroup.unitGroupID]) {
        [ATLogger logMessage:@"Newly returned offer retrieved and will replace the old offer" type:ATLogTypeInternal];
        _currentOffer = cache;
        successful = YES;
    } else {
        [ATLogger logMessage:[NSString stringWithFormat:@"offer has not been updated, current unit group id:%@, new cache unit group id:%@", _currentOffer.unitGroup.unitGroupID, cache.unitGroup.unitGroupID] type:ATLogTypeInternal];
    }
    return successful;
}

-(void) willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow != nil) {
        if (_currentOffer != nil) {
            [_renderer renderOffer:_currentOffer];
            [self doADShowingHousekeeping:NO];
        }
    }
}

-(NSString*)impressionIDWithOffer:(ATNativeADCache*)cache {
    return [NSString stringWithFormat:@"%@%@%@", cache.placementModel.placementID, cache.unitGroup.unitGroupID, cache.requestID].md5;
}

-(void) doADShowingHousekeeping:(BOOL)refresh {
    if (_currentOffer != nil && ![self.previousImpressionID isEqualToString:[self impressionIDWithOffer:_currentOffer]]) {
        self.previousImpressionID = [self impressionIDWithOffer:_currentOffer];
        _currentOffer.showTimes++;
        
        if ([[ATNativeADOfferManager sharedManager] offerExhaustedInPlacementID:_currentOffer.placementModel.placementID unitGroupID:_currentOffer.unitGroup.unitGroupID]) {
            [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:_currentOffer.placementModel.placementID];
            [[ATCapsManager sharedManager] setShowFlagForPlacementID:_currentOffer.placementModel.placementID requestID:_currentOffer.requestID];
        }
        [[ATCapsManager sharedManager] increaseCapWithPlacementID:_placementID unitGroupID:_currentOffer.unitGroup.unitGroupID requestID:_currentOffer.requestID];
        [[ATCapsManager sharedManager] setLastShowTimeWithPlacementID:_placementID unitGroupID:_currentOffer.unitGroup.unitGroupID];
        
        //Tracking
        [self.customEvent trackShow:refresh];
        
        //Notify delegate
        if ([_delegate respondsToSelector:@selector(didShowNativeAdInAdView:placementID:extra:)]) {
            [_delegate didShowNativeAdInAdView:[self embededAdView] placementID:_placementID extra:@{kATNativeDelegateExtraNetworkIDKey:@(self.currentOffer.unitGroup.networkFirmID),kATNativeDelegateExtraAdSourceIDKey:self.currentOffer.unitGroup.unitID != nil ? self.currentOffer.unitGroup.unitID : @"",kATNativeDelegateExtraIsHeaderBidding:@(self.currentOffer.unitGroup.headerBidding),kATNativeDelegateExtraPriority:@(self.currentOffer.priorityIndex),kATNativeDelegateExtraPrice:@(self.currentOffer.unitGroup.price)}];
        }
    }
   
}

-(NSArray<UIView*>*)clickableViews {
    return @[self];
}

#pragma mark - internal
-(void) notifyNativeAdClick {
    if ([self.delegate respondsToSelector:@selector(didClickNativeAdInAdView:placementID:extra:)]) { [self.delegate didClickNativeAdInAdView:self placementID:_placementID extra:@{kATNativeDelegateExtraNetworkIDKey:@(self.currentOffer.unitGroup.networkFirmID),kATNativeDelegateExtraAdSourceIDKey:self.currentOffer.unitGroup.unitID != nil ? self.currentOffer.unitGroup.unitID : @"",kATNativeDelegateExtraIsHeaderBidding:@(self.currentOffer.unitGroup.headerBidding),kATNativeDelegateExtraPriority:@(self.currentOffer.priorityIndex),kATNativeDelegateExtraPrice:@(self.currentOffer.unitGroup.price)}];
    }

}

-(void) notifyCloseButtonTapped {
    if ([self.delegate respondsToSelector:@selector(didTapCloseButtonInAdView:placementID:extra:)]) { [self.delegate didTapCloseButtonInAdView:self placementID:_placementID extra:@{kATNativeDelegateExtraNetworkIDKey:@(self.currentOffer.unitGroup.networkFirmID),kATNativeDelegateExtraAdSourceIDKey:self.currentOffer.unitGroup.unitID != nil ? self.currentOffer.unitGroup.unitID : @"",kATNativeDelegateExtraIsHeaderBidding:@(self.currentOffer.unitGroup.headerBidding),kATNativeDelegateExtraPriority:@(self.currentOffer.priorityIndex),kATNativeDelegateExtraPrice:@(self.currentOffer.unitGroup.price)}];
    }
}

-(void) notifyVideoStart {
    if ([self.delegate respondsToSelector:@selector(didStartPlayingVideoInAdView:placementID:extra:)]) { [self.delegate didStartPlayingVideoInAdView:self placementID:_placementID extra:@{kATNativeDelegateExtraNetworkIDKey:@(self.currentOffer.unitGroup.networkFirmID),kATNativeDelegateExtraAdSourceIDKey:self.currentOffer.unitGroup.unitID != nil ? self.currentOffer.unitGroup.unitID : @"",kATNativeDelegateExtraIsHeaderBidding:@(self.currentOffer.unitGroup.headerBidding),kATNativeDelegateExtraPriority:@(self.currentOffer.priorityIndex),kATNativeDelegateExtraPrice:@(self.currentOffer.unitGroup.price)}];
    }

}

-(void) notifyVideoEnd {
    if ([self.delegate respondsToSelector:@selector(didEndPlayingVideoInAdView:placementID:extra:)]) { [self.delegate didEndPlayingVideoInAdView:self placementID:_placementID extra:@{kATNativeDelegateExtraNetworkIDKey:@(self.currentOffer.unitGroup.networkFirmID),kATNativeDelegateExtraAdSourceIDKey:self.currentOffer.unitGroup.unitID != nil ? self.currentOffer.unitGroup.unitID : @"",kATNativeDelegateExtraIsHeaderBidding:@(self.currentOffer.unitGroup.headerBidding),kATNativeDelegateExtraPriority:@(self.currentOffer.priorityIndex),kATNativeDelegateExtraPrice:@(self.currentOffer.unitGroup.price)}];
    }

    
}

-(void) notifyVideoEnterFullScreen {
    if ([self.delegate respondsToSelector:@selector(didEnterFullScreenVideoInAdView:placementID: extra:)]) { [self.delegate didEnterFullScreenVideoInAdView:self placementID:_placementID extra:@{kATNativeDelegateExtraNetworkIDKey:@(self.currentOffer.unitGroup.networkFirmID),kATNativeDelegateExtraAdSourceIDKey:self.currentOffer.unitGroup.unitID != nil ? self.currentOffer.unitGroup.unitID : @"",kATNativeDelegateExtraIsHeaderBidding:@(self.currentOffer.unitGroup.headerBidding),kATNativeDelegateExtraPriority:@(self.currentOffer.priorityIndex),kATNativeDelegateExtraPrice:@(self.currentOffer.unitGroup.price)}];
    }

}

-(void) notifyVideoExitFullScreen {
    if ([self.delegate respondsToSelector:@selector(didExitFullScreenVideoInAdView:placementID:extra:)]) { [self.delegate didExitFullScreenVideoInAdView:self placementID:_placementID extra:@{kATNativeDelegateExtraNetworkIDKey:@(self.currentOffer.unitGroup.networkFirmID),kATNativeDelegateExtraAdSourceIDKey:self.currentOffer.unitGroup.unitID != nil ? self.currentOffer.unitGroup.unitID : @"",kATNativeDelegateExtraIsHeaderBidding:@(self.currentOffer.unitGroup.headerBidding),kATNativeDelegateExtraPriority:@(self.currentOffer.priorityIndex),kATNativeDelegateExtraPrice:@(self.currentOffer.unitGroup.price)}];
    }

}
@end
