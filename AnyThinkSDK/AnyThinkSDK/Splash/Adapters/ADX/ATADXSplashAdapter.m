//
//  ATADXSplashAdapter.m
//  AnyThinkSDK
//
//  Created by Topon on 10/21/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXSplashAdapter.h"
#import "ATADXSplashCustomEvent.h"
#import "ATPlacementModel.h"
#import "ATSplashManager.h"
#import "ATAppSettingManager.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAPI+Internal.h"
#import "ATAdManager+Splash.h"
#import "ATAdAdapter.h"
#import "ATADXSplashAdManager.h"
#import "ATBidInfo.h"
#import "ATBidInfoManager.h"
#import "ATADXPlacementSetting.h"
#import "ATADXOfferModel.h"
#import "ATADXLoader.h"
#import "ATOfferResourceLoader.h"
#import "ATADXTracker.h"
#import "ATSplash.h"

@interface ATADXSplashAdapter()
@property(nonatomic, readonly) ATADXSplashCustomEvent *customEvent;
@end

@implementation ATADXSplashAdapter
+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
    return @{@"unit_id":unitGroupModel.unitID,
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"ad_format":@(ATAdFormatSplash).stringValue,
             @"get_offer":@(2),
             @"ecpoffer":[[ATAPI sharedInstance] exludeAppleIdArray] != nil? [[ATAPI sharedInstance] exludeAppleIdArray]:@[]
    };
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATADXSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.delegate = self.delegateToBePassed;
    
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    _customEvent.unitGroupModel = unitGroupModel;
    _customEvent.setting = [[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:serverInfo placementID:placementModel.placementID];
    
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    _customEvent.requestID = requestID;
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
        
    if(bidInfo.offerDataDict != nil){
        self->_customEvent.price = bidInfo.price;
        self->_customEvent.bidId = bidInfo.bidId;
        self->_customEvent.containerView = [localInfo[kATSplashExtraContainerViewKey] isKindOfClass:[UIView class]] ? localInfo[kATSplashExtraContainerViewKey] : nil;
        
        if (bidInfo.nURL != nil) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
        
        NSMutableDictionary* resultDictionary = [[NSMutableDictionary alloc] initWithDictionary:bidInfo.offerDataDict];
        [resultDictionary setObject:@([bidInfo.expireDate timeIntervalSince1970]) forKey:@"expire_timestamp"];
        [resultDictionary setObject:placementModel.placementID forKey:@"at_placement_id"];
        [resultDictionary setObject:unitGroupModel.unitID forKey:@"at_unit_id"];
        [resultDictionary setObject:[NSString stringWithFormat:@"%ld", placementModel.format] forKey:@"at_format"];
        [resultDictionary setObject:requestID forKey:@"at_request_id"];
        
        ATADXOfferModel *offerModel = [[ATADXOfferModel alloc] initWithDictionary:resultDictionary content:serverInfo];
        _customEvent.offerModel = offerModel;
        //send nurl when adx request is response
        [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventNTKurl offerModel:offerModel extra:nil];
        
        [[ATOfferResourceLoader sharedLoader] loadOfferWithOfferModel:offerModel placementID:_customEvent.setting.placementID resourceDownloadTimeout:_customEvent.setting.resourceDownloadTimeout extra:nil completion:^(NSError *error) {
            if (error == nil) {
                if ([self->_customEvent respondsToSelector:@selector(didLoadADSuccessWithPlacementID:unitID:)]) {
                    [self->_customEvent didLoadADSuccessWithPlacementID:self->_customEvent.setting.placementID unitID:unitGroupModel.unitID];
                }
            }else{
                [[ATADXLoader sharedLoader] removeOfferModel:offerModel];
                [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:self->_customEvent.setting.placementID unitGroupModel:unitGroupModel requestID:requestID];
                if ([self->_customEvent respondsToSelector:@selector(didFailToLoadADWithPlacementID:unitID:error:)]) { [self->_customEvent didFailToLoadADWithPlacementID:self->_customEvent.setting.placementID unitID:unitGroupModel.unitID error:error]; }
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:kATSDKSplashADTooLongToLoadPlacementSettingMsg}]);
    }
}

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel{
    return unitGroupModel.unitID;
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate {
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    ATADXSplashCustomEvent *customEvent = (ATADXSplashCustomEvent *)splash.customEvent;
    [[ATADXSplashAdManager sharedManager] showSplashInKeyWindow:window containerView:customEvent.containerView offerModel:customEvent.offerModel setting:customEvent.setting delegate:(id<ATADXSplashDelegate>)customEvent];
}

@end
