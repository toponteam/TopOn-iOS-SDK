//
//  ATFacebookAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookNativeAdapter.h"
#import "ATFacebookCustomEvent.h"
#import "ATFacebookNativeADRenderer.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATAdAdapter.h"
const CGFloat kATFBAdOptionsViewWidth = 43.0f;
const CGFloat kATFBAdOptionsViewHeight = 18.0f;
@interface ATFacebookNativeAdapter()
@property(nonatomic, readonly) id<ATFBNativeBannerAd> nativeBannerAd;
@property(nonatomic, readonly) id<ATFBNativeAd> nativeAd;
@property(nonatomic, readonly) ATFacebookCustomEvent *customEvent;
@end
@implementation ATFacebookNativeAdapter
+(Class) rendererClass {
    return [ATFacebookNativeADRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFacebook]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFacebook];
                [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameFacebook];
                [NSClassFromString(@"FBAdSettings") setAdvertiserTrackingEnabled:YES];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"FBNativeAd") != nil && NSClassFromString(@"FBNativeBannerAd") != nil) {
        _customEvent = [ATFacebookCustomEvent new];
        _customEvent.unitID = serverInfo[@"unit_id"];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.requestNumber = 1;
        _customEvent.requestExtra = localInfo;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([serverInfo[@"unit_type"] integerValue] == 0) {
                self->_nativeAd = [[NSClassFromString(@"FBNativeAd") alloc] initWithPlacementID:serverInfo[@"unit_id"]];
                self->_nativeAd.delegate = self->_customEvent;
                [self->_nativeAd loadAd];
            } else {
                self->_nativeBannerAd = [[NSClassFromString(@"FBNativeBannerAd") alloc] initWithPlacementID:serverInfo[@"unit_id"]];
                self->_nativeBannerAd.delegate = self->_customEvent;
                [self->_nativeBannerAd loadAd];
            }
        });
    }
}
@end
