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
#import "ATAdLoader+HeaderBidding.h"
#import "ATAppSettingManager.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Native.h"

NSString *const kATMintegralNativeAssetCustomEvent = @"assets_mintegral_custom_event_key";
@interface ATMintegralNativeAdapter()
@property(nonatomic, readonly) ATMintegralNativeCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATMTGBidNativeAdManager> bidAdManager;
@property(nonatomic, readonly) id<ATMTGNativeAdvancedAd> advancedNativeAd;
@end
@implementation ATMintegralNativeAdapter
+(Class) rendererClass { return [ATMintegralNativeADRenderer class]; }

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
                };
                if ([NSThread currentThread].isMainThread) blk();
                else dispatch_sync(dispatch_get_main_queue(), blk);
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NSClassFromString(@"MTGNativeAdManager") != nil && NSClassFromString(@"MTGBidNativeAdManager") != nil && ([info[@"unit_type"] integerValue] == 1 ? NSClassFromString(@"MTGNativeAdvancedAd") != nil : YES)) {
            self->_customEvent = [ATMintegralNativeCustomEvent new];
            self->_customEvent.requestCompletionBlock = completion;
            self->_customEvent.unitID = info[@"unitid"];
            NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
            self->_customEvent.requestExtra = extraInfo;
            
            ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
            NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
            if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:info[@"unitid"]]; }
                if ([info[@"unit_type"] integerValue] == 0) {
                    self->_bidAdManager = [[NSClassFromString(@"MTGBidNativeAdManager") alloc] initWithPlacementId:info[@"placement_id"] unitID:info[@"unitid"] presentingViewController:nil];
                    self->_customEvent.bidNativeAdManager = self->_bidAdManager;
                    self->_bidAdManager.delegate = self->_customEvent;
                    [self->_bidAdManager loadWithBidToken:[unitGroupModel bidTokenWithRequestID:requestID]];
                } else {
                    [self loadAdvancedNativeWithInfo:info bidToken:[unitGroupModel bidTokenWithRequestID:requestID]];
                }
                [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
            } else {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:info[@"unitid"]]; }
                if ([info[@"unit_type"] integerValue] == 0) {
                    id<ATMTGNativeAdManager> adManager = [[NSClassFromString(@"MTGNativeAdManager") alloc] initWithPlacementId:info[@"placement_id"] unitID:info[@"unitid"] fbPlacementId:nil supportedTemplates:@[[NSClassFromString(@"MTGTemplate") templateWithType:AT_MTGAD_TEMPLATE_BIG_IMAGE adsNum:1]] autoCacheImage:NO adCategory:0 presentingViewController:nil];
                    adManager.delegate = self->_customEvent;
                    self->_customEvent.nativeAdManager = adManager;
                    [adManager loadAds];
                } else {
                    [self loadAdvancedNativeWithInfo:info bidToken:nil];
                }
            }
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"Mintegral has failed to load native.", NSLocalizedFailureReasonErrorKey:@"AT SDK has failed to get MTGNativeAdManager's shared instance; this might be due to Mintegral SDK not being imported or it's imported but a unsupported version is being used."}]);
        }
    });
}

-(void) loadAdvancedNativeWithInfo:(NSDictionary*)info bidToken:(NSString*)bidToken {
    NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
    CGSize size = [extraInfo[kExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [extraInfo[kExtraInfoNativeAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 250.0f);
    
    _advancedNativeAd = [[NSClassFromString(@"MTGNativeAdvancedAd") alloc] initWithPlacementID:info[@"placement_id"] unitID:info[@"unitid"] adSize:size rootViewController:nil];
    _advancedNativeAd.delegate = _customEvent;
    if (info[@"video_muted"] != nil) { _advancedNativeAd.mute = ![info[@"video_muted"] boolValue]; }//Inverted; see docs for more detail
    if (info[@"video_autoplay"] != nil) { _advancedNativeAd.autoPlay = [info[@"video_autoplay"] integerValue]; }
    if (info[@"close_button"] != nil) { _advancedNativeAd.showCloseButton = ![info[@"close_button"] boolValue]; }//Inverted; see docs for more detail
    
    if (bidToken != nil) {
        [_advancedNativeAd loadAdWithBidToken:bidToken];
    } else {
        [_advancedNativeAd loadAd];
    }
}
@end
