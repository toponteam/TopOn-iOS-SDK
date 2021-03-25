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
#import "ATSplash.h"

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
    [[ATMyOfferOfferManager sharedManager] loadOfferWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:localInfo completion:^(NSError *error) {
        [weakSelf.customEvent trackSplashAdLoaded:offerModel adExtra:nil];
        //show splash
        weakSelf.customEvent.containerView = [localInfo[kATSplashExtraContainerViewKey] isKindOfClass:[UIView class]] ? localInfo[kATSplashExtraContainerViewKey] : nil;
    }];
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate {
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    ATMyOfferSplashCustomEvent *customEvent = (ATMyOfferSplashCustomEvent *)splash.customEvent;
    ATPlacementModel *placementModel = (ATPlacementModel*)customEvent.serverInfo[kAdapterCustomInfoPlacementModelKey];
    ATMyOfferOfferModel *offerModel = [ATMyOfferUtilities getMyOfferModelWithOfferId:placementModel.offers offerID:customEvent.serverInfo[@"my_oid"]];
    [[ATMyOfferOfferManager sharedManager] showSplashInKeyWindow:window containerView:customEvent.containerView offerModel:offerModel setting:placementModel.myOfferSetting delegate:customEvent];
}

@end
