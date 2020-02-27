//
//  ATMintegralBannerAdapter.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/11/15.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "ATMintegralBannerAdapter.h"
#import "ATMintegralBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Banner.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"

@interface ATMintegralBannerAdapter ()
@property(nonatomic, readonly) id<ATMTGBannerAdView> bannerView;
@property(nonatomic, readonly) ATMintegralBannerCustomEvent *customEvent;
@end

@implementation ATMintegralBannerAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMintegral]) {
                        NSDictionary *consent = [ATAPI sharedInstance].networkConsentInfo[kNetworkNameMintegral];
                        if ([consent isKindOfClass:[NSDictionary class]]) {
                            [consent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                [[NSClassFromString(@"MTGSDK") sharedInstance] setUserPrivateInfoType:[key integerValue] agree:[obj boolValue]];
                            }];
                        }
                    } else {
                        BOOL set = NO;
                        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                        if (set) {
                            /*
                             consentStatus: 1 Personalized, 0 Nonpersonalized
                             */
                            id<ATMTGSDK> mtgSDK = [NSClassFromString(@"MTGSDK") sharedInstance];
                            mtgSDK.consentStatus = !limit;
                        }
                        
                    }
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
                };
                if ([NSThread mainThread]) blk();
                else dispatch_sync(dispatch_get_main_queue(), blk);
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MTGSDK") != nil && NSClassFromString(@"MTGBannerAdView") != nil) {
        NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
        CGSize adSize = [extraInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [extraInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 50.0f);
        _customEvent = [[ATMintegralBannerCustomEvent alloc]initWithUnitID:info[@"unitid"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_bannerView = [[NSClassFromString(@"MTGBannerAdView") alloc] initBannerAdViewWithBannerSizeType:[ATMintegralBannerAdapter sizeToMTGBannerSizeType:unitGroupModel.adSize] unitId:info[@"unitid"] rootViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]]];
            self->_bannerView.delegate = self->_customEvent;
            if ([info[@"size"] isEqualToString:@"smart"]) {
                self->_bannerView.frame = CGRectMake(0, 0, adSize.width, adSize.height);
            }
            if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
                [self->_bannerView loadBannerAdWithBidToken:[unitGroupModel bidTokenWithRequestID:requestID]];
                [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
            }else {
                [self->_bannerView loadBannerAd];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"MTG"]}]);
    }
}

+(ATMTGBannerSizeType) sizeToMTGBannerSizeType:(CGSize)size {
    if (size.width == 320 && size.height == 50) {
        return ATMTGStandardBannerType320x50;
    } else if (size.width == 320 && size.height == 90) {
        return ATMTGLargeBannerType320x90;
    } else if (size.width == 300 && size.height == 250) {
        return ATMTGMediumRectangularBanner300x250;
    } else {
        return ATMTGSmartBannerType;
    }
}
@end
