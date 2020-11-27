//
//  ATADXAdManager.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATUnitGroupModel.h"
#import "ATADXPlacementSetting.h"
#import "ATADXAdLoadingDelegate.h"
#import "ATBidInfo.h"
#import "ATADXInterstitialDelegate.h"
#import "ATADXRewardedVideoDelegate.h"
#import "ATPlacementModel.h"
#import "ATThreadSafeAccessor.h"

@protocol ATADXAdLoadingDelegate;
@interface ATADXAdManager : NSObject

@property(nonatomic, strong) NSDictionary *extra;
@property(nonatomic, readwrite) NSMutableDictionary<NSString*, id> *delegateStorage;
@property(nonatomic, readwrite) ATThreadSafeAccessor *delegateStorageAccessor;
@property (nonatomic , readwrite, strong) ATADXOfferModel *offerModel;
@property (nonatomic, readwrite) ATADXPlacementSetting *setting;
@property (nonatomic , readwrite, weak) UIViewController *currentViewController;


-(void) loadADWithUnitGroup:(ATUnitGroupModel*)unitGroupModel bidInfo:(ATBidInfo*) bidInfo setting:(ATADXPlacementSetting*)setting placementModel:(ATPlacementModel *)placementModel content:(NSDictionary *)content requestID:(NSString *)requestID delegate:(id<ATADXAdLoadingDelegate>)delegate;
-(BOOL) readyForUnitGroupModel:(ATUnitGroupModel*)unitGroupModel setting:(ATADXPlacementSetting*)setting;
-(NSString *) priceForReadyUnitGroupModel:(ATUnitGroupModel*)unitGroupModel setting:(ATADXPlacementSetting*)setting;
@end
