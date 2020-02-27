//
//  HBAdBidResponse.h
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HBBidNetworkItem;

NS_ASSUME_NONNULL_BEGIN

@interface HBAdBidResponse : NSObject


@property (nonatomic,copy,  readonly) NSString *unitId;
@property (nonatomic,copy,  readonly) NSObject *payLoad;
@property (nonatomic,assign,readonly) double price;
@property (nonatomic,copy,  readonly) NSString *currency;

@property (nonatomic,assign,readonly) BOOL success;
@property (nonatomic,strong,readonly) NSError *error;
@property (nonatomic,strong,readonly) HBBidNetworkItem *networkItem;


- (id)getAdsRender;



@end

NS_ASSUME_NONNULL_END
