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
#import "NSString+KAKit.h"
@implementation ATSplashCustomEvent
-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        self.requestNumber = 1;
        _unitID = unitID;
    }
    return self;
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATSplashDelegateExtraNetworkIDKey:@(self.ad.unitGroup.networkFirmID),kATSplashDelegateExtraAdSourceIDKey:self.ad.unitGroup.unitID != nil ? self.ad.unitGroup.unitID : @"",kATSplashDelegateExtraIsHeaderBidding:@(self.ad.unitGroup.headerBidding),kATSplashDelegateExtraPriority:@(self.ad.priority),kATSplashDelegateExtraPrice:@(self.ad.unitGroup.price), kATADDelegateExtraSegmentIDKey:@(self.ad.placementModel.groupID), kATADDelegateExtraECPMLevelKey:@(self.ad.unitGroup.ecpmLevel)}];
    NSString *channel = [ATAPI sharedInstance].channel;
    if (channel != nil) { extra[kATADDelegateExtraChannelKey] = channel; }
    NSString *subchannel = [ATAPI sharedInstance].subchannel;
    if (subchannel != nil) { extra[kATADDelegateExtraSubChannelKey] = subchannel; }
    if ([self.ad.placementModel.associatedCustomData count] > 0) { extra[kATADDelegateExtraCustomRuleKey] = self.ad.placementModel.associatedCustomData; }
    NSString *extraID = [NSString stringWithFormat:@"%@%@%@",self.ad.requestID,self.ad.unitGroup.unitID,self.sdkTime];
    extra[kATADDelegateExtraIDKey] = [extraID md5];
    extra[kATADDelegateExtraAdunitIDKey] = self.ad.placementModel.placementID;
    extra[kATADDelegateExtraPublisherRevenueKey] = @(self.ad.unitGroup.price / 1000.0f);
    extra[kATADDelegateExtraCurrencyKey] = self.ad.placementModel.callback[@"currency"];
    extra[kATADDelegateExtraCountryKey] = self.ad.placementModel.callback[@"cc"];
    extra[kATADDelegateExtraFormatKey] = @"Splash";
    extra[kATADDelegateExtraPrecisionKey] = self.ad.unitGroup.precision;
    extra[kATADDelegateExtraNetworkTypeKey] = self.ad.unitGroup.networkFirmID == 35 ? @"Cross_promotion":@"Network";
    return extra;
}

-(void) trackShow {
    [super trackShow];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:self.ad.placementModel.placementID];
    });
    if ([_delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) {
        [_delegate splashDidShowForPlacementID:self.ad.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSInteger)priorityIndex {
    return [ATAdCustomEvent calculateAdPriority:self.ad];;
}

@end
