//
//  ATMyOfferBannerAdapter.m
//  AnyThinkMyOffer
//
//  Created by stephen on 11/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>
#import "ATMyOfferBannerAdapter.h"
#import "ATMyOfferBannerCustomEvent.h"
#import "ATMyofferBannerSharedDelegate.h"
#import "ATMyOfferUtilities.h"
#import "ATPlacementModel.h"
#import "ATBannerManager.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"

@interface ATMyOfferBannerAdapter()
@property(nonatomic) ATMyOfferBannerView* adView;
@property(nonatomic, readonly) ATMyOfferBannerCustomEvent *customEvent;
@end
@implementation ATMyOfferBannerAdapter

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
    ATMyOfferOfferModel *offerModel = [ATMyOfferUtilities getMyOfferModelWithOfferId:placementModel.offers offerID:unitGroup.content[@"my_oid"]];
    if (offerModel != nil && ![[ATMyOfferOfferManager sharedManager] checkExcludedWithOfferModel:offerModel] && [[ATMyOfferOfferManager sharedManager] resourceReadyForOfferModel:offerModel]) {
        
        NSDictionary *loadExtraInfo = [[ATAdManager sharedManager] lastExtraInfoForPlacementID:placementModel.placementID];
        if (loadExtraInfo != nil) {
            ATMyOfferBannerCustomEvent *customEvent = [[ATMyOfferBannerCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:loadExtraInfo];
            ATMyOfferBannerView* bannerView = [[ATMyOfferBannerSharedDelegate sharedDelegate] retrieveBannerViewWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:nil delegate:customEvent];
            if(bannerView != nil){
                ATBanner *banner = [[ATBanner alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kBannerAssetsUnitIDKey:offerModel.offerID, kBannerAssetsCustomEventKey:customEvent, kBannerAssetsBannerViewKey:bannerView} unitGroup:unitGroup finalWaterfall:finalWaterfall];
                return banner;
            }else{
                return nil;
            }
        }else{
            return nil;
        }
    } else {
        return nil;
    }
}

+(ATMyOfferOfferModel*) resourceReadyMyOfferForPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info {
    ATMyOfferOfferModel *offerModel = [ATMyOfferUtilities getMyOfferModelWithOfferId:placementModel.offers offerID:unitGroupModel.content[@"my_oid"]];
    return [[ATMyOfferOfferManager sharedManager] resourceReadyForOfferModel:offerModel] ? offerModel : nil;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return YES;
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    ATMyOfferOfferModel *offerModel = [ATMyOfferUtilities getMyOfferModelWithOfferId:placementModel.offers offerID:serverInfo[@"my_oid"]];
    _customEvent = [[ATMyOfferBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    __weak typeof(self) weakSelf = self;
    [[ATMyOfferOfferManager sharedManager] loadOfferWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:localInfo completion:^(NSError *error) {
        if (error == nil) {
            if (offerModel != nil && offerModel.offerID != nil && weakSelf.customEvent != nil) {
                ATMyOfferBannerView* bannerView = [[ATMyOfferBannerSharedDelegate sharedDelegate] retrieveBannerViewWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:nil delegate:weakSelf.customEvent];
                if(bannerView != nil){
                    [weakSelf.customEvent trackBannerAdLoaded:bannerView adExtra:nil];
                }else{
                    [weakSelf.customEvent trackBannerAdLoadFailed:[NSError errorWithDomain:@"com.anythink.MyOfferBanner" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to show banner", NSLocalizedFailureReasonErrorKey:@"Banner's not ready for resource"}]];
                }
            }
        }else{
            [weakSelf.customEvent trackBannerAdLoadFailed:error];
        }
    }];
}
@end
