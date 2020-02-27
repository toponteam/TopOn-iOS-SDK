//
//  WindAdOptions.h
//  WindSDK
//
//  Created by happyelements on 2018/4/8.
//  Copyright © 2018 Codi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WindAdOptions : NSObject

@property (copy, nonatomic) NSString* appId;
@property (copy, nonatomic) NSString* apiKey;

//Quickly generate the current object.
+ (instancetype)options;

@end
