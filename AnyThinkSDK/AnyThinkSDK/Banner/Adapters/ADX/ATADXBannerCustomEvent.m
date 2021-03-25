//
//  ATADXBannerCustomEvent.m
//  AnyThinkSDK
//
//  Created by Topon on 10/22/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXBannerCustomEvent.h"
#import "Utilities.h"
#import "ATADXLoader.h"
#import "ATAdManagement.h"
#import "ATOfferBannerView.h"
#import "ATADXBannerAdManager.h"
#import "ATBidInfoManager.h"

@implementation ATADXBannerCustomEvent

-(void) didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXBanner::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    
    self.offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:self.setting.placementID unitGroupModel:self.unitGroupModel];
    ATOfferBannerView *bannerView = [[ATADXBannerAdManager sharedManager] retrieveBannerViewWithOfferModel:[[ATADXLoader sharedLoader] offerModelWithPlacementID:self.setting.placementID unitGroupModel:self.unitGroupModel] setting:self.setting extra:self.localInfo delegate:self];
    if(bannerView != nil){
        [self trackBannerAdLoaded:bannerView adExtra:@{kAdAssetsPriceKey:_price, kAdAssetsBidIDKey:_bidId}];
    }else{
        [self trackBannerAdLoadFailed:[NSError errorWithDomain:@"com.anythink.ADXBanner" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"ADX has failed to load banner", NSLocalizedFailureReasonErrorKey:@"Banner's not ready for resource"}]];
    }
}

-(void) didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADXBanner::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID unitID:(NSString *)unitID error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"ADXBanner::didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
}

-(void) adxBannerFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error {
    [ATLogger logMessage:@"ADXBanner::adxBannerFailToShowOffer:" type:ATLogTypeExternal];
}

- (void) adxBannerDeepLinkOrJumpResult:(BOOL)success offer:(ATADXOfferModel *)offer {
    [ATLogger logMessage:@"ADXBanner::adxBannerDeepLinkOrJumpResult:" type:ATLogTypeExternal];
    [self trackBannerAdDeeplinkOrJumpResult:success];
}
-(void) adxBannerShowOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXBanner::adxBannerShowOffer:" type:ATLogTypeExternal];
    [self trackShow];
//    [Utilities reportProfit:self.ad time:self.sdkTime];
    [[ATADXLoader sharedLoader] removeOfferModel:offer];
    [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:self.setting.placementID unitGroupModel:self.unitGroupModel requestID:self.requestID];
}

-(void) adxBannerClickOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXBanner::adxBannerClickOffer:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

-(void) adxBannerCloseOffer:(ATADXOfferModel*)offer {
    [ATLogger logMessage:@"ADXBanner::adxBannerCloseOffer:" type:ATLogTypeExternal];
    [self trackBannerAdClosed];
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
