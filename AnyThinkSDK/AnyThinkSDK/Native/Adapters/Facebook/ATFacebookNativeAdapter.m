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
#import "ATAdLoader+HeaderBidding.h"
const CGFloat kATFBAdOptionsViewWidth = 43.0f;
const CGFloat kATFBAdOptionsViewHeight = 18.0f;
@interface ATFacebookNativeAdapter()
@property(nonatomic, readonly) NSMutableArray<id<ATFBNativeAd>>* nativeAds;
@property(nonatomic, readonly) ATFacebookCustomEvent *customEvent;
@end
@implementation ATFacebookNativeAdapter
+(Class) rendererClass {
    return [ATFacebookNativeADRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFacebook]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFacebook];
                [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameFacebook];
            }
        });
        _nativeAds = [NSMutableArray<id<ATFBNativeAd>> array];
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"FBNativeAd") != nil) {
        _customEvent = [ATFacebookCustomEvent new];
        _customEvent.unitID = info[@"unit_id"];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.requestNumber = [info[@"request_num"] longValue];
        NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
        _customEvent.requestExtra = extraInfo;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSInteger i = 0; i < [info[@"request_num"] integerValue]; i++) {
                id<ATFBNativeAd> nativeAd = [[NSClassFromString(@"FBNativeAd") alloc] initWithPlacementID:info[@"unit_id"]];
                if (nativeAd != nil) {
                    nativeAd.delegate = self->_customEvent;
                    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
                    NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
                    if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
                        [nativeAd loadAdWithBidPayload:[unitGroupModel bidTokenWithRequestID:requestID]];
                        [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
                    } else {
                        [nativeAd loadAd];
                    }
                    [self->_nativeAds addObject:nativeAd];
                }
            }
        });
    }
}
@end
