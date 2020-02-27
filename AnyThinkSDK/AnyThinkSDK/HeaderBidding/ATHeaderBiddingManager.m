//
//  ATHeaderBiddingManager.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 2019/6/18.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATHeaderBiddingManager.h"
#import <objc/runtime.h>
NSString *const kATHeaderBiddingAdSourceInfoAppIDKey = @"app_id";
NSString *const kATHeaderBiddingAdSourceInfoUnitIDKey = @"unit_id";
static NSString *const kATHeaderBiddingNetworkItemUnitIDAssociateKey = @"associate_unit_id";

static NSString *const kATHeaderBiddingRequestResultExtraInfoTotalErrorKey = @"total_error";
static NSString *const kATHeaderBiddingRequestResultExtraInfoDetailErrorKey = @"detail_error";
extern NSString *const kATHeaderBiddingExtraInfoUnitGroupsUsingLatestBidInfoKey;

typedef NS_ENUM(NSInteger, ATHBError) {
    ATHBErrorNetworkNotSupported = 10001,
    ATHBErrorHBKitNotImportedProperly = 10002,
    ATHBErrorBidRequestSentButFailed = 10003,
};
@implementation ATHeaderBiddingManager
+(instancetype)sharedManager {
    static ATHeaderBiddingManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATHeaderBiddingManager alloc] init];
    });
    return sharedManager;
}

/*
 Find the first position for HBAdSource using condition
 */
NSUInteger FindPositionToInsert(NSArray *adsources, id HBAdSource, BOOL (^condition)(id, id)) {
    __block NSUInteger index = [adsources count];
    [adsources enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (condition(obj, HBAdSource)) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

/*
 Insert all the element in src into des by applying each element in src & des & condition to FindPositionToInsert;
 elements in src will be in descending order after the insertion;
 des is not necessarily sorted before and/or after the insertion
 
 Example:
 BEFORE insertion:
 des: 10, 25, 7, 6, 5
 src: 9, 6, 3
 condition is implemented as taking the price(if adsource is non-hb) / bidPrice(if adsource is hb) as the compared price & check if HBAdSource's comparaed price is greater than or equals to that of adsource
 AFTER insertion:
 10, 25, 9, 7, 6(from src), 6, 5, 3
 */
NSArray* CombineAdSources(NSArray* des, NSArray* src, BOOL(^condition)(id adSource, id HBAdSource)) {
    NSMutableArray* sortedAdsources = [des count] > 0 ? [NSMutableArray arrayWithArray:des] : [NSMutableArray array];
    [src enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sortedAdsources insertObject:obj atIndex:FindPositionToInsert(sortedAdsources, obj, condition)];
    }];
    return sortedAdsources;
}

NSString* CustomEventClassName(ATHBAdBidNetwork network) {
    return @{@(ATHBAdBidNetworkFacebook):@"FBBidAdapter", @(AnyThinkHBAdBidNetworkMintegral):@"MTGBidAdapter"}[@(network)];
}

NSString *NetworkItemHBAdSourceMapKey(id<ATHBBidNetworkItem> networkItem) {
    return [NSString stringWithFormat:@"%ld_%@", networkItem.network, networkItem.unitId];
}

BOOL CheckNetworkSupport(ATHBAdBidNetwork network) {
    BOOL support = NO;
    switch (network) {
        case ATHBAdBidNetworkFacebook:
            support = NSClassFromString(@"FBAdBidRequest") != nil && NSClassFromString(@"FBAdBidResponse") != nil;
            break;
        case AnyThinkHBAdBidNetworkMintegral:
            support = NSClassFromString(@"MTGBiddingResponse") != nil && NSClassFromString(@"MTGBiddingRequest") != nil && NSClassFromString(@"MTGSDK") != nil;
            break;
        default:
            break;
    }
    return support;
}

-(void) runHeaderBiddingWithForamt:(ATHBAdBidFormat)format unitID:(NSString*)unitID adSources:(NSArray<id<ATAdSource>>*)adSources headerBiddingAdSources:(NSArray<id<ATHeaderBiddingAdSource>>*)HBAdSources timeout:(NSTimeInterval)timeout completion:(void(^)(NSArray<id<ATAdSource>>*, NSDictionary*))completion {
    if (NSClassFromString(@"HBBidNetworkItem") != nil && NSClassFromString(@"HBAdsBidRequest") != nil) {
        //Used for get bid tokens/prices
        NSMutableArray<id<ATHBBidNetworkItem>> *netwrokItems = [NSMutableArray<id<ATHBBidNetworkItem>> array];
        //Used to save unsupported adsources
        NSMutableArray<id<ATHeaderBiddingAdSource>> *unsupportedAdSources = [NSMutableArray<id<ATHeaderBiddingAdSource>> array];
        //Used to save all biding adsource, network_unitId keyed
        NSMutableDictionary<NSString*, id<ATHeaderBiddingAdSource>>*networkItemAdSourceMap = [NSMutableDictionary<NSString*, id<ATHeaderBiddingAdSource>> dictionary];
        NSMutableDictionary<NSNumber*, NSError*>* detailErrors = [NSMutableDictionary<NSNumber*, NSError*> dictionary];
        [HBAdSources enumerateObjectsUsingBlock:^(id<ATHeaderBiddingAdSource>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CheckNetworkSupport(obj.network) && CustomEventClassName(obj.network) != nil) {
                id<ATHBBidNetworkItem> networkItem = [NSClassFromString(@"HBBidNetworkItem") buildItemNetwork:obj.network customEventClassName:CustomEventClassName(obj.network) appId:obj.adSrouceInfo[kATHeaderBiddingAdSourceInfoAppIDKey] unitId:obj.adSrouceInfo[kATHeaderBiddingAdSourceInfoUnitIDKey]];
                networkItem.extraParams = obj.adSrouceInfo;
                networkItem.maxTimeoutMS = obj.headerBiddingRequestTimeout;
                networkItem.platformId = obj.adSrouceInfo[kATHeaderBiddingAdSourceInfoAppIDKey];
//                networkItem.testMode = YES;//to do
                [netwrokItems addObject:networkItem];
                networkItemAdSourceMap[NetworkItemHBAdSourceMapKey(networkItem)] = obj;
            } else {
                detailErrors[@(((NSObject*)obj).hash)] = [NSError errorWithDomain:@"com.anythink.HeaderBiddingRequest" code:ATHBErrorNetworkNotSupported userInfo:@{NSLocalizedDescriptionKey:@"Header bidding request failed", NSLocalizedFailureReasonErrorKey:@"This network does not support header bidding"}];
                [unsupportedAdSources addObject:obj];
            }
        }];
        
        if ([netwrokItems count] > 0) {
            [NSClassFromString(@"HBAdsBidRequest") getBidNetworks:netwrokItems unitId:unitID adFormat:format maxTimeoutMS:timeout responseCallback:^(id<ATHBAuctionResult> result, NSError *error) {
                if (result != nil) {
                    void (^ConfigBidResponse)(id<ATHeaderBiddingAdSource> HBAdSource, id<ATHBAdBidResponse> HBResponse) = ^(id<ATHeaderBiddingAdSource> HBAdSource, id<ATHBAdBidResponse> HBResponse) {
                        if ([HBAdSource respondsToSelector:@selector(bidPrice)] && [HBAdSource respondsToSelector:@selector(bidToken)] && [HBResponse respondsToSelector:@selector(price)] && [HBResponse respondsToSelector:@selector(payLoad)]) {
                            HBAdSource.bidPrice = HBResponse.price;
                            HBAdSource.bidToken = HBResponse.payLoad;
                        }
                    };
                    
                    NSMutableArray<id<ATHeaderBiddingAdSource>> *sucAdSources = [NSMutableArray<id<ATHeaderBiddingAdSource>> array];
                    id<ATHeaderBiddingAdSource> winderAdSource = networkItemAdSourceMap[NetworkItemHBAdSourceMapKey(result.winner.networkItem)];
                    if (result.winner.success) {
                        if (winderAdSource != nil) {
                            [sucAdSources addObject:winderAdSource];
                            ConfigBidResponse(winderAdSource, result.winner);
                        }
                    } else {
                        detailErrors[@(winderAdSource.hash)] = [result.winner.error isKindOfClass:[NSError class]] ? result.winner.error : [NSError errorWithDomain:@"com.anythink.HeaderBiddingRequest" code:ATHBErrorBidRequestSentButFailed userInfo:@{NSLocalizedDescriptionKey:@"Header bidding request failed", NSLocalizedFailureReasonErrorKey:@"Bid request has been sent but failed"}];
                    }
                    
                    NSMutableArray<id<ATAdSource>> *adSourcesUsingLatestBidInfo = [NSMutableArray<id<ATAdSource>> array];
                    [result.otherResponse enumerateObjectsUsingBlock:^(id<ATHBAdBidResponse>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        id<ATHeaderBiddingAdSource> curAdSource = networkItemAdSourceMap[NetworkItemHBAdSourceMapKey(obj.networkItem)];
                        if (obj.success) {
                            ConfigBidResponse(curAdSource, obj);
                            [sucAdSources addObject:curAdSource];
                        } else {
                            //Handle failure
                            NSDictionary *latestBidInfo = [curAdSource latestBidInfo];
                            if ([latestBidInfo isKindOfClass:[NSDictionary class]] && latestBidInfo[kUnitGroupBidInfoPriceKey] != nil && latestBidInfo[kUnitGroupBidInfoBidTokenKey] != nil) {
                                curAdSource.bidPrice = [latestBidInfo[kUnitGroupBidInfoPriceKey] doubleValue];
                                curAdSource.bidToken = latestBidInfo[kUnitGroupBidInfoBidTokenKey];
                                [sucAdSources addObject:curAdSource];
                                [adSourcesUsingLatestBidInfo addObject:curAdSource];
                            } else {
                                detailErrors[@(curAdSource.hash)] = [obj.error isKindOfClass:[NSError class]] ? obj.error : [NSError errorWithDomain:@"com.anythink.HeaderBiddingRequest" code:ATHBErrorBidRequestSentButFailed userInfo:@{NSLocalizedDescriptionKey:@"Header bidding request failed", NSLocalizedFailureReasonErrorKey:@"Bid request has been sent but failed"}];
                            }
                        }
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(CombineAdSources(adSources, sucAdSources, ^BOOL(id<ATAdSource> adSource, id<ATHeaderBiddingAdSource> HBAdSource) {
                            return HBAdSource.bidPrice >= ([sucAdSources containsObject:(id<ATHeaderBiddingAdSource>)adSource] ? ((id<ATHeaderBiddingAdSource>)adSource).bidPrice : adSource.price);
                        }), @{kATHeaderBiddingRequestResultExtraInfoDetailErrorKey:detailErrors, kATHeaderBiddingExtraInfoUnitGroupsUsingLatestBidInfoKey:adSourcesUsingLatestBidInfo});
                    });
                } else {
                    NSMutableArray<id<ATHeaderBiddingAdSource>> *adSourcesUsingLatestBidInfo = [NSMutableArray<id<ATHeaderBiddingAdSource>> array];
                    [networkItemAdSourceMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<ATHeaderBiddingAdSource>  _Nonnull curAdSource, BOOL * _Nonnull stop) {
                        NSDictionary *latestBidInfo = [curAdSource latestBidInfo];
                        if ([latestBidInfo isKindOfClass:[NSDictionary class]] && latestBidInfo[kUnitGroupBidInfoPriceKey] != nil && latestBidInfo[kUnitGroupBidInfoBidTokenKey] != nil) {
                            curAdSource.bidPrice = [latestBidInfo[kUnitGroupBidInfoPriceKey] doubleValue];
                            curAdSource.bidToken = latestBidInfo[kUnitGroupBidInfoBidTokenKey];
                            [adSourcesUsingLatestBidInfo addObject:curAdSource];
                        } else {
                            detailErrors[@(curAdSource.hash)] = [NSError errorWithDomain:@"com.anythink.HeaderBiddingRequest" code:ATHBErrorBidRequestSentButFailed userInfo:@{NSLocalizedDescriptionKey:@"Header bidding request failed", NSLocalizedFailureReasonErrorKey:@"Bid request has been sent but failed and previously returned bid info exists."}];
                        }
                    }];
                    if ([adSourcesUsingLatestBidInfo count] > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(CombineAdSources(adSources, adSourcesUsingLatestBidInfo, ^BOOL(id<ATAdSource> adSource, id<ATHeaderBiddingAdSource> HBAdSource) {
                                return HBAdSource.bidPrice >= ([adSourcesUsingLatestBidInfo containsObject:(id<ATHeaderBiddingAdSource>)adSource] ? ((id<ATHeaderBiddingAdSource>)adSource).bidPrice : adSource.price);
                            }), @{kATHeaderBiddingRequestResultExtraInfoDetailErrorKey:detailErrors, kATHeaderBiddingExtraInfoUnitGroupsUsingLatestBidInfoKey:adSourcesUsingLatestBidInfo});
                        });
                    } else {
                        NSLog(@"Error occured while running header bidding request:%@; will combine non-header bidding adsource&header bidding adsource with ecpm floor.", error);
                        completion(adSources, @{kATHeaderBiddingRequestResultExtraInfoTotalErrorKey:[error isKindOfClass:[NSError class]] ? error : [NSError errorWithDomain:@"com.anythink.HeaderBiddingRequest" code:ATHBErrorBidRequestSentButFailed userInfo:@{NSLocalizedDescriptionKey:@"Header bidding request failed", NSLocalizedFailureReasonErrorKey:@"Error occured while running header bidding request."}]});
                    }
                }
            }];
        } else {
            NSLog(@"No header bidding supported adsource found, will combine non-header bidding adsource&header bidding adsource with ecpm floor.");
            completion(adSources, @{kATHeaderBiddingRequestResultExtraInfoTotalErrorKey:[NSError errorWithDomain:@"com.anythink.HeaderBiddingRequest" code:ATHBErrorNetworkNotSupported userInfo:@{NSLocalizedDescriptionKey:@"Header bidding request failed", NSLocalizedFailureReasonErrorKey:@"No header bidding supported adsource found."}]});
        }
    } else {
        NSLog(@"HiBid framework not imported properly, will sort adsources by their ecpm floor");
        completion(adSources, @{kATHeaderBiddingRequestResultExtraInfoTotalErrorKey:[NSError errorWithDomain:@"com.anythink.HeaderBiddingRequest" code:ATHBErrorHBKitNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"Header bidding request failed", NSLocalizedFailureReasonErrorKey:@"HiBid framework not imported properly."}]});
    }
}
@end
