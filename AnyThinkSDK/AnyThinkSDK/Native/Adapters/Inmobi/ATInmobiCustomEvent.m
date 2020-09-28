//
//  ATInmobiCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 24/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiCustomEvent.h"
#import "ATInmobiNativeAdapter.h"
#import "ATNativeADCache.h"
#import "ATUnitGroupModel.h"
#import "ATAPI+Internal.h"
#import "ATTracker.h"
#import "ATAgentEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATNativeADView+Internal.h"
#import "ATNativeADOfferManager.h"
#import "ATPlacementModel.h"
#import "ATLogger.h"
#import <objc/runtime.h>

static NSString *const kGestureRecognizerKey = @"gesture_recognizer";

@interface ATInmobiCustomEvent()
@property(nonatomic, readonly) BOOL clickHandled;
@property(nonatomic, readonly) BOOL interacted;
@end
@implementation ATInmobiCustomEvent
-(void)nativeDidFinishLoading:(id<ATIMNative>)native{
    [ATLogger logMessage:@"InmobiNative::nativeDidFinishLoading" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:native, kAdAssetsCustomObjectKey, self.unitID, kNativeADAssetsUnitIDKey, nil];
    if (native.adIcon != nil) { assets[kNativeADAssetsIconImageKey] = native.adIcon; }
    if ([native.adTitle length] > 0) { assets[kNativeADAssetsMainTitleKey] = native.adTitle; }
    if ([native.adDescription length] > 0) { assets[kNativeADAssetsMainTextKey] = native.adDescription; }
    if ([native.adCtaText length] > 0) { assets[kNativeADAssetsCTATextKey] = native.adCtaText; }
    if ([native.adRating length] > 0) { assets[kNativeADAssetsRatingKey] = [NSNumber numberWithDouble:[native.adRating doubleValue]]; }
    
    [self trackNativeAdLoaded:assets];
}

-(void)native:(id<ATIMNative>)native didFailToLoadWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiNative::native:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [ATLogger logError:[NSString stringWithFormat:@"Inmobi has failed to load offer, error: %@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)native:(id<ATIMNative>)native didInteractWithParams:(NSDictionary *)params {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiNative::native:didInteractWithParams:%@", params] type:ATLogTypeExternal];
    [self handleClick];
    _interacted = YES;
    if (_clickHandled) { _clickHandled = NO; }
}

-(void) didAttachMediaView {
    id<ATIMNative> native = ((ATNativeADCache*)self.adView.nativeAd).customObject;
    NSArray<UIView*>* clickableViews = self.adView.clickableViews;
    if ([native isKindOfClass:NSClassFromString(@"IMNative")]) {//For refresh
        [clickableViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:native action:@selector(reportAdClickAndOpenLandingPage)];
            [obj addGestureRecognizer:tap];
            objc_setAssociatedObject(obj, (__bridge_retained void*)kGestureRecognizerKey, tap, OBJC_ASSOCIATION_RETAIN);
        }];
    }
}

-(void) willDetachOffer:(ATNativeADCache*)offer fromAdView:(ATNativeADView*)adView {
    NSArray<UIView*>* clickableViews = self.adView.clickableViews;
    [clickableViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIGestureRecognizer *gr = objc_getAssociatedObject(obj, (__bridge_retained void*)kGestureRecognizerKey);
        if (gr !=  nil) { [obj removeGestureRecognizer:gr]; }
    }];
}

- (void)nativeAdImpressed:(id<ATIMNative>)native {
    [ATLogger logMessage:@"InmobiNative::nativeAdImpressed" type:ATLogTypeExternal];
    //Impression will be tracked within the base ad view
}

- (void)nativeDidDismissScreen:(id<ATIMNative>)native {
    [ATLogger logMessage:@"InmobiNative::nativeDidDismissScreen" type:ATLogTypeExternal];
}

- (void)nativeDidFinishPlayingMedia:(id<ATIMNative>)native {
    [ATLogger logMessage:@"InmobiNative::nativeDidFinishPlayingMedia" type:ATLogTypeExternal];
    [self trackNativeAdVideoEnd];
}

- (void)nativeDidPresentScreen:(id<ATIMNative>)native {
    [ATLogger logMessage:@"InmobiNative::nativeDidPresentScreen" type:ATLogTypeExternal];
    [self handleClick];
}

- (void)nativeWillDismissScreen:(id<ATIMNative>)native {
    [ATLogger logMessage:@"InmobiNative::nativeWillDismissScreen" type:ATLogTypeExternal];
}

- (void)nativeWillPresentScreen:(id<ATIMNative>)native {
    [ATLogger logMessage:@"InmobiNative::nativeWillPresentScreen" type:ATLogTypeExternal];
}

- (void)userDidSkipPlayingMediaFromNative:(id<ATIMNative>)native {
    [ATLogger logMessage:@"InmobiNative::userDidSkipPlayingMediaFromNative" type:ATLogTypeExternal];
}

- (void)userWillLeaveApplicationFromNative:(id<ATIMNative>)native {
    [ATLogger logMessage:@"InmobiNative::userWillLeaveApplicationFromNative" type:ATLogTypeExternal];
    _clickHandled = YES;
    [self handleClick];
    if (_interacted) { _interacted = NO; }
}

-(ATNativeADSourceType) sourceType {
    return ATNativeADSourceTypeUnknown;
}

-(void) handleClick {
    if (!_interacted || !_clickHandled) {
        [self trackNativeAdClick];
    }
}

- (NSString *)networkUnitId {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    return cache.unitGroup.content[@"unit_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"unit_id"];
//    return extra;
//}
@end
