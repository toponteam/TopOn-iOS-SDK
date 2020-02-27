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

static NSString *const kMyOfferClassName = @"ATMyOfferOfferManager";

@interface ATMyOfferInterstitialAdapter()
@property(nonatomic, readonly) ATMyOfferInterstitialCustomEvent *customEvent;
@end

@implementation ATMyOfferInterstitialAdapter
+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATMyOfferOfferModel *offerModel = Interstitial_FindMyOfferModel(placementModel.offers, unitGroup.content[@"my_oid"]);
    if (offerModel != nil && [[NSClassFromString(kMyOfferClassName) sharedManager] resourceReadyForOfferModel:offerModel]) {
        ATMyOfferInterstitialCustomEvent *customEvent = [[ATMyOfferInterstitialCustomEvent alloc] initWithUnitID:unitGroup.content[@"my_oid"] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
        ATInterstitial *ad = [[ATInterstitial alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kInterstitialAssetsUnitIDKey:offerModel.offerID, kInterstitialAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:offerModel} unitGroup:unitGroup];
        return ad;
    } else {
        return nil;
    }
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return YES;
}

+(BOOL) adReadyWithCustomObject:(ATMyOfferOfferModel*)customObject info:(NSDictionary*)info {
    return [[NSClassFromString(kMyOfferClassName) sharedManager] offerReadyForOfferModel:customObject];
}

+(ATMyOfferOfferModel*) resourceReadyMyOfferForPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info {
    ATMyOfferOfferModel *offerModel = Interstitial_FindMyOfferModel(placementModel.offers, unitGroupModel.content[@"my_oid"]);
    return [[NSClassFromString(kMyOfferClassName) sharedManager] resourceReadyForOfferModel:offerModel] ? offerModel : nil;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    ATMyOfferInterstitialCustomEvent *customEvent = (ATMyOfferInterstitialCustomEvent*)interstitial.customEvent;
    customEvent.delegate = delegate;
    customEvent.interstitial = interstitial;
    interstitial.customEvent.delegate = delegate;
    [[NSClassFromString(kMyOfferClassName) sharedManager] showInterstitialWithOfferModel:interstitial.customObject setting:interstitial.placementModel.myOfferSetting viewController:viewController delegate:customEvent];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMyOffer]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMyOffer];
            if (NSClassFromString(kMyOfferClassName) != nil) { [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameMyOffer]; }
        }
    }
    return self;
}

ATMyOfferOfferModel* Interstitial_FindMyOfferModel(NSArray<ATMyOfferOfferModel*>* offers, NSString *offerID) {
    ATMyOfferOfferModel *offerModel = nil;
    @try {
        offerModel = offers[[[offers mutableArrayValueForKey:@"offerID"] indexOfObject:offerID]];
    } @catch (NSException *exception) {
        [ATLogger logError:[NSString stringWithFormat:@"Exception occured while finding offer with id:%@ in offers:%@", offerID, offers] type:ATLogTypeExternal];
    } @finally {
        return offerModel;
    }
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kMyOfferClassName) != nil) {
        ATPlacementModel *placementModel = (ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey];
        ATMyOfferOfferModel *offerModel = Interstitial_FindMyOfferModel(placementModel.offers, info[@"my_oid"]);
        
        _customEvent = [[ATMyOfferInterstitialCustomEvent alloc] initWithUnitID:offerModel.offerID customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        __weak typeof(self) weakSelf = self;
        [[NSClassFromString(kMyOfferClassName) sharedManager]loadOfferWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:nil completion:^(NSError *error) {
            if (error == nil) {
                if (offerModel != nil && offerModel.offerID != nil && weakSelf.customEvent != nil) {
                    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithDictionary:@{kInterstitialAssetsUnitIDKey:offerModel.offerID, kInterstitialAssetsCustomEventKey:weakSelf.customEvent, kAdAssetsCustomObjectKey:offerModel}];
                    [weakSelf.customEvent handleAssets:assets];
                }
            }else{
                [weakSelf.customEvent handleLoadingFailure:error];
            }
        }];
        
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"MyOffer"]}]);
    }
}

@end
