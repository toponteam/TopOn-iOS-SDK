//
//  ATMyOfferNativeCustomEvent.m
//  AnyThinkMyOffer
//
//  Created by Topon on 8/11/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferNativeCustomEvent.h"
#import "Utilities.h"
#import "ATMyOfferTracker.h"

@implementation ATMyOfferNativeCustomEvent

-(void) myOfferNativeFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error {
    [ATLogger logMessage:@"MyOfferNative::myOfferNativeFailToShowOffer:" type:ATLogTypeExternal];
}

-(void) myOfferNativeShowOffer:(ATMyOfferOfferModel*)offer {
    [ATLogger logMessage:@"MyOfferNative::myOfferNativeShowOffer:" type:ATLogTypeExternal];
}

-(void) myOfferNativeClickOffer:(ATMyOfferOfferModel*)offer {
    [ATLogger logMessage:@"MyOfferNative::myOfferNativeClickOffer:" type:ATLogTypeExternal];
    [self trackNativeAdClick];
}

- (NSString *)lifeCircleIDForOffer:(ATMyOfferOfferModel *)offer {
    [ATLogger logMessage:@"MyOfferNative::lifeCircleIDForOffer:" type:ATLogTypeExternal];
    return self.serverInfo[kAdapterCustomInfoRequestIDKey];
}

- (void)trackNativeAdShow:(BOOL)refresh {
    [super trackNativeAdShow:refresh];
    [self trackNativeAdImpression];
    [self didMoveToWindow];
//    [Utilities reportProfit:self.ad time:self.sdkTime];
}

//父视图已更改
- (void)didMoveToWindow {
    if(_offerModel != nil && _setting != nil){
        NSString *lifeCircleID = self.serverInfo[kAdapterCustomInfoRequestIDKey] != nil ? self.serverInfo[kAdapterCustomInfoRequestIDKey] : @"";
        [[ATMyOfferTracker sharedTracker] impressionOfferWithOfferModel:_offerModel extra:@{kATOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""}];
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATOfferTrackerExtraLifeCircleID];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventImpression offerModel:_offerModel extra:trackerExtra];
        [[ATMyOfferTracker sharedTracker] preloadStorekitForOfferModel:_offerModel setting:_setting viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID skDelegate:self];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"my_oid"];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
   //TODO something when storeit is close
}

@end
