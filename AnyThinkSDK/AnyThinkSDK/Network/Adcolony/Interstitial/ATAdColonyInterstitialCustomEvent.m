//
//  ATAdColonyInterstitialCustomEvent.m
//  AnyThinkAdColonyInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdColonyInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"


@implementation ATAdColonyInterstitialCustomEvent
-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeVideo;
}

#pragma mark -new delegate
- (void)adColonyInterstitialDidLoad:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"AdColonyInterstitial::adColonyInterstitialDidLoad:" type:ATLogTypeInternal];
    [self trackInterstitialAdLoaded:interstitial adExtra:nil];
}

- (void)adColonyInterstitialDidFailToLoad:(id<AdColonyAdRequestError>)error {
    [ATLogger logMessage:@"AdColonyInterstitial::handleLoadFailure" type:ATLogTypeInternal];
    
    [self trackInterstitialAdLoadFailed:(NSError*)error];
}

- (void)adColonyInterstitialWillOpen:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"AdColonyInterstitial::adColonyInterstitialWillOpen" type:ATLogTypeInternal];
    [self trackInterstitialAdShow];
    [self trackInterstitialAdVideoStart];
}

- (void)adColonyInterstitialDidClose:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"AdColonyInterstitial::adColonyInterstitialDidClose" type:ATLogTypeInternal];
    [super trackInterstitialAdClose];
    [self trackInterstitialAdVideoEnd];
}

- (void)adColonyInterstitialExpired:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    
}

- (void)adColonyInterstitialWillLeaveApplication:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    
}

- (void)adColonyInterstitialDidReceiveClick:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"AdColonyInterstitial::adColonyInterstitialDidReceiveClick" type:ATLogTypeInternal];
    [self trackInterstitialAdClick];
}

- (void)adColonyInterstitial:(id<ATAdColonyInterstitial> _Nonnull)interstitial iapOpportunityWithProductId:(NSString * _Nonnull)iapProductID andEngagement:(ATAdColonyIAPEngagement)engagement {
    
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"zone_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"zone_id"];
//    return extra;
//}
@end
