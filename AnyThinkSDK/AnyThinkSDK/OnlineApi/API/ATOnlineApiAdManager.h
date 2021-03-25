//
//  ATOnlineApiAdManager.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ATRequestConfiguration, ATOnlineApiPlacementSetting, ATOnlineApiOfferModel,ATThreadSafeAccessor;
@interface ATOnlineApiAdManager : NSObject

@property(nonatomic, strong) ATOnlineApiOfferModel *model;
@property(nonatomic, strong) ATOnlineApiPlacementSetting *setting;
@property(nonatomic, readwrite) ATThreadSafeAccessor *delegateStorageAccessor;
@property(nonatomic, readwrite) NSMutableDictionary<NSString*, id> *delegateStorage;
@property (nonatomic , readwrite, weak) UIViewController *currentViewController;

- (void)requestOnlineApiAdsWithConfiguration:(ATRequestConfiguration *)config;

/**
 If it's not ready, then the return value will be nil.
 */
- (ATOnlineApiOfferModel *)readyOnlineApiAdWithUnitGroupModelID:(NSString *)unitGroupModelID placementSetting:( ATOnlineApiPlacementSetting *)placementSetting;
- (NSString *)priceForReadyUnitGroupModelID:(NSString *)uid placementID:(NSString *)pid;
@end

