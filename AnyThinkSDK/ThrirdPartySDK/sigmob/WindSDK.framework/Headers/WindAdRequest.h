//
//  WindAdRequest.h
//  WindSDK
//
//  Created by happyelements on 2018/4/8.
//  Copyright © 2018 Codi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WindAdRequest : NSObject

@property (nonatomic,copy) NSString *userId;

@property (nonatomic,copy) NSString *placementId;

@property (nonatomic,copy) NSString *loadId;

//做为扩展参数使用
@property (nonatomic,strong) NSDictionary<NSString *, NSString *> *options;

+ (instancetype)request;



@end
