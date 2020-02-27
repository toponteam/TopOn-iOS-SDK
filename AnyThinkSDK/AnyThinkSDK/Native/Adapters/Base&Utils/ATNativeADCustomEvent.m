//
//  ATNativeADCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATNativeADCache.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"
#import "ATNativeADView.h"
#import "ATVideoView.h"
#import "ATThreadSafeAccessor.h"
#import "ATAPI.h"
#import "ATLogger.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATLoadingScheduler.h"
#import "ATAdManager+Internal.h"
#import "ATAdCustomEvent.h"
#import "ATAppSettingManager.h"
@interface ATNativeADCustomEvent()
/**
 * For agent event.
 * Some network, mintegral for instance, has to be shown to determine whether or not it contains an video. So this information can't fall into offer model.
 */
@property(nonatomic, readonly, getter=isVideoContents) BOOL videoContents;

@property(nonatomic, readonly) ATThreadSafeAccessor *assetsAccessor;
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* assets_impl;

@property(nonatomic, readonly) ATThreadSafeAccessor *numberOfFinishedRequestsAccessor;
@property(nonatomic, readonly) NSInteger numberOfFinishedRequests_impl;
@end
@implementation ATNativeADCustomEvent
-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _assetsAccessor = [ATThreadSafeAccessor new];
        _assets_impl = [NSMutableArray<NSDictionary*> array];
        
        _numberOfFinishedRequestsAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

-(NSMutableArray<NSDictionary*>*) assets {
    return [_assetsAccessor readWithBlock:^id{ return _assets_impl; }];
}

-(NSInteger) numberOfFinishedRequests {
    return [[_numberOfFinishedRequestsAccessor readWithBlock:^id{ return @(_numberOfFinishedRequests_impl); }] integerValue];
}

-(void) setNumberOfFinishedRequests:(NSInteger)numberOfFinishedRequests {
    [_numberOfFinishedRequestsAccessor writeWithBlock:^{ _numberOfFinishedRequests_impl = numberOfFinishedRequests; }];
}

-(void) handleAssets:(NSDictionary*)assets {
    [self.assets addObject:assets];
    self.numberOfFinishedRequests++;
    [ATLogger logMessage:[NSString stringWithFormat:@"Successfully loaded, event:%@, finishedNumber: %ld, successful loads:%ld, total: %ld", NSStringFromClass([self class]), [self.assets count], self.numberOfFinishedRequests, self.requestNumber] type:ATLogTypeInternal];
    if (self.numberOfFinishedRequests == self.requestNumber) {
        [ATLogger logMessage:@"Request number reached and will invoke callback" type:ATLogTypeInternal];
        self.requestCompletionBlock(self.assets, nil);
    }
}

-(void) handleLoadingFailure:(NSError*)error {
    self.numberOfFinishedRequests++;
    [ATLogger logMessage:[NSString stringWithFormat:@"Loading failed, event:%@, finishedNumber: %ld, successful loads:%ld, total: %ld", NSStringFromClass([self class]), [self.assets count], self.numberOfFinishedRequests, self.requestNumber] type:ATLogTypeInternal];
    if (self.numberOfFinishedRequests == self.requestNumber) {
        [ATLogger logMessage:@"Request number reached and will invoke callback" type:ATLogTypeInternal];
        self.requestCompletionBlock(self.assets, [self.assets count] > 0 ? nil : (error != nil ? error : [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"Third-party network offer loading has failed.", NSLocalizedFailureReasonErrorKey:@"Third-party SDK did not return any offer."}]));
    }
}

-(void) didAttachMediaView {
    
}

-(void) willDetachOffer:(ATNativeADCache*)offer fromAdView:(ATNativeADView*)adView {
    
}

-(void) trackShow:(BOOL)refresh {
    ATNativeADCache *offer = (ATNativeADCache*)self.adView.nativeAd;
    [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:offer.placementModel unitGroup:offer.unitGroup requestID:offer.requestID];
    NSMutableDictionary *generalAdAgentEventExtraInfo = [NSMutableDictionary dictionaryWithDictionary:[ATAgentEvent generalAdAgentInfoWithPlacementModel:offer.placementModel unitGroupModel:offer.unitGroup requestID:offer.requestID]];
    generalAdAgentEventExtraInfo[kGeneralAdAgentEventExtraInfoAutoRequestFlagKey] = [self.requestExtra[kAdLoadingExtraAutoloadFlagKey] boolValue] ? @"1" : @"0";
    [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:offer event:ATGeneralAdAgentEventTypeImpression extra:self.requestExtra error:nil]] type:ATLogTypeTemporary];
    NSDictionary *loadExtra = [self.requestExtra isKindOfClass:[NSDictionary class]] ? self.requestExtra : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:offer.unitGroup requestID:offer.requestID], kATTrackerExtraHeaderBiddingInfoKey, offer.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(offer.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(offer.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    [[ATTracker sharedTracker] trackWithPlacementID:offer.placementModel.placementID requestID:offer.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
}

-(void) trackClick {
    ATNativeADCache *offer = (ATNativeADCache*)self.adView.nativeAd;
    [ATLogger logMessage:[NSString stringWithFormat:@"\nClick with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:offer event:ATGeneralAdAgentEventTypeClick extra:nil error:nil]] type:ATLogTypeTemporary];
    NSMutableDictionary *generalAdAgentEventExtraInfo = [NSMutableDictionary dictionaryWithDictionary:[ATAgentEvent generalAdAgentInfoWithPlacementModel:offer.placementModel unitGroupModel:offer.unitGroup requestID:offer.requestID]];
    generalAdAgentEventExtraInfo[kGeneralAdAgentEventExtraInfoAutoRequestFlagKey] = [self.requestExtra[kAdLoadingExtraAutoloadFlagKey] boolValue] ? @"1" : @"0";
    NSDictionary *loadExtra = [self.requestExtra isKindOfClass:[NSDictionary class]] ? self.requestExtra : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:offer.unitGroup requestID:offer.requestID], kATTrackerExtraHeaderBiddingInfoKey, offer.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(offer.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(offer.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    [[ATTracker sharedTracker] trackClickWithAd:(ATNativeADCache*)self.adView.nativeAd extra:trackingExtra];

}

-(void) trackVideoStart {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    NSDictionary *loadExtra = [self.requestExtra isKindOfClass:[NSDictionary class]] ? self.requestExtra : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:cache.unitGroup requestID:cache.requestID], kATTrackerExtraHeaderBiddingInfoKey, cache.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(cache.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(cache.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    [[ATTracker sharedTracker] trackWithPlacementID:cache.placementModel.placementID requestID:cache.requestID trackType:ATNativeAdTrackTypeVideoStart extra:trackingExtra];
}

-(void) trackVideoEnd {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    NSDictionary *loadExtra = [self.requestExtra isKindOfClass:[NSDictionary class]] ? self.requestExtra : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:cache.unitGroup requestID:cache.requestID], kATTrackerExtraHeaderBiddingInfoKey, cache.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(cache.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(cache.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    [[ATTracker sharedTracker] trackWithPlacementID:cache.placementModel.placementID requestID:cache.requestID trackType:ATNativeAdTrackTypeVideoEnd extra:trackingExtra];
}

-(ATNativeADSourceType) sourceType {
    return self.isVideoContents ? ATNativeADSourceTypeVideo : ATNativeADSourceTypeImage;
}

-(BOOL) isVideoContents {
    return self.adView.isVideoContents;
}
@end
