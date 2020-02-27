//
//  ATMyOfferRewardedVideoAdapter.m
//  AnyThinkMyOfferRewardedVideoAdapter
//
//  Created by Topon on 2019/10/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATMyOfferRewardedVideoCustomEvent.h"

static NSString *const kMyOfferClassName = @"ATMyOfferOfferManager";
@interface  ATMyOfferRewardedVideoAdapter()
@property(nonatomic, readonly) ATMyOfferRewardedVideoCustomEvent *customEvent;

@end
@implementation ATMyOfferRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"my_oid"]} unitGroup:unitGroup];
}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATMyOfferOfferModel *offerModel = RV_FindMyOfferModel(placementModel.offers, unitGroup.content[@"my_oid"]);
    if (offerModel != nil && [[NSClassFromString(kMyOfferClassName) sharedManager] resourceReadyForOfferModel:offerModel]) {
        ATMyOfferRewardedVideoCustomEvent *customEvent = [[ATMyOfferRewardedVideoCustomEvent alloc] initWithUnitID:unitGroup.content[@"my_oid"] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
        ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:offerModel.offerID, kRewardedVideoAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:offerModel} unitGroup:unitGroup];
        return ad;
    } else {
        return nil;
    }
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return YES;
}

+(ATMyOfferOfferModel*) resourceReadyMyOfferForPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info {
    ATMyOfferOfferModel *offerModel = RV_FindMyOfferModel(placementModel.offers, unitGroupModel.content[@"my_oid"]);
    return [[NSClassFromString(kMyOfferClassName) sharedManager] resourceReadyForOfferModel:offerModel] ? offerModel : nil;
}

+(BOOL) adReadyWithCustomObject:(ATMyOfferOfferModel*)customObject info:(NSDictionary*)info {
    return [[NSClassFromString(kMyOfferClassName) sharedManager]offerReadyForOfferModel:customObject];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATMyOfferRewardedVideoCustomEvent *customEvent = (ATMyOfferRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    customEvent.rewardedVideo = rewardedVideo;
    [[NSClassFromString(kMyOfferClassName) sharedManager] showRewardedVideoWithOfferModel:rewardedVideo.customObject setting:rewardedVideo.placementModel.myOfferSetting viewController:viewController delegate:customEvent];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if(self != nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMyOffer]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMyOffer];
                if (NSClassFromString(kMyOfferClassName) != nil) {
                    [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameMyOffer];
                }
            }
        });
    }
    return self;
}

ATMyOfferOfferModel* RV_FindMyOfferModel(NSArray<ATMyOfferOfferModel*>* offers, NSString *offerID) {
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
    if(NSClassFromString(kMyOfferClassName)!=nil){
        ATPlacementModel *placementModel = (ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey];
        ATMyOfferOfferModel *offerModel = RV_FindMyOfferModel(placementModel.offers, info[@"my_oid"]);
        
        _customEvent = [[ATMyOfferRewardedVideoCustomEvent alloc] initWithUnitID:offerModel.offerID customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        __weak typeof(self) weakSelf = self;
        [[NSClassFromString(kMyOfferClassName) sharedManager] loadOfferWithOfferModel:offerModel setting:placementModel.myOfferSetting extra:nil completion:^(NSError *error) {
            if (error == nil) {
                if (offerModel != nil && offerModel.offerID != nil && weakSelf.customEvent != nil) {
                    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithDictionary:@{kRewardedVideoAssetsUnitIDKey:offerModel.offerID, kRewardedVideoAssetsCustomEventKey:weakSelf.customEvent, kAdAssetsCustomObjectKey:offerModel}];
                    [weakSelf.customEvent handleAssets:assets];
                }
            }else{
                [weakSelf.customEvent handleLoadingFailure:error];
            }
        }];
    }else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"MyOffer"]}]);
    }
}

@end
