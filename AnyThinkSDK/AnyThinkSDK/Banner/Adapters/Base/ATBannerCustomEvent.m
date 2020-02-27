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
@end
