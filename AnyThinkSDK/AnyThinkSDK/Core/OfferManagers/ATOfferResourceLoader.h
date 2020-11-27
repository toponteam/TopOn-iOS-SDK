//
//  ATOfferResourceLoader.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATOfferModel.h"
@interface ATOfferResourceLoader : NSObject
+(instancetype)sharedLoader;
-(void)loadOfferWithOfferModel:(ATOfferModel*)offerModel placementID:(NSString *) placementID resourceDownloadTimeout:(NSTimeInterval)resourceDownloadTimeout extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion;
+(NSString*)resourceRootPath;
@end
