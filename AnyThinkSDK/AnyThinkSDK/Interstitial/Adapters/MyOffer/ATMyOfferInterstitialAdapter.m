//
//  ATMyOfferInterstitialAdapter.m
//  AnyThinkMyOfferInterstitialAdapter
//
//  Created by Topon on 2019/10/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferInterstitialAdapter.h"
#import "ATMyOfferInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import <objc/runtime.h>
#import "ATAdAdapter.h"
#import "ATAdManager+Interstitial.h"
#import "ATAgentEvent.h"

@interface ATMyOfferInterstitialAdapter()
@property(nonatomic, readonly) ATMyOfferInterstitialCustomEvent *customEvent;
@end

@implementation ATMyOfferInterstitialAdapter
+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
    ATMyOfferOfferModel *offerModel = Interstitial_FindMyOfferModel(placementModel.offers, unitGroup.content[@"my_oid"]);
    if (offerModel != nil && ![[ATMyOfferOfferManager sharedManager] checkExcludedWithOfferModel:offerModel] && [[ATMyOfferOfferManager sharedManager] resourceReadyForOfferModel:offerModel]) {
        ATMyOfferInterstitialCustomEvent *customEvent = [[ATMyOfferInterstitialCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
        ATInterstitial *ad = [[ATInterstitial alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kInterstitialAssetsUnitIDKey:offerModel.offerID, kInterstitialAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:offerModel} unitGroup:unitGroup finalWaterfall:finalWaterfall];
        return ad;
    } else {
        return nil;
    }
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return YES;
}

+(BOOL) adReadyWithCustomObject:(ATMyOfferOfferModel*)customObject info:(NSDictionary*)info {
    return [[ATMyOfferOfferManager sharedManager] offerReadyForInterstitialOfferModel:customObject];
}

+(ATMyOfferOfferModel*) resourceReadyMyOfferForPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info {
    ATMyOfferOfferModel *offerModel = Interstitial_FindMyOfferModel(placementModel.offers, unitGroupModel.content[@"my_oid"]);
    return [[ATMyOfferOfferManager sharedManager] resourceReadyForOfferModel:offerModel] ? offerModel : nil;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    ATMyOfferInterstitialCustomEvent *customEvent = (ATMyOfferInterstitialCustomEvent*)interstitial.customEvent;
    customEvent.delegate = delegate;
    customEvent.interstitial = interstitial;
    interstitial.customEvent.delegate = delegate;
    [[ATMyOfferOfferManager sharedManager] showInterstitialWithOfferModel:interstitial.customObject setting:interstitial.placementModel.myOfferSetting viewController:viewController delegate:customEvent];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

ATMyOfferOfferModel* Interstitial_FindMyOfferModel(NSArray<ATMyOfferOfferModel*>* offers, NSString *offerID) {
    ATMyOfferOfferModel *offerModel = nil;
    @try {
        offerModel = offers[[[offers mutableArrayValueForKey:@"offerID"] indexOfObject:offerID]];
    } @catch (NSException *exception) {
        [ATLogger logError:[NSString stringWithFormat:@"Exception occured while finding offer with id:%@ in offers:%@", offerID, offers] type:ATLogTypeExternal];
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyCrashInfoKey placementID:nil unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoCrashReason: exception.reason, kAgentEventExtraInfoCallStackSymbols: [NSThread callStackSymbols].firstObject}];

    } @finally {
        return offerModel;
    }
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    ATMyOfferOfferModel *offerModel = Interstitial_FindMyOfferModel(placementModel.offers, serverInfo[@"my_oid"]);
    
    _customEvent = [[ATMyOfferInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    __weak typeof(self) weakSelf = self;
    [[ATMyOfferOfferManager sharedManager]loadOfferWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:localInfo completion:^(NSError *error) {
        if (error == nil) {
            if (offerModel != nil && offerModel.offerID != nil && weakSelf.customEvent != nil) {
                [weakSelf.customEvent trackInterstitialAdLoaded:offerModel adExtra:nil];
            }
        }else{
            [weakSelf.customEvent trackInterstitialAdLoadFailed:error];
        }
    }];
}

@end
