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
NSString *const kATAdTitleKey = @"title";
NSString *const kATAdTextKey = @"text";
NSString *const kATAdIconImageKey = @"iconimage";
NSString *const kATAdMainImageKey = @"mainimage";
NSString *const kATAdCTATextKey = @"ctatext";
NSString *const kATAdStarRatingKey = @"starrating";

@interface ATMopubNativeAdapter()
@property(nonatomic, readonly) ATMopubCustomEvent *customEvent;
@end
@implementation ATMopubNativeAdapter
+(Class) rendererClass {
    return [ATMopubRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];
            [[ATAPI sharedInstance] setVersion:[mopub version] forNetwork:kNetworkNameMopub];
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    void(^Load)(void) = ^{
        dispatch_group_t ads_loading_queue = dispatch_group_create();
        NSMutableArray<NSDictionary*>* offers = [NSMutableArray<NSDictionary*> array];
        
        for (NSInteger i = 0; i < [info[@"request_num"] integerValue]; i++) {
            dispatch_group_enter(ads_loading_queue);
            ATMopubRenderSettings *settings = [ATMopubRenderSettings new];
            id<ATMPNativeAdRequest> request = [NSClassFromString(@"MPNativeAdRequest") requestWithAdUnitIdentifier:info[@"unitid"] rendererConfigurations:@[[NSClassFromString(@"ATMopubRenderer") rendererConfigurationWithRendererSettings:settings]]];
            [request startWithCompletionHandler:^(id<ATMPNativeAdRequest> request, id<ATMPNativeAd> response, NSError *error) {
                if (error == nil) {
                    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:info[@"unitid"], kNativeADAssetsUnitIDKey, nil];
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
                        assets[kNativeADAssetsIconURLKey] = response.properties[kATAdIconImageKey];
                        dispatch_group_enter(image_loading_group);
                        [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:response.properties[kATAdIconImageKey]] completion:^(UIImage *image, NSError *error) {
                            if (image != nil) assets[kNativeADAssetsIconImageKey] = image;
                            dispatch_group_leave(image_loading_group);
                        }];
                    }
                    if ([response.properties containsObjectForKey:kATAdMainImageKey]) {
                        assets[kNativeADAssetsImageURLKey] = response.properties[kATAdMainImageKey];
                        dispatch_group_enter(image_loading_group);
                        [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:response.properties[kATAdMainImageKey]] completion:^(UIImage *image, NSError *error) {
                            if (image != nil) assets[kNativeADAssetsMainImageKey] = image;
                            dispatch_group_leave(image_loading_group);
                        }];
                    }
                    dispatch_group_notify(image_loading_group, dispatch_get_main_queue(), ^{
                        [offers addObject:assets];
                        dispatch_group_leave(ads_loading_queue);
                    });
                } else {
                    [ATLogger logError:[NSString stringWithFormat:@"Mopub has failed to load offer, error:%@", error] type:ATLogTypeExternal];
                }
            }];
        }
        dispatch_group_notify(ads_loading_queue, dispatch_get_main_queue(), ^{
            completion(offers, [offers count] > 0 ? nil : [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"Third-party network offer loading has failed.", NSLocalizedFailureReasonErrorKey:@"Third-party SDK did not return any offer."}]);
        });
    };
    
    id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];
    if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMopub]) {
        [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMopub];
        if ([[ATAPI sharedInstance] inDataProtectionArea]) {
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMopub]) {
                if ([[ATAPI sharedInstance].networkConsentInfo[kNetworkNameMopub] boolValue]) {
                    [mopub grantConsent];
                } else {
                    [mopub revokeConsent];
                }
            } else {
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) {
                    if (limit) {
                        [mopub revokeConsent];
                    } else {
                        [mopub grantConsent];
                    }
                }
            }
        }
        [mopub initializeSdkWithConfiguration:[[NSClassFromString(@"MPMoPubConfiguration") alloc] initWithAdUnitIdForAppInitialization:info[@"unitid"]] completion:^{
            Load();
        }];
    } else {
        Load();
    }
    
}


@end
