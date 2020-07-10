//
//  HBBidRequestManager.m
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/9.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "HBBidRequestManager.h"
#import "HBAdBidResponse.h"
#import "HBBidNetworkItem.h"
#import "HBAdBidResponse+Addition.h"
#import "HBAdBidError.h"
#import "HBBidAdapter.h"
#import "HBAuctionResult+Addition.h"


@interface HBBidRequestManager()

@property (nonatomic,  copy)  void(^completionHandler)(HBAuctionResult *auctionResponse,NSError *error);
@property (nonatomic,assign)  HBAdBidFormat adFormat;
@property (nonatomic,  copy)  NSString *unitId;
@property (nonatomic,strong)  NSArray *networkItems;
@property (nonatomic,strong)  NSMutableArray *adapterArray;
@property (nonatomic,strong)  NSLock *adapterArrayLock;
@property (nonatomic,strong)  NSMutableDictionary *responseDict;
@property (nonatomic,strong)  NSLock *responseLock;
@property (nonatomic,strong)  NSLock *handleAuctionLock;
@property (nonatomic,strong)  NSTimer  *timer;
@property (nonatomic,assign)  BOOL timeout;
@property (nonatomic,strong)  NSLock *timeoutLock;

@end

@implementation HBBidRequestManager

-(void)dealloc{
    DLog(@"");
    self.completionHandler = nil;
    [self.responseDict removeAllObjects];
}

#pragma mark  Public methods -
- (void)getBidNetworks:(NSArray *)networkItems statisticsInfo:(NSDictionary*)statisticsInfo unitId:(NSString *)unitId adFormat:(HBAdBidFormat)format maxTimeoutMS:(NSInteger)maxTimeoutMS responseCallback:(void(^)(HBAuctionResult *auctionResponse,NSError *error))callback{

    if (!callback) {
        NSAssert(callback, @"Attention: the callback you passed is nil");
        return;
    }

    if (networkItems.count == 0) {
        NSString *errorMsg = @"The networkItems you passed is nil";
        NSError *error = [HBAdBidError errorWithCode:GDBidErrorInputParamersInvalid userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        callback(nil,error);
        return;
    }

    if (maxTimeoutMS < 1) {
        maxTimeoutMS = 1000;
    }
    self.networkItems = networkItems;
    self.completionHandler = callback;
    self.responseDict = [NSMutableDictionary new];
    self.adapterArray = [NSMutableArray new];
    self.adFormat = format;
    self.unitId = unitId;
    
    self.adapterArrayLock = [[NSLock alloc] init];
    self.responseLock = [[NSLock alloc] init];
    self.timeoutLock = [[NSLock alloc] init];
    self.handleAuctionLock = [[NSLock alloc] init];

    [self requestNetworkBids:networkItems statisticsInfo:statisticsInfo requestTimeout:maxTimeoutMS];
    
    NSTimeInterval duration = maxTimeoutMS / 1000.f;
    self.timer = [NSTimer timerWithTimeInterval:duration  target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:NO];

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate dateWithTimeIntervalSinceNow:duration]];
}

#pragma mark Private methods -

- (void)requestNetworkBids:(NSArray *)networkItems statisticsInfo:(NSDictionary*)statisticsInfo requestTimeout:(NSInteger)maxTimeoutMS{
    
    NSAssert(networkItems.count > 0, @"networkItems should not be nil");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    [networkItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HBBidNetworkItem *item,NSUInteger idx,BOOL *stop){
        
        if (item.maxTimeoutMS < 1 || item.maxTimeoutMS > maxTimeoutMS) {
            item.maxTimeoutMS = maxTimeoutMS;
        }
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{

            __weak __typeof(self)weakSelf = self;

            HBBidAdapter *adapter = [[HBBidAdapter alloc] init];
            [self.adapterArrayLock lock];
            [self.adapterArray addObject:adapter];
            [self.adapterArrayLock unlock];

            [adapter getBidNetwork:item extra:statisticsInfo[item.unitId] adFormat:self.adFormat responseCallback:^(HBAdBidResponse * _Nonnull bidResponse) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;

                [bidResponse appendUnitId:strongSelf.unitId];
                [strongSelf.responseLock lock];
                NSString *key = [NSString stringWithFormat:@"%@",bidResponse.networkItem.itemInstanceKey];
                if (bidResponse) {
                    [weakSelf.responseDict setObject:bidResponse forKey:key];
                }

                [strongSelf.responseLock unlock];
                dispatch_group_leave(group);
            }];
        });
        
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{

        BOOL timeout = NO;
        [self.timeoutLock lock];
        timeout = self.timeout;
        [self.timeoutLock unlock];

        if (timeout) return;

        [self.timer invalidate];
        self.timer = nil;

        [self.responseLock lock];
        NSDictionary *currentResponseDict = [self.responseDict mutableCopy];;
        [self.responseLock unlock];

        NSAssert(currentResponseDict.allKeys.count == networkItems.count, nil);
        
        NSArray *sortedArray = [self sortDict:currentResponseDict];
        [self handleAuctionResult:sortedArray];
    });
}

- (void)timerFireMethod:(NSTimer *)timer{
    
    [self.timeoutLock lock];
    self.timeout = YES;
    [self.timeoutLock unlock];

    [self.timer invalidate];
    self.timer = nil;

    [self.responseLock lock];
    NSDictionary *currentResponseDict = [self.responseDict mutableCopy];;
    [self.responseLock unlock];
    
    NSArray *availaleArray = [self sortDict:currentResponseDict];
    NSMutableArray *timeoutNetworks = [NSMutableArray new];
    for (HBBidNetworkItem *item  in self.networkItems) {
        NSString *key = [NSString stringWithFormat:@"%@",item.itemInstanceKey];
        if (![currentResponseDict objectForKey:key]) {
            
            NSString *errorMsg = [NSString stringWithFormat:@"Current network(%ld) bid request timeout",(long)item.network];
            NSError *error = [HBAdBidError errorWithCode:(GDBidErrorNetworkBidTimeout) userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
            HBAdBidResponse *response = [HBAdBidResponse buildResponseWithError:error withNetwork:item];
            
            [timeoutNetworks addObject:response];
        }
    }
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:availaleArray];
    [sortedArray addObjectsFromArray:timeoutNetworks];
    [self handleAuctionResult:sortedArray];
}


- (void)handleAuctionResult:(NSArray *)sortedArray{
    
    [self.handleAuctionLock lock];
    if (self.completionHandler) {
        
        HBAdBidResponse *firstResponse = sortedArray.firstObject;
        if (!firstResponse.success) {
            NSString *errorMsg = @"There is no valid response";
            NSError *error = [HBAdBidError errorWithCode:1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
            self.completionHandler(nil, error);
        }else{
            
            NSArray *lossedNetworkResponses = [self getLossedResponses:sortedArray];
            [self notifyLossedNetwork:lossedNetworkResponses];
            [self notifyWonNetwork:@[sortedArray[0]]];
            
            HBAuctionResult *result = [HBAuctionResult buildAuctionResult:sortedArray[0] otherResponses:lossedNetworkResponses];
            self.completionHandler(result,nil);
        }
    }
    self.completionHandler = nil;
    [self.handleAuctionLock unlock];
}



- (NSArray *)sortDict:(NSDictionary *)dict{
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:dict.allValues];
    if (tempArray.count == 0) {
        return nil;
    }
    NSSortDescriptor *successDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"success" ascending:NO];
    NSSortDescriptor *priceDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObjects:successDescriptor,priceDescriptor, nil];
    [tempArray sortUsingDescriptors:descriptors];

    return tempArray;
}

- (NSArray *)getLossedResponses:(NSArray *)responses{
    
    if (responses.count < 2) return nil;

    NSRange range = NSMakeRange(1, responses.count - 1);
    NSArray *lossedResponses = [responses subarrayWithRange:range];
    return lossedResponses;
}

- (void)notifyLossedNetwork:(NSArray *)responses{

    if (responses.count == 0) return;

    for (HBAdBidResponse *response in responses) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [response loss];
        });
    }
}

- (void)notifyWonNetwork:(NSArray *)responses{
    
    if (responses.count == 0) return;
    
    for (HBAdBidResponse *response in responses) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [response win];
        });
    }
}





@end
