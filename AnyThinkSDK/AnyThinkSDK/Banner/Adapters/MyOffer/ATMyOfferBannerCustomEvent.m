//
//  ATMyOfferBannerCustomEvent.m
//  AnyThinkMyOffer
//
//  Created by stephen on 11/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAPI.h"

@implementation ATMyOfferBannerCustomEvent

-(void) myOfferBannerFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error {
    [ATLogger logMessage:@"ATMyOfferBanner::myOfferBannerFailToShowOffer:" type:ATLogTypeExternal];
}
-(void) myOfferBannerShowOffer:(ATMyOfferOfferModel*)offer {
    [ATLogger logMessage:@"ATMyOfferBanner::myOfferBannerShowOffer:" type:ATLogTypeExternal];
    [self trackShow];
//    [Utilities reportProfit:self.ad time:self.sdkTime];
}
-(void) myOfferBannerClickOffer:(ATMyOfferOfferModel*)offer {
    [ATLogger logMessage:@"ATMyOfferBanner::myOfferBannerClickOffer:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}
-(void) myOfferBannerCloseOffer:(ATMyOfferOfferModel*)offer {
    [ATLogger logMessage:@"ATMyOfferBanner::myOfferBannerCloseOffer:" type:ATLogTypeExternal];
    [self trackBannerAdClosed];
}

-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer {
    return self.serverInfo[kAdapterCustomInfoRequestIDKey];
}


- (NSString *)networkUnitId {
    return self.serverInfo[@"my_oid"];
}
@end
