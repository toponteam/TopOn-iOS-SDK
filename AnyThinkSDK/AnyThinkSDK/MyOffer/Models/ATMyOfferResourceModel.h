//
//  ATMyOfferResourceModel.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATModel.h"
@interface ATMyOfferResourceModel : ATModel
-(NSString*) resourcePathForURL:(NSString*)URL;
-(NSArray<NSString*>*) allResourcePaths;
-(void) setResourcePath:(NSString*)path forURL:(NSString*)URL;
-(void) accumulateLength:(NSUInteger)length;
-(void) updateLastUseDate;
/*
 * For archiving; resource model will be converted into dictionary before being archived.
 */
-(NSDictionary*)dictionary;
@property (nonatomic, readonly) NSUInteger length;
@property (nonatomic, readonly) NSDate *cacheDate;
@property (nonatomic, readonly) NSDate *lastUseDate;
+(instancetype) mockResourceModel;
@end
