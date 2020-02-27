//
//  ATAdCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATThreadSafeAccessor.h"
#import "Utilities.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATAgentEvent.h"
#import "ATCapsManager.h"
#import "ATAdAdapter.h"
#import "ATLoadingScheduler.h"
#import "ATPlacementSettingManager.h"
#import "ATAdLoader.h"
#import "ATAdManager+Internal.h"

NSString *const kSDKImportIssueErrorReason = @"This might be due to %@ SDK not being imported or it's imported but a unsupported version is being used.";
NSString *const kSDKImportIssueRecoverySuggestionKey = @"Make sure %@ are correctly imported.";
NSString *const kATAdAssetsAppIDKey = @"app_id";
@interface ATAdCustomEvent()
@property(nonatomic, readonly) ATThreadSafeAccessor *assetsAccessor;
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* assets_impl;

@property(nonatomic, readonly) ATThreadSafeAccessor *numberOfFinishedRequestsAccessor;
@property(nonatomic, readonly) NSInteger numberOfFinishedRequests_impl;
@end
@implementation ATAdCustomEvent
+(NSDictionary*)customInfoWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary*)extra {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:unitGroupModel.content];
    info[kAdapterCustomInfoExtraKey] = @{kAdLoadingExtraFilledByReadyFlagKey:@YES};
    return info;
}

-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo {
    self = [super init];
    if (self != nil) {
        _assetsAccessor = [ATThreadSafeAccessor new];
        _assets_impl = [NSMutableArray<NSDictionary*> array];
        _numberOfFinishedRequestsAccessor = [ATThreadSafeAccessor new];
        
        _customInfo = customInfo;
    }
    return self;
}

-(NSMutableArray<NSDictionary*>*) assets {
    return [_assetsAccessor readWithBlock:^id{ return _assets_impl; }];
}

-(void) setRequestNumber:(NSInteger)requestNumber {
    _requestNumber = requestNumber;
    self.numberOfFinishedRequests = 0;
}

-(NSInteger) numberOfFinishedRequests {
    return [[_numberOfFinishedRequestsAccessor readWithBlock:^id{ return @(_numberOfFinishedRequests_impl); }] integerValue];
}

-(void) setNumberOfFinishedRequests:(NSInteger)numberOfFinishedRequests {
    [_numberOfFinishedRequestsAccessor writeWithBlock:^{ _numberOfFinishedRequests_impl = numberOfFinishedRequests; }];
}

+(NSInteger) calculateAdPriority:(id<ATAd>)ad {
    NSArray<ATUnitGroupModel*>* ugs = [ad.placementModel unitGroupsForRequestID:ad.requestID];
    ugs = [ugs count] > 0 ? ugs : ad.placementModel.unitGroups;
    
    return [ugs indexOfObject:ad.unitGroup];;
}

-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeUnknown;
}

-(void) trackShow {
    if (self.ad != nil) {
        [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:self.ad.placementModel unitGroup:self.ad.unitGroup requestID:self.ad.requestID];
        [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.ad event:ATGeneralAdAgentEventTypeImpression extra:self.customInfo[kAdapterCustomInfoExtraKey] error:nil]] type:ATLogTypeTemporary];
        [[ATCapsManager sharedManager] increaseCapWithPlacementID:self.ad.placementModel.placementID unitGroupID:self.ad.unitGroup.unitGroupID requestID:self.ad.requestID];
        [[ATCapsManager sharedManager] setLastShowTimeWithPlacementID:self.ad.placementModel.placementID unitGroupID:self.ad.unitGroup.unitGroupID];
        
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.ad.unitGroup requestID:self.ad.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.ad.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.ad.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(self.ad.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        [[ATTracker sharedTracker] trackWithPlacementID:self.ad.placementModel.placementID requestID:self.ad.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
    }
}

-(void) trackClick {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nClick with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.ad event:ATGeneralAdAgentEventTypeClick extra:self.customInfo[kAdapterCustomInfoExtraKey] error:nil]] type:ATLogTypeTemporary];
    NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.ad.unitGroup requestID:self.ad.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.ad.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.ad.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, nil];
//    [[ATTracker sharedTracker] trackWithPlacementID:self.ad.placementModel.placementID requestID:self.ad.requestID trackType:ATNativeADTrackTypeADClicked extra:trackingExtra];
    [[ATTracker sharedTracker]trackClickWithAd:self.ad extra:trackingExtra];
}

-(void) handleAssets:(NSDictionary*)assets {
    [self.assets addObject:assets];
    self.numberOfFinishedRequests++;
    [ATLogger logMessage:[NSString stringWithFormat:@"Successfully loaded, event:%@, finishedNumber: %ld, successful loads:%ld, total: %ld", NSStringFromClass([self class]), [self.assets count], self.numberOfFinishedRequests, self.requestNumber] type:ATLogTypeInternal];
    if (self.numberOfFinishedRequests == self.requestNumber) {
        [ATLogger logMessage:@"Request number reached and will invoke callback" type:ATLogTypeInternal];
        if (self.requestCompletionBlock != nil) { self.requestCompletionBlock([NSArray arrayWithArray:self.assets], nil); }
        [self.assets removeAllObjects];
        [ATLogger logMessage:@"Remove assets after invoke the completion block" type:ATLogTypeInternal];
    }
}

-(void) handleLoadingFailure:(NSError*)error {
    self.numberOfFinishedRequests++;
    [ATLogger logMessage:[NSString stringWithFormat:@"Loading failed, event:%@, finishedNumber: %ld, successful loads:%ld, total: %ld", NSStringFromClass([self class]), [self.assets count], self.numberOfFinishedRequests, self.requestNumber] type:ATLogTypeInternal];
    if (self.numberOfFinishedRequests == self.requestNumber) {
        [ATLogger logMessage:@"Request number reached and will invoke callback" type:ATLogTypeInternal];
        if (self.requestCompletionBlock != nil) {
            self.requestCompletionBlock(self.assets, [self.assets count] > 0 ? nil : (error != nil ? error : [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"Third-party network offer loading has failed.", NSLocalizedFailureReasonErrorKey:@"Third-party SDK did not return any offer."}]));
        }
    }
}

-(void) handleClose {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nClose with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.ad event:ATGeneralAdAgentEventTypeClose extra:nil error:nil]] type:ATLogTypeTemporary];
}
@end
