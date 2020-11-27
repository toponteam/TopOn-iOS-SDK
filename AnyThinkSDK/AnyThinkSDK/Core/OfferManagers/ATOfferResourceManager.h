//
//  ATOfferResourceManager.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ATOfferResourceModel.h"
#import "ATOfferModel.h"

@interface ATOfferResourceManager : NSObject
+(instancetype) sharedManager;
-(ATOfferResourceModel*)retrieveResourceModelWithResourceID:(NSString*)resourceID;
-(void) saveResourceModel:(ATOfferResourceModel*)resourceModel forResourceID:(NSString*)resourceID;
-(void) updateLastUseDateForResourceWithResourceID:(NSString*)resourceID;
-(NSString*) resourcePathForOfferModel:(ATOfferModel*)offerModel resourceURL:(NSString*)URL;
-(UIImage *) imageForOfferModel:(ATOfferModel*)offerModel resourceURL:(NSString*)URL;

@end
