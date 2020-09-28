//
//  ATMyOfferResourceManager.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ATMyOfferResourceModel.h"
#import "ATMyOfferOfferModel.h"

@interface ATMyOfferResourceManager : NSObject
+(instancetype) sharedManager;
-(ATMyOfferResourceModel*)retrieveResourceModelWithResourceID:(NSString*)resourceID;
-(void) saveResourceModel:(ATMyOfferResourceModel*)resourceModel forResourceID:(NSString*)resourceID;
-(void) updateLastUseDateForResourceWithResourceID:(NSString*)resourceID;
-(NSString*) resourcePathForOfferModel:(ATMyOfferOfferModel*)offerModel resourceURL:(NSString*)URL;
-(UIImage *) imageForOfferModel:(ATMyOfferOfferModel*)offerModel resourceURL:(NSString*)URL;

@end
