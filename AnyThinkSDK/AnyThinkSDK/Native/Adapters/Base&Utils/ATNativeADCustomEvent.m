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
#import "NSString+KAKit.h"
#import "ATAPI.h"
#import "ATLogger.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATLoadingScheduler.h"
#import "ATAdManager+Internal.h"
#import "ATAdCustomEvent.h"
#import "Utilities.h"
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

-(void) trackNativeAdLoaded:(NSDictionary*)assets {
    [self.assets addObject:assets];
    self.numberOfFinishedRequests++;
    [ATLogger logMessage:[NSString stringWithFormat:@"Successfully loaded, event:%@, finishedNumber: %ld, successful loads:%ld, total: %ld", NSStringFromClass([self class]), [self.assets count], self.numberOfFinishedRequests, self.requestNumber] type:ATLogTypeInternal];
    if (self.numberOfFinishedRequests == self.requestNumber) {
        [ATLogger logMessage:@"Request number reached and will invoke callback" type:ATLogTypeInternal];
        self.requestCompletionBlock(self.assets, nil);
    }
}

-(void) trackNativeAdLoadFailed:(NSError*)error {
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

-(void) trackNativeAdShow:(BOOL)refresh {
    ATNativeADCache *offer = (ATNativeADCache*)self.adView.nativeAd;
    [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:offer.placementModel unitGroup:offer.unitGroup requestID:offer.requestID];
//    offer.sdkTime = [Utilities normalizedTimeStamp];
    NSMutableDictionary *generalAdAgentEventExtraInfo = [NSMutableDictionary dictionaryWithDictionary:[ATAgentEvent generalAdAgentInfoWithPlacementModel:offer.placementModel unitGroupModel:offer.unitGroup requestID:offer.requestID]];
    generalAdAgentEventExtraInfo[kGeneralAdAgentEventExtraInfoAutoRequestFlagKey] = [self.requestExtra[kAdLoadingExtraAutoloadFlagKey] boolValue] ? @"1" : @"0";
    [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:offer event:ATGeneralAdAgentEventTypeImpression extra:self.requestExtra error:nil]] type:ATLogTypeTemporary];
    NSDictionary *loadExtra = [self.requestExtra isKindOfClass:[NSDictionary class]] ? self.requestExtra : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:offer requestID:offer.requestID], kATTrackerExtraHeaderBiddingInfoKey, offer.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(offer.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(offer.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey,offer.sdkTime,kATTrackerExtraAdShowSDKTimeKey,nil];
    if (offer.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
    [[ATTracker sharedTracker] trackWithPlacementID:offer.placementModel.placementID requestID:offer.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
}

-(void) trackNativeAdClick {
    ATNativeADCache *offer = (ATNativeADCache*)self.adView.nativeAd;
    [ATLogger logMessage:[NSString stringWithFormat:@"\nClick with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:offer event:ATGeneralAdAgentEventTypeClick extra:nil error:nil]] type:ATLogTypeTemporary];
    NSMutableDictionary *generalAdAgentEventExtraInfo = [NSMutableDictionary dictionaryWithDictionary:[ATAgentEvent generalAdAgentInfoWithPlacementModel:offer.placementModel unitGroupModel:offer.unitGroup requestID:offer.requestID]];
    generalAdAgentEventExtraInfo[kGeneralAdAgentEventExtraInfoAutoRequestFlagKey] = [self.requestExtra[kAdLoadingExtraAutoloadFlagKey] boolValue] ? @"1" : @"0";
    NSDictionary *loadExtra = [self.requestExtra isKindOfClass:[NSDictionary class]] ? self.requestExtra : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:offer requestID:offer.requestID], kATTrackerExtraHeaderBiddingInfoKey, offer.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(offer.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(offer.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    if (offer.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
    [[ATTracker sharedTracker] trackClickWithAd:(ATNativeADCache*)self.adView.nativeAd extra:trackingExtra];

    [self.adView notifyNativeAdClick];
}

-(void) trackNativeAdVideoStart {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    NSDictionary *loadExtra = [self.requestExtra isKindOfClass:[NSDictionary class]] ? self.requestExtra : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:cache requestID:cache.requestID], kATTrackerExtraHeaderBiddingInfoKey, cache.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(cache.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(cache.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    if (cache.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
    [[ATTracker sharedTracker] trackWithPlacementID:cache.placementModel.placementID requestID:cache.requestID trackType:ATNativeAdTrackTypeVideoStart extra:trackingExtra];
    
     [self.adView notifyVideoStart];
}

-(void) trackNativeAdVideoEnd {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    NSDictionary *loadExtra = [self.requestExtra isKindOfClass:[NSDictionary class]] ? self.requestExtra : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:cache requestID:cache.requestID], kATTrackerExtraHeaderBiddingInfoKey, cache.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(cache.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(cache.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    if (cache.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
    [[ATTracker sharedTracker] trackWithPlacementID:cache.placementModel.placementID requestID:cache.requestID trackType:ATNativeAdTrackTypeVideoEnd extra:trackingExtra];
    
     [self.adView notifyVideoEnd];
}

-(void) trackNativeAdClosed {
    [self.adView notifyCloseButtonTapped];
}
-(ATNativeADSourceType) sourceType {
    return self.isVideoContents ? ATNativeADSourceTypeVideo : ATNativeADSourceTypeImage;
}

-(BOOL) isVideoContents {
    return self.adView.isVideoContents;
}

-(NSDictionary*)delegateExtra {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATNativeDelegateExtraNetworkIDKey:@(cache.unitGroup.networkFirmID),kATNativeDelegateExtraAdSourceIDKey:cache.unitGroup.unitID != nil ? cache.unitGroup.unitID : @"",kATNativeDelegateExtraIsHeaderBidding:@(cache.unitGroup.headerBidding),kATNativeDelegateExtraPriority:@(cache.priorityIndex),kATNativeDelegateExtraPrice:@([cache.price doubleValue]), kATADDelegateExtraECPMLevelKey:@(cache.unitGroup.ecpmLevel), kATADDelegateExtraSegmentIDKey:@(cache.placementModel.groupID)}];
    
    NSString *channel = [ATAPI sharedInstance].channel;
    if (channel != nil) { extra[kATADDelegateExtraChannelKey] = channel; }
    NSString *subchannel = [ATAPI sharedInstance].subchannel;
    if (subchannel != nil) { extra[kATADDelegateExtraSubChannelKey] = subchannel; }
    if ([cache.placementModel.associatedCustomData count] > 0) { extra[kATADDelegateExtraCustomRuleKey] = cache.placementModel.associatedCustomData; }
    NSString *extraID = [NSString stringWithFormat:@"%@_%@_%@",cache.requestID,cache.unitGroup.unitID,self.sdkTime];
    extra[kATADDelegateExtraIDKey] = extraID;
    extra[kATADDelegateExtraAdunitIDKey] = cache.placementModel.placementID;
    extra[kATADDelegateExtraPublisherRevenueKey] = @([cache.price doubleValue] / 1000.f);
     extra[kATADDelegateExtraCurrencyKey] = cache.placementModel.callback[@"currency"];
    extra[kATADDelegateExtraCountryKey] = cache.placementModel.callback[@"cc"];
    extra[kATADDelegateExtraFormatKey] = @"Native";
    extra[kATADDelegateExtraPrecisionKey] = cache.unitGroup.precision;
    extra[kATADDelegateExtraNetworkTypeKey] = cache.unitGroup.networkFirmID == 35 ? @"Cross_promotion":@"Network";
    
    //add adsource unit_id value
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.networkUnitId != nil ? self.networkUnitId:@"";
    return extra;
}
@end
