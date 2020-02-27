//
//  ATMyOfferResourceLoader.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferModel.h"
@interface ATMyOfferResourceLoader : NSObject
+(instancetype)sharedLoader;
-(void)loadOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion;
+(NSString*)resourceRootPath;
@end
