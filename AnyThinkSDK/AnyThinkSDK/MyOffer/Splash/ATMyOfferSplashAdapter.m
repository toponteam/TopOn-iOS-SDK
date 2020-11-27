//
//  ATMyOfferSplashAdapter.m
//  AnyThinkMyOffer
//
//  Created by stephen on 8/7/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>
#import "ATMyOfferSplashAdapter.h"
#import "ATMyOfferSplashCustomEvent.h"
#import "ATMyOfferUtilities.h"
#import "ATPlacementModel.h"
#import "ATSplashManager.h"
#import "ATAppSettingManager.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"


@interface ATMyOfferSplashAdapter()
@property(nonatomic, readonly) ATMyOfferSplashCustomEvent *customEvent;
@end

@implementation ATMyOfferSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    ATMyOfferOfferModel *offerModel = [ATMyOfferUtilities getMyOfferModelWithOfferId:placementModel.offers offerID:serverInfo[@"my_oid"]];
    _customEvent = [[ATMyOfferSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.delegate = self.delegateToBePassed;
    __weak typeof(self) weakSelf = self;
    NSDate *startDate = [NSDate date];
    [[ATMyOfferOfferManager sharedManager] loadOfferWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:localInfo completion:^(NSError *error) {
        NSTimeInterval tolerateTimeout = [localInfo containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [localInfo[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];
        NSTimeInterval loadTime = [[NSDate date] timeIntervalSinceDate:startDate];
        if (error == nil && loadTime <= tolerateTimeout && offerModel != nil && offerModel.offerID != nil && weakSelf.customEvent != nil) {
            [weakSelf.customEvent trackSplashAdLoaded:offerModel];
            //show splash
            weakSelf.customEvent.window = localInfo[kATSplashExtraWindowKey];
            
            weakSelf.customEvent.containerView = [localInfo[kATSplashExtraContainerViewKey] isKindOfClass:[UIView class]] ? localInfo[kATSplashExtraContainerViewKey] : nil;
            [[ATMyOfferOfferManager sharedManager] showSplashInKeyWindow:weakSelf.customEvent.window containerView:weakSelf.customEvent.containerView offerModel:offerModel setting:placementModel.myOfferSetting delegate:self->_customEvent];
        }else{
            [weakSelf.customEvent trackSplashAdLoadFailed:error != nil ? error:[NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:kATSDKSplashADTooLongToLoadPlacementSettingMsg}]];
        }
    }];
}
@end
