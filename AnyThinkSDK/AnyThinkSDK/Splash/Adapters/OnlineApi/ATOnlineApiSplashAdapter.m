//
//  ATOnlineApiSplashAdapter.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiSplashAdapter.h"
#import "ATOnlineApiSplashCustomEvent.h"
#import "ATSplashManager.h"
#import "ATOnlineApiSplashAdManager.h"
#import "ATRequestConfiguration.h"
#import "ATAppSettingManager.h"
#import "NSDictionary+KAKit.h"
#import "ATAdManager+Internal.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATSplash.h"
#import "ATOnlineApiLoader.h"

@interface ATOnlineApiSplashAdapter ()
@property(nonatomic, readonly) ATOnlineApiSplashCustomEvent *customEvent;

@end

@implementation ATOnlineApiSplashAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATOnlineApiSplashCustomEvent alloc]initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.delegate = self.delegateToBePassed;
    
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    _customEvent.unitGroupModel = unitGroupModel;
    _customEvent.placementModel = placementModel;
    _customEvent.setting = [[ATOnlineApiPlacementSetting alloc] initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:serverInfo placementID:placementModel.placementID];
    
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    
    _customEvent.containerView = [localInfo[kATSplashExtraContainerViewKey] isKindOfClass:[UIView class]] ? localInfo[kATSplashExtraContainerViewKey] : nil;
    
    ATRequestConfiguration *config = [ATRequestConfiguration new];
    config.networkFirmID = unitGroupModel.networkFirmID;
    config.extraInfo = serverInfo;
    config.setting = _customEvent.setting;
    config.unitID = unitGroupModel.unitID;
    config.delegate = _customEvent;
    config.requestID = requestID;
    config.groupID = placementModel.groupID;
    config.trafficGroupID = placementModel.trafficGroupID;
    [[ATOnlineApiSplashAdManager sharedManager] requestOnlineApiAdsWithConfiguration:config];
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate {
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    ATOnlineApiSplashCustomEvent *customEvent = (ATOnlineApiSplashCustomEvent *)splash.customEvent;
    ATOnlineApiOfferModel *offerModel = [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:customEvent.unitGroupModel.unitID placementID:customEvent.placementModel.placementID];
    [[ATOnlineApiSplashAdManager sharedManager] showSplashInKeyWindow:window containerView:customEvent.containerView offerModel:offerModel setting:customEvent.setting delegate:(id<ATOnlineApiSplashDelegate>)customEvent];
}
@end
