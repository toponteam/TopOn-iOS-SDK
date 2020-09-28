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

NSString *const kATMintegralNativeAssetCustomEvent = @"assets_mintegral_custom_event_key";
@interface ATMintegralNativeAdapter()
@property(nonatomic, readonly) ATMintegralNativeCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATMTGBidNativeAdManager> bidAdManager;
@property(nonatomic, readonly) id<ATMTGNativeAdvancedAd> advancedNativeAd;
@end
@implementation ATMintegralNativeAdapter
+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    return @{@"display_manager_ver":[NSClassFromString(@"MTGSDK") sdkVersion],
             @"unit_id":unitGroupModel.content[@"unitid"] != nil ? unitGroupModel.content[@"unitid"] : @"",
             @"app_id":unitGroupModel.content[@"appid"] != nil ? unitGroupModel.content[@"appid"] : @"",
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"buyeruid":[NSClassFromString(@"MTGBiddingSDK") buyerUID] != nil ? [NSClassFromString(@"MTGBiddingSDK") buyerUID] : @"",
             @"ad_format":@(ATAdFormatNative).stringValue
    };
}

+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
        [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
        void(^blk)(void) = ^{
            BOOL set = NO;
            BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
            if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
            [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
        };
        if ([NSThread currentThread].isMainThread) blk();
        else dispatch_sync(dispatch_get_main_queue(), blk);
    }
    
    if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:2 unitId:info[@"unitid"]]; }
    [NSClassFromString(@"MTGBiddingRequest") getBidWithRequestParameter:[[NSClassFromString(@"MTGBiddingRequestParameter") alloc] initWithPlacementId:info[@"placement_id"] unitId:info[@"unitid"] basePrice:@0] completionHandler:^(id<ATMTGBiddingResponse> bidResponse) {
        if (completion != nil) { completion(bidResponse.success ? [ATBidInfo bidInfoWithPlacementID:placementModel.placementID unitGroupUnitID:unitGroupModel.unitID token:bidResponse.bidToken price:bidResponse.price expirationInterval:unitGroupModel.bidTokenTime customObject:bidResponse] : nil, bidResponse.success ? nil : (bidResponse.error != nil ? bidResponse.error : [NSError errorWithDomain:@"com.anythink.MTGInterstitialHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"MTGSDK has failed to get bid info"}])); }
    }];
}

+(Class) rendererClass {
    return [ATMintegralNativeADRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    BOOL set = NO;
                    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                    if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:serverInfo[@"appid"] ApiKey:serverInfo[@"appkey"]];
                };
                if ([NSThread currentThread].isMainThread) blk();
                else dispatch_sync(dispatch_get_main_queue(), blk);
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NSClassFromString(@"MTGNativeAdManager") != nil && NSClassFromString(@"MTGBidNativeAdManager") != nil && ([serverInfo[@"unit_type"] integerValue] == 1 ? NSClassFromString(@"MTGNativeAdvancedAd") != nil : YES)) {
            _customEvent = [ATMintegralNativeCustomEvent new];
            _customEvent.requestCompletionBlock = completion;
            _customEvent.unitID = serverInfo[@"unitid"];
            NSDictionary *extraInfo = localInfo;
            _customEvent.requestExtra = extraInfo;
            
            ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
            ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
            NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
            ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            if (bidInfo != nil) {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                    [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:serverInfo[@"unitid"]];
                }
                
                if (bidInfo.nURL != nil) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
                if ([serverInfo[@"unit_type"] integerValue] == 0) {
                    _bidAdManager = [[NSClassFromString(@"MTGBidNativeAdManager") alloc] initWithPlacementId:serverInfo[@"placement_id"] unitID:serverInfo[@"unitid"] presentingViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
                    _customEvent.bidNativeAdManager = _bidAdManager;
                    _bidAdManager.delegate = _customEvent;
                    _customEvent.price = bidInfo.price;
                    [_bidAdManager loadWithBidToken:bidInfo.token];
                } else {
                    [self loadAdvancedNativeWithInfo:serverInfo localInfo:localInfo bidToken:bidInfo.token];
                }
                [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            } else {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                    [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:serverInfo[@"unitid"]];
                }
                if ([serverInfo[@"unit_type"] integerValue] == 0) {
                    id<ATMTGNativeAdManager> adManager = [[NSClassFromString(@"MTGNativeAdManager") alloc] initWithPlacementId:serverInfo[@"placement_id"] unitID:serverInfo[@"unitid"] fbPlacementId:nil supportedTemplates:@[[NSClassFromString(@"MTGTemplate") templateWithType:AT_MTGAD_TEMPLATE_BIG_IMAGE adsNum:1]] autoCacheImage:NO adCategory:0 presentingViewController:nil];
                    adManager.delegate = _customEvent;
                    _customEvent.nativeAdManager = adManager;
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
@end
