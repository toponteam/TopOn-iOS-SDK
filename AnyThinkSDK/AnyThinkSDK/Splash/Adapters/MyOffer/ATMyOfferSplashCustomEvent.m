//
//  ATMyOfferSplashCustomEvent.m
//  AnyThinkMyOffer
//
//  Created by stephen on 8/7/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferSplashCustomEvent.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATSplashDelegate.h"

@implementation ATMyOfferSplashCustomEvent

-(void) myOfferSplashFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error {
    [ATLogger logMessage:@"MyOfferSplash::myOfferSplashFailToShowOffer:" type:ATLogTypeExternal];
}

-(void) myOfferSplashShowOffer:(ATMyOfferOfferModel*)offer {
    [ATLogger logMessage:@"MyOfferSplash::myOfferSplashShowOffer:" type:ATLogTypeExternal];
    [self trackSplashAdShow];
}

-(void) myOfferSplashClickOffer:(ATMyOfferOfferModel*)offer {
    [ATLogger logMessage:@"MyOfferSplash::myOfferSplashClickOffer:" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

-(void) myOfferSplashCloseOffer:(ATMyOfferOfferModel*)offer {
    [ATLogger logMessage:@"MyOfferSplash::myOfferSplashCloseOffer:" type:ATLogTypeExternal];
    [self trackSplashAdClosed];
}

-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer {
    return self.serverInfo[kAdapterCustomInfoRequestIDKey];
}


- (NSString *)networkUnitId {
    return self.serverInfo[@"my_oid"];
}

@end
