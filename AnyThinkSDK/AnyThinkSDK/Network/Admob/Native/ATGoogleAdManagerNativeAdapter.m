//
//  ATGoogleAdManagerNativeAdapter.m
//  AnyThinkGoogleAdManagerNativeAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerNativeAdapter.h"
#import "ATGoogleAdManagerNativeCustomEvent.h"
#import "ATGoogleAdManagerNativeAdRenderer.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATAdmobBaseManager.h"

@interface ATGoogleAdManagerNativeAdapter()
@property(nonatomic, readonly) id<ATDFPAdLoader> loader;
@property(nonatomic, readonly) ATGoogleAdManagerNativeCustomEvent *customEvent;
@end
@implementation ATGoogleAdManagerNativeAdapter
+(Class) rendererClass {
    return [ATGoogleAdManagerNativeAdRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAdmobBaseManager initGoogleAdManagerWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"GADAdLoader") != nil) {
        _customEvent = [ATGoogleAdManagerNativeCustomEvent new];
        _customEvent.unitID = serverInfo[@"unit_id"];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.requestNumber = [serverInfo[@"request_num"] longValue];
        NSDictionary *extraInfo = localInfo;
        _customEvent.requestExtra = extraInfo;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray<id<ATGADAdLoaderOptions>>* options = [NSMutableArray<id<ATGADAdLoaderOptions>> array];
            
            id<ATGADNativeAdMediaAdLoaderOptions> mediaOption = [NSClassFromString(@"GADNativeAdMediaAdLoaderOptions") new];
            mediaOption.mediaAspectRatio = [serverInfo[@"media_ratio"] integerValue];
            if (mediaOption != nil) { [options addObject:mediaOption]; }
            
            self->_loader = [[NSClassFromString(@"GADAdLoader") alloc] initWithAdUnitID:serverInfo[@"unit_id"] rootViewController:nil adTypes:@[ kATGADAdLoaderAdTypeUnifiedNative ] options:options];
            self->_loader.delegate = self->_customEvent;
            id<ATDFPRequest> request = [NSClassFromString(@"DFPRequest") request];
            [self->_loader loadRequest:request];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GoogleAdManager"]}]);
    }
}
@end
