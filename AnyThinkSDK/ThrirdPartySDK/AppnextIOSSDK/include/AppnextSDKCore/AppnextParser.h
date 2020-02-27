//
//  AppnextParser.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 26/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdData.h>

@interface AppnextParser : NSObject

#pragma mark - Utility methods

+ (NSArray *) parseArray:(NSArray *)data andAction:(SEL)action;
+ (id) parseDictionary:(NSDictionary *)data andAction:(SEL)action;

#pragma mark - Reverse Parsing

+ (NSString *) jsonStringFromArray:(NSArray *)array prettify:(BOOL)pretty;
+ (NSString *) jsonStringFromDictionary:(NSDictionary *)dict prettify:(BOOL)pretty;
+ (id) jsonObjectFromJsonString:(NSString *)jsonString;

#pragma mark - Parsing Offer Wall Response

+ (NSArray<AppnextAdData *> *) parseOfferWallAds:(NSDictionary *)data;
+ (AppnextAdData *) parseAdData:(NSDictionary *)data;
+ (NSDictionary *) dictionaryFromAdData:(AppnextAdData *)adData;

@end
