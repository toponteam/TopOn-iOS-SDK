//
//  ATADXSplashCustomEvent.m
//  AnyThinkSDK
//
//  Created by Topon on 10/21/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXSplashCustomEvent.h"
#import "Utilities.h"
#import "ATAdManagement.h"
#import "ATADXSplashAdManager.h"
#import "ATBidInfoManager.h"
#import "ATADXLoader.h"

@implementation ATADXSplashCustomEvent

-(void) didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXSplash::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    [self trackSplashAdLoaded:self adExtra:@{kAdAssetsPriceKey:_price, kAdAssetsBidIDKey:_bidId}];
}

-(void) didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID unitID:(NSString *)unitID error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"ADXSplash::didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    [self trackSplashAdLoadFailed:error];
}

-(void) adxSplashFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error {
    [ATLogger logMessage:@"ADXSplash::adxSplashFailToShowOffer:" type:ATLogTypeExternal];
}

-(void) adxSplashShowOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXSplash::adxSplashShowOffer:" type:ATLogTypeExternal];
    [self trackSplashAdShow];
}

-(void) adxSplashClickOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXSplash::adxSplashClickOffer:" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

- (void)adxSplashDeepLinkOrJumpResult:(BOOL)success offer:(ATADXOfferModel *)offer {
    [ATLogger logMessage:@"ADXSplash::adxSplashDeepLinkOrJumpResult:" type:ATLogTypeExternal];
    [self trackSplashAdDeeplinkOrJumpResult:success];
}

-(void) adxSplashCloseOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXSplash::adxSplashCloseOffer:" type:ATLogTypeExternal];
    [self trackSplashAdClosed];
}

-(NSString*) lifeCircleIDForOffer:(ATADXOfferModel*)offer {
    return self.serverInfo[kAdapterCustomInfoRequestIDKey];
}

- (NSString *)networkUnitId {
    return _unitGroupModel.unitID;
}

- (NSDictionary *)networkCustomInfo {
    if (self.offerModel != nil) {
        BOOL isDeepLink = NO;
        if ([Utilities isEmpty:self.offerModel.deeplinkUrl] == NO || [Utilities isEmpty:self.offerModel.jumpUrl] == NO) {
            isDeepLink = YES;
        }
        NSDictionary *extInfo = @{kATADDelegateExtraOfferIDKey:self.offerModel.offerID != nil ? self.offerModel.offerID : @"", kATADDelegateExtraCreativeIDKey:self.offerModel.resourceID != nil ? self.offerModel.resourceID : @"", kATADDelegateExtraIsDeeplinkKey:@(isDeepLink)};
        return extInfo;
    }else {
        return nil;
    }
}

@end
