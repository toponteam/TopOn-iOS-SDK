//
//  AppnextAdsContainer.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 24/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdsContainerDelegate.h>

@interface AppnextAdsContainer : NSObject<AppnextAdsContainerProtocol>

@property (nonatomic, assign) ANLoadingState loadingState;
@property (nonatomic, assign) NSUInteger loadingRetries;
@property (nonatomic, strong) NSString *attachedLoadedBannerId;
@property (nonatomic, assign) time_t responseTime;
@property (nonatomic, assign) time_t responseValidityPeriod;
@property (nonatomic, strong) NSArray<AppnextAdData *> *adsArray;
@property (nonatomic, strong) NSMutableSet<AppnextWeakReferenceWrapper<id<AppnextAdsContainerDelegate>> *> *delegates;

+ (instancetype) adsContainerWithPlacementID:(NSString *)placementID
                                     withTID:(NSString *)tid
                                    withAUID:(NSString *)auid
                              withCategories:(NSString *)categories
                                withPostback:(NSString *)postback
                                   withCount:(NSUInteger)count;

- (instancetype) initWithPlacementID:(NSString *)placement
                             withTID:(NSString *)tid
                            withAUID:(NSString *)auid
                      withCategories:(NSString *)categories
                        withPostback:(NSString *)postback
                           withCount:(NSUInteger)count;
@end
