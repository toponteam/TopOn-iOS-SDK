//
//  ATNendBannerAdapter.m
//  AnyThinkNendBannerAdapter
//
//  Created by Martin Lau on 2019/4/19.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendBannerAdapter.h"
#import "ATNendBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Banner.h"
#import "ATAdManager+Internal.h"
#import <objc/runtime.h>
@interface ATNendBannerAdapter()
@property(nonatomic, readonly) id<ATNADView> bannerView;
@property(nonatomic, readonly) ATNendBannerCustomEvent *customEvent;
@end
@implementation ATNendBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameNend]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameNend];
                [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameNend];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"NADView") != nil) {
        _customEvent = [[ATNendBannerCustomEvent alloc] initWithUnitID:info[@"spot_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        NSDictionary *extra = info[kAdapterCustomInfoExtraKey];
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *para = extra[kATBannerLoadingExtraParameters];
            BOOL adjustAdSize = [extra[kATAdLoadingExtraBannerSizeAdjustKey] boolValue];
            self->_customEvent.adjustAdSize = adjustAdSize;
            self->_customEvent.loadingParameters = para;
            self->_bannerView = [[NSClassFromString(@"NADView") alloc] initWithFrame:CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height) isAdjustAdSize:adjustAdSize];
            [self->_bannerView setNendID:info[@"api_key"] spotID:info[@"spot_id"]];
            self->_bannerView.delegate = self->_customEvent;
            [para isKindOfClass:[NSDictionary class]] ? [self->_bannerView load:para] : [self->_bannerView load];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Nend"]}]);
    }
}
@end
