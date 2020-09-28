//
//  ATMintegralInterstitialCustomEvent.m
//  AnyThinkMintegralInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@implementation ATMintegralInterstitialCustomEvent
-(ATNativeADSourceType) adSourceType {
    return [self.interstitial.unitGroup.content[@"is_video"] boolValue] ? ATNativeADSourceTypeVideo : ATNativeADSourceTypeImage;
}
#pragma mark - interstitial delegate
- (void) onInterstitialLoadSuccess:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialLoadSuccess:" type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:adManager, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsPriceKey:@(_price)}];
    [self trackInterstitialAdLoaded:adManager adExtra:@{kAdAssetsPriceKey:@(_price)}];
}

- (void) onInterstitialLoadFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralInterstitial::onInterstitialLoadFail:%@ adManager:", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void) onInterstitialShowSuccess:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialShowSuccess:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void) onInterstitialShowFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralInterstitial::onInterstitialShowFail:%@ adManager:", error] type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:error];
}

- (void) onInterstitialClosed:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialClosed:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void) onInterstitialAdClick:(id<ATMTGInterstitialAdManager>)adManager  {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialAdClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

#pragma mark - interstitial video delegate
- (void) onInterstitialAdLoadSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager {//Video not ready
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialAdLoadSuccess:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void) onInterstitialVideoLoadSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialVideoLoadSuccess:" type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:adManager, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsPriceKey:@(_price)}];
    [self trackInterstitialAdLoaded:adManager adExtra:@{kAdAssetsPriceKey:@(_price)}];
}

- (void) onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralInterstitial::onInterstitialVideoLoadFail:%@ adManager:", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void) onInterstitialVideoShowSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialVideoShowSuccess:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void) onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralInterstitial::onInterstitialVideoShowFail:%@ adManager:", error] type:ATLogTypeExternal];
    [self trackInterstitialAdDidFailToPlayVideo:error];
}

- (void) onInterstitialVideoAdClick:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialVideoAdClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialVideoAdDismissedWithConverted:adManager:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}


//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"unitid"];
//    return extra;
//}
@end
