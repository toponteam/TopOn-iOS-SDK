//
//  ATMintegralNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 18/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralNativeAdapter.h"
#import "ATAPI+Internal.h"
#import "ATMintegralNativeADRenderer.h"
#import "NSObject+ExtraInfo.h"
#import "ATMintegralNativeCustomEvent.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATBidInfo.h"
#import "ATBidInfoManager.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Native.h"
#import "ATMintegralBaseManager.h"

NSString *const kATMintegralNativeAssetCustomEvent = @"assets_mintegral_custom_event_key";
@interface ATMintegralNativeAdapter()
@property(nonatomic, readonly) ATMintegralNativeCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATMTGBidNativeAdManager> bidAdManager;
@property(nonatomic, readonly) id<ATMTGNativeAdvancedAd> advancedNativeAd;
@end
@implementation ATMintegralNativeAdapter
+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
    return @{@"display_manager_ver":[NSClassFromString(@"MTGSDK") sdkVersion],
             @"unit_id":unitGroupModel.content[@"unitid"] != nil ? unitGroupModel.content[@"unitid"] : @"",
             @"app_id":unitGroupModel.content[@"appid"] != nil ? unitGroupModel.content[@"appid"] : @"",
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"buyeruid":[NSClassFromString(@"MTGBiddingSDK") buyerUID] != nil ? [NSClassFromString(@"MTGBiddingSDK") buyerUID] : @"",
             @"ad_format":@(ATAdFormatNative).stringValue
    };
}

+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    [ATMintegralBaseManager bidRequestWithPlacementModel:placementModel unitGroupModel:unitGroupModel info:info completion:completion];
}

+(Class) rendererClass {
    return [ATMintegralNativeADRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMintegralBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NSClassFromString(@"MTGNativeAdManager") != nil && NSClassFromString(@"MTGBidNativeAdManager") != nil && ([serverInfo[@"unit_type"] integerValue] == 1 ? NSClassFromString(@"MTGNativeAdvancedAd") != nil : YES)) {
            self->_customEvent = [ATMintegralNativeCustomEvent new];
            self->_customEvent.requestCompletionBlock = completion;
            self->_customEvent.unitID = serverInfo[@"unitid"];
            NSDictionary *extraInfo = localInfo;
            self->_customEvent.requestExtra = extraInfo;
            
            ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
            ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
            NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
            ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            self->_customEvent.price = bidInfo ? bidInfo.price : unitGroupModel.price;
            self->_customEvent.bidId = bidInfo ? bidInfo.bidId : @"";
            if (bidInfo != nil) {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                    [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:serverInfo[@"unitid"]];
                }
                
                if (bidInfo.nURL != nil) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
                if ([serverInfo[@"unit_type"] integerValue] == 0) {
                    self->_bidAdManager = [[NSClassFromString(@"MTGBidNativeAdManager") alloc] initWithPlacementId:serverInfo[@"placement_id"] unitID:serverInfo[@"unitid"] presentingViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
                    self->_customEvent.bidNativeAdManager = self->_bidAdManager;
                    self->_bidAdManager.delegate = self->_customEvent;
                    [self->_bidAdManager loadWithBidToken:bidInfo.bidId];
                } else {
                    [self loadAdvancedNativeWithInfo:serverInfo localInfo:localInfo bidToken:bidInfo.bidId];
                }
                [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            } else {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                    [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:serverInfo[@"unitid"]];
                }
                if ([serverInfo[@"unit_type"] integerValue] == 0) {
                    id<ATMTGNativeAdManager> adManager = [[NSClassFromString(@"MTGNativeAdManager") alloc] initWithPlacementId:serverInfo[@"placement_id"] unitID:serverInfo[@"unitid"] fbPlacementId:nil supportedTemplates:@[[NSClassFromString(@"MTGTemplate") templateWithType:AT_MTGAD_TEMPLATE_BIG_IMAGE adsNum:[serverInfo[@"request_num"]integerValue]]] autoCacheImage:NO adCategory:0 presentingViewController:nil];
                    adManager.delegate = self->_customEvent;
                    self->_customEvent.nativeAdManager = adManager;
                    [adManager loadAds];
                } else {
                    [self loadAdvancedNativeWithInfo:serverInfo localInfo:localInfo bidToken:nil];
                }
            }
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mintegral"]}]);
        }
    });
}

-(void) loadAdvancedNativeWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo bidToken:(NSString*)bidToken {
    NSDictionary *extraInfo = localInfo;
    CGSize size = [extraInfo[kExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [extraInfo[kExtraInfoNativeAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 250.0f);
    
    _advancedNativeAd = [[NSClassFromString(@"MTGNativeAdvancedAd") alloc] initWithPlacementID:serverInfo[@"placement_id"] unitID:serverInfo[@"unitid"] adSize:size rootViewController:nil];
    _advancedNativeAd.delegate = _customEvent;
    if (serverInfo[@"video_muted"] != nil) { _advancedNativeAd.mute = ![serverInfo[@"video_muted"] boolValue]; }//Inverted; see docs for more detail
    if (serverInfo[@"video_autoplay"] != nil) { _advancedNativeAd.autoPlay = [serverInfo[@"video_autoplay"] integerValue]; }
    if (serverInfo[@"close_button"] != nil) { _advancedNativeAd.showCloseButton = ![serverInfo[@"close_button"] boolValue]; }//Inverted; see docs for more detail
    
    if (bidToken != nil) {
        [_advancedNativeAd loadAdWithBidToken:bidToken];
    } else {
        [_advancedNativeAd loadAd];
    }
}

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    return content[@"unitid"];
}

@end
