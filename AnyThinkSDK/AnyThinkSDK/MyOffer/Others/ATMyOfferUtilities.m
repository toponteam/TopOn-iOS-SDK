//
//  ATMyOfferUtilities.m
//  AnyThinkMyOffer
//
//  Created by stephen on 8/7/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferUtilities.h"
#import "ATLogger.h"

@implementation ATMyOfferUtilities

+(ATMyOfferOfferModel*) getMyOfferModelWithOfferId:(NSArray<ATMyOfferOfferModel*>*) offers offerID:(NSString *)offerID {
    ATMyOfferOfferModel *offerModel = nil;
    @try {
        offerModel = offers[[[offers mutableArrayValueForKey:@"offerID"] indexOfObject:offerID]];
    } @catch (NSException *exception) {
        [ATLogger logError:[NSString stringWithFormat:@"Exception occured while finding offer with id:%@ in offers:%@", offerID, offers] type:ATLogTypeExternal];
    } @finally {
        return offerModel;
    }
}


@end
