//
//  ATMopubNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubNativeAdapter.h"
#import "ATMopubRenderer.h"
#import "ATMopubCustomEvent.h"
#import "ATImageLoader.h"
#import "ATAPI+Internal.h"
#import "ATAPI.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATMopubBaseManager.h"

NSString *const kATAdTitleKey = @"title";
NSString *const kATAdTextKey = @"text";
NSString *const kATAdIconImageKey = @"iconimage";
NSString *const kATAdMainImageKey = @"mainimage";
NSString *const kATAdCTATextKey = @"ctatext";
NSString *const kATAdStarRatingKey = @"starrating";

static NSString *const kUnitIDKey = @"unitid";
@interface ATMopubNativeAdapter()
@property(nonatomic, readonly) ATMopubCustomEvent *customEvent;
@end
@implementation ATMopubNativeAdapter
+(Class) rendererClass {
    return [ATMopubRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMopubBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    void(^Load)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_group_t ads_loading_queue = dispatch_group_create();
            NSMutableArray<NSDictionary*>* offers = [NSMutableArray<NSDictionary*> array];
            
            dispatch_group_enter(ads_loading_queue);
            ATMopubRenderSettings *settings = [ATMopubRenderSettings new];
            id<ATMPNativeAdRequest> request = [NSClassFromString(@"MPNativeAdRequest") requestWithAdUnitIdentifier:serverInfo[@"unitid"] rendererConfigurations:@[[NSClassFromString(@"ATMopubRenderer") rendererConfigurationWithRendererSettings:settings]]];
            [request startWithCompletionHandler:^(id<ATMPNativeAdRequest> request, id<ATMPNativeAd> response, NSError *error) {
                if (error == nil) {
                    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:serverInfo[@"unitid"], kNativeADAssetsUnitIDKey, self.customEvent, kAdAssetsCustomEventKey, nil];
                    assets[kAdAssetsCustomObjectKey] = response;
                    if ([response.properties containsObjectForKey:kATAdTitleKey]) {
                        assets[kNativeADAssetsMainTitleKey] = response.properties[kATAdTitleKey];
                    }
                    if ([response.properties containsObjectForKey:kATAdTextKey]) {
                        assets[kNativeADAssetsMainTextKey] = response.properties[kATAdTextKey];
                    }
                    if ([response.properties containsObjectForKey:kATAdCTATextKey]) {
                        assets[kNativeADAssetsCTATextKey] = response.properties[kATAdCTATextKey];
                    }
                    if ([response.properties containsObjectForKey:kATAdStarRatingKey]) {
                        assets[kNativeADAssetsRatingKey] = response.properties[kATAdStarRatingKey];
                    }
                    
                    //Load images
                    dispatch_group_t image_loading_group = dispatch_group_create();
                    if ([response.properties containsObjectForKey:kATAdIconImageKey]) {
                        if ([response.properties[kATAdIconImageKey] length] > 0) {
                            assets[kNativeADAssetsIconURLKey] = response.properties[kATAdIconImageKey];
                            dispatch_group_enter(image_loading_group);
                            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:response.properties[kATAdIconImageKey]] completion:^(UIImage *image, NSError *error) {
                                if (image != nil) assets[kNativeADAssetsIconImageKey] = image;
                                dispatch_group_leave(image_loading_group);
                            }];
                        }
                    }
                    if ([response.properties containsObjectForKey:kATAdMainImageKey]) {
                        if ([response.properties[kATAdMainImageKey] length] > 0) {
                            assets[kNativeADAssetsImageURLKey] = response.properties[kATAdMainImageKey];
                            dispatch_group_enter(image_loading_group);
                            [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:response.properties[kATAdMainImageKey]] completion:^(UIImage *image, NSError *error) {
                                if (image != nil) assets[kNativeADAssetsMainImageKey] = image;
                                dispatch_group_leave(image_loading_group);
                            }];
                        }
                    }
                    dispatch_group_notify(image_loading_group, dispatch_get_main_queue(), ^{
                        [offers addObject:assets];
                        dispatch_group_leave(ads_loading_queue);
                    });
                } else {
                    [ATLogger logError:[NSString stringWithFormat:@"Mopub has failed to load offer, error:%@", error] type:ATLogTypeExternal];
                }
            }];
            dispatch_group_notify(ads_loading_queue, dispatch_get_main_queue(), ^{
                completion(offers, [offers count] > 0 ? nil : [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"Third-party network offer loading has failed.", NSLocalizedFailureReasonErrorKey:@"Third-party SDK did not return any offer."}]);
            });
        });
    };
    
    if (NSClassFromString(@"MoPub") != nil && NSClassFromString(@"MPMoPubConfiguration") != nil) {
        id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];
        if(![ATAPI getMPisInit]){
            [mopub initializeSdkWithConfiguration:[[NSClassFromString(@"MPMoPubConfiguration") alloc] initWithAdUnitIdForAppInitialization:serverInfo[kUnitIDKey]] completion:^{
                [ATAPI setMPisInit:YES];
                Load();
            }];
        }else{
            Load();
        }
    }else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mopub"]}]);
    }
}


@end
