//
//  WindProtocol.h
//  WindSDK
//
//  Created by happyelements on 2018/8/2.
//  Copyright © 2018 Codi. All rights reserved.
//

@class WindAdRequest;

@protocol WindAdRequestProtocol<NSObject>

@optional

- (NSDictionary *)parametes;

- (NSDictionary *)parametes:(NSString *)placementId;

- (WindAdRequest *)request:(NSString *)placementId;


@end

