//
//  ATAdManager+Banner.m
//  AnyThinkBanner
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdManager+Banner.h"
#import "ATBannerView+Internal.h"
#import "ATBannerManager.h"
#import "ATBanner.h"
#import "ATAdManager+Internal.h"
#import "ATBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerAdapter.h"
#import "Utilities.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATPlacementSettingManager.h"
#import "ATCapsManager.h"

NSString *const kATBannerDelegateExtraNetworkIDKey = @"network_firm_id";
NSString *const kATBannerDelegateExtraAdSourceIDKey = @"adsource_id";
NSString *const kATBannerDelegateExtraIsHeaderBidding = @"adsource_isHeaderBidding";
NSString *const kATBannerDelegateExtraPrice = @"adsource_price";
NSString *const kATBannerDelegateExtraPriority = @"adsource_index";
NSString *const kATBannerLoadingExtraParameters = @"banner_parameters";
NSString *const kATAdLoadingExtraBannerAdSizeKey = @"banner_ad_size";
NSString *const kATAdLoadingExtraBannerSizeAdjustKey = @"adust_size";
NSString *const kATAdLoadingExtraAdmobBannerSizeKey = @"inline_adaptive_width";
NSString *const kATAdLoadingExtraAdmobAdSizeFlagsKey = @"Admob_AdSize_Flags";//Admob AdSize flags
@implementation ATAdManager (Banner)
-(BOOL) bannerAdReadyForPlacementID:(NSString*)placementID {
    BOOL ready = [self bannerReadyForPlacementID:placementID caller:ATAdManagerReadyAPICallerReady banner:nil];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:2 api:kATAPIIsReady]];
    info[@"result"] = ready ? @"YES" : @"NO";
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", info] type:ATLogTypeTemporary];
    return ready;
}

-(BOOL) bannerReadyForPlacementID:(NSString*)placementID caller:(ATAdManagerReadyAPICaller)caller banner:(ATBanner* __strong*)banner {
    return [[ATAdManager sharedManager] adReadyForPlacementID:placementID caller:caller context:^BOOL(NSDictionary *__autoreleasing *extra) {
        ATBanner *localBanner = [[ATBannerManager sharedManager] bannerForPlacementID:placementID invalidateStatus:caller == ATAdManagerReadyAPICallerShow extra:extra];
        if (banner != nil) { *banner = localBanner; }
        return localBanner != nil;
    }];
}
-(ATBannerView*)retrieveBannerViewForPlacementID:(NSString*)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:2 api:kATAPIShow]] type:ATLogTypeTemporary];
    
    NSError *error = nil;
    ATBannerView *adView = nil;
    ATBanner *banner = nil;
    if ([self bannerReadyForPlacementID:placementID caller:ATAdManagerReadyAPICallerShow banner:&banner]) {
        adView = [[ATBannerView alloc] initWithFrame:CGRectMake(.0f, .0f, banner.customEvent.size.width, banner.customEvent.size.height) banner:banner];
        [[ATCapsManager sharedManager] setShowFlagForPlacementID:placementID requestID:banner.requestID];
        [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:placementID];
        [[ATAdManager sharedManager] setAdBeingShownFlagForPlacementID:placementID];
    } else {
        error = [NSError errorWithDomain:ATADShowingErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to show Banner ad", NSLocalizedFailureReasonErrorKey:@"Banner ad's not ready for the placement"}];
    }
    return adView;
}
-(ATBannerView*)retrieveBannerViewForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    return [[ATAdManager sharedManager]retrieveBannerViewForPlacementID:placementID];
}
@end
