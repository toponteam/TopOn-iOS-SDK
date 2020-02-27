//
//  ATSplashCustomEvent.m
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATSplashCustomEvent.h"
#import "ATSplashDelegate.h"
#import "ATPlacementSettingManager.h"
@implementation ATSplashCustomEvent
-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        self.requestNumber = 1;
        self.priorityIndex = [ATAdCustomEvent calculateAdPriority:self.ad];
        _unitID = unitID;
    }
    return self;
}

-(void) trackShow {
    [super trackShow];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:self.ad.placementModel.placementID];
    });
    if ([_delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) {
        [_delegate splashDidShowForPlacementID:self.ad.placementModel.placementID extra:@{kATSplashDelegateExtraNetworkIDKey:@(self.ad.unitGroup.networkFirmID),kATSplashDelegateExtraAdSourceIDKey:self.ad.unitGroup.unitID != nil ? self.ad.unitGroup.unitID : @"",kATSplashDelegateExtraIsHeaderBidding:@(self.ad.unitGroup.headerBidding),kATSplashDelegateExtraPriority:@(self.ad.priority),kATSplashDelegateExtraPrice:@(self.ad.unitGroup.price)}];
    }
}
@end
