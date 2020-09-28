//
//  ATMyOfferUtilities.h
//  AnyThinkMyOffer
//
//  Created by stephen on 8/7/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ATMyOfferOfferModel.h"

@interface ATMyOfferUtilities : NSObject
+(ATMyOfferOfferModel*) getMyOfferModelWithOfferId:(NSArray<ATMyOfferOfferModel*>*) offers offerID:(NSString *)offerID;
@end
