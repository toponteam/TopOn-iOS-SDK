//
//  HBBidAdapter.m
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBBidAdapter.h"
#import "HBBidBaseCustomEvent.h"
#import "HBBidNetworkItem.h"
#import "HBAdBidResponse.h"

@interface HBBidAdapter()

@property (nonatomic,strong) HBBidBaseCustomEvent *customEvent;
@property (nonatomic,strong,readwrite) HBAdBidResponse *bidResponse;
@property (nonatomic,  copy) void(^completionHandler)(HBAdBidResponse *bidResponse);
@property (nonatomic,strong) HBBidNetworkItem *networkItem;
@end

@implementation HBBidAdapter

-(void)dealloc{
    DLog(@"");
}

#pragma mark Public methods -

- (void)getBidNetwork:(HBBidNetworkItem *)networkItem adFormat:(HBAdBidFormat)format responseCallback:(void(^)(HBAdBidResponse *bidResponse))callback{
    
    NSAssert(networkItem, @"networkItem should not be nil");
    NSAssert(callback, @"callback should not be nil");

    self.networkItem = networkItem;

    Class class = NSClassFromString(networkItem.customEventClassName);

    self.customEvent = [self buildCustomEventFromCustomClass:class];
    if (!self.customEvent) {
    
        NSString *errorMsg = [NSString stringWithFormat:@"The customClassName named%@   init failed",networkItem.customEventClassName];
        NSError *error = [HBAdBidError errorWithCode:GDBidErrorInputParamersInvalid userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        HBAdBidResponse *response = [HBAdBidResponse buildResponseWithError:error withNetwork:networkItem];
        callback(response);
        return;
    }

    __weak __typeof(self)weakSelf = self;

    [self.customEvent getBidNetwork:networkItem adFormat:format responseCallback:^(HBAdBidResponse * _Nonnull bidResponse) {

        __strong __typeof(weakSelf)strongSelf = weakSelf;

        strongSelf.bidResponse = bidResponse;

        if (callback) {
            callback(bidResponse);
        }
    }];
}

- (void)win{
    NSAssert(self.bidResponse, @"self.bidResponse should be nil");
    [self.bidResponse win];
}

- (void)loss{
    NSAssert(self.bidResponse, @"self.bidResponse should be nil");
    [self.bidResponse loss];
}

#pragma mark Private methods -

- (HBBidBaseCustomEvent *)buildCustomEventFromCustomClass:(Class)customClass{
    
    HBBidBaseCustomEvent *customEvent = [[customClass alloc] init];
    
    if (![customEvent isKindOfClass:[HBBidBaseCustomEvent class]]) {
        return nil;
    }

    return customEvent;
}


@end
