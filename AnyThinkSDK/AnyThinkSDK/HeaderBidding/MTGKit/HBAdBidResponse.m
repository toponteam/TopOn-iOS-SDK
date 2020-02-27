//
//  HBAdBidResponse.m
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBAdBidResponse.h"
#import "HBAdsBidConstants.h"
#import "HBBidNetworkItem.h"

@interface HBAdBidResponse()

@property (nonatomic,copy,  readwrite) NSString *unitId;
@property (nonatomic,copy,  readwrite) NSObject *payLoad;
@property (nonatomic,assign,readwrite) double price;
@property (nonatomic,copy,  readwrite) NSString *currency;

@property (nonatomic,assign,readwrite) BOOL success;
@property (nonatomic,strong,readwrite) NSError *error;
@property (nonatomic,strong,readwrite) HBBidNetworkItem *networkItem;

@property (nonatomic,strong)  id adsRender;

@property (nonatomic,copy) void(^notifyWin)(void);
@property (nonatomic,copy) void(^notifyLoss)(void);

@end


@implementation HBAdBidResponse

-(void)dealloc{
    DLog(@"");
    _adsRender = nil;
}

#pragma mark Public methods -

- (id)getAdsRender{

    return _adsRender;
}



#pragma mark Private methods -
+ (HBAdBidResponse *)buildResponseWithError:(NSError *)error withNetwork:(HBBidNetworkItem *)networkItem{

    HBAdBidResponse *response = [[HBAdBidResponse alloc] init];
    response.success = NO;
    response.networkItem = networkItem;
    response.error = error;
    return response;
}

+ (HBAdBidResponse *)buildResponseWithPrice:(double)price
                                   currency:(NSString *)currency
                                    payLoad:(NSObject *)payLoad
                                    network:(HBBidNetworkItem *)networkItem
                                  adsRender:(id)adsRender
                                notifyWin:(void (^)(void))win
                               notifyLoss:(void (^)(void))loss{

    HBAdBidResponse *response = [[HBAdBidResponse alloc] init];
    response.success = YES;
    response.payLoad = payLoad;
    response.error = nil;
    response.price = price;
    response.currency = currency;
    response.networkItem = networkItem;
    response.adsRender = adsRender;
    response.notifyWin = win;
    response.notifyLoss = loss;
    return response;
}

- (void)appendUnitId:(NSString *)unitId{
    self.unitId = unitId;
}


- (void)loss{
    
    if (self.notifyLoss) {
        self.notifyLoss();
    }
}

- (void)win{
    
    if (self.notifyWin) {
        self.notifyWin();
    }
}


@end
