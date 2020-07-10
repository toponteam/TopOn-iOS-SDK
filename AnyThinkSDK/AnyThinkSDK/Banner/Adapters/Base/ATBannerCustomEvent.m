//
//  ATBannerCustomEvent.m
//  AnyThinkBanner
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerCustomEvent.h"
#import "ATTracker.h"
#import "ATCapsManager.h"
#import "ATBanner.h"
#import "ATAdManager+Internal.h"
#import "Utilities.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Banner.h"

@implementation ATBannerCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo{
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        self.requestNumber = 1;
        self.priorityIndex = [ATAdCustomEvent calculateAdPriority:self.ad];
        _unitID = unitID;
        _size = [customInfo[kAdapterCustomInfoExtraKey][kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [customInfo[kAdapterCustomInfoExtraKey][kATAdLoadingExtraBannerAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 50.0f);
        
    }
    return self;
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATBannerDelegateExtraNetworkIDKey:@(self.banner.unitGroup.networkFirmID), kATBannerDelegateExtraAdSourceIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"",kATBannerDelegateExtraIsHeaderBidding:@(self.banner.unitGroup.headerBidding),kATBannerDelegateExtraPriority:@(self.priorityIndex),kATBannerDelegateExtraPrice:@(self.banner.unitGroup.price), kATADDelegateExtraECPMLevelKey:@(self.banner.unitGroup.ecpmLevel), kATADDelegateExtraSegmentIDKey:@(self.banner.placementModel.groupID)}];
    NSString *channel = [ATAPI sharedInstance].channel;
    if (channel != nil) { extra[kATADDelegateExtraChannelKey] = channel; }
    NSString *subchannel = [ATAPI sharedInstance].subchannel;
    if (subchannel != nil) { extra[kATADDelegateExtraSubChannelKey] = subchannel; }
    if ([self.banner.placementModel.associatedCustomData count] > 0) { extra[kATADDelegateExtraCustomRuleKey] = self.banner.placementModel.associatedCustomData; }
    NSString *extraID = [NSString stringWithFormat:@"%@%@%@",self.banner.requestID,self.banner.unitGroup.unitID,self.sdkTime];
    extra[kATADDelegateExtraIDKey] = [extraID md5];
    extra[kATADDelegateExtraAdunitIDKey] = self.banner.placementModel.placementID;
    extra[kATADDelegateExtraPublisherRevenueKey] = @(self.banner.unitGroup.price / 1000.0f);
    extra[kATADDelegateExtraCurrencyKey] = self.banner.placementModel.callback[@"currency"];
    extra[kATADDelegateExtraCountryKey] = self.banner.placementModel.callback[@"cc"];
    extra[kATADDelegateExtraFormatKey] = @"Banner";
    extra[kATADDelegateExtraPrecisionKey] = self.banner.unitGroup.precision;
    extra[kATADDelegateExtraNetworkTypeKey] = self.banner.unitGroup.networkFirmID == 35 ? @"Cross_promotion":@"Network";
    return extra;
}

+(UIViewController*)rootViewControllerWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    NSDictionary *extra = [[ATAdManager sharedManager] extraInfoForPlacementID:placementID requestID:requestID];
    if ([extra[kExtraInfoRootViewControllerKey] isKindOfClass:[UIViewController class]]) {
        UIViewController *rootVC = extra[kExtraInfoRootViewControllerKey];
        [[ATAdManager sharedManager] removeExtraInfoForPlacementID:placementID requestID:requestID];
        return rootVC;
    } else {
        __block UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (keyWindow == nil) {
            [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (keyWindow.keyWindow) {
                    keyWindow = obj;
                    *stop = YES;
                }
            }];
            if (keyWindow == nil) {
                keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
                [keyWindow makeKeyWindow];
            }
        }
        return keyWindow.rootViewController;
    }
}

-(void) cleanup {
    [ATLogger logMessage:@"ATBannerCustomEvent cleanup(Added for testing memory issues)." type:ATLogTypeInternal];
}

-(void) dealloc {
    [ATLogger logMessage:[NSString stringWithFormat:@"%@ dealloc(Added for testing memory issues).", NSStringFromClass([self class])] type:ATLogTypeInternal];
}

-(void) trackClick {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nClick with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.banner event:ATGeneralAdAgentEventTypeClick extra:nil error:nil]] type:ATLogTypeTemporary];
    
    NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.banner.unitGroup requestID:self.banner.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.banner.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.banner.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(self.banner.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    [[ATTracker sharedTracker] trackClickWithAd:self.ad extra:trackingExtra];

}

-(void) handleClose {
    [super handleClose];
    if (self.banner != nil) { [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyClose placementID:self.banner.placementModel.placementID unitGroupModel:nil
    extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.banner.requestID != nil ? self.banner.requestID : @"", kAgentEventExtraInfoNetworkFirmIDKey:@(self.banner.unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"", kAgentEventExtraInfoPriorityKey:@(self.banner.priority)}]; }
}

-(NSInteger)priorityIndex {
    return [ATAdCustomEvent calculateAdPriority:self.ad];;
}

@end
