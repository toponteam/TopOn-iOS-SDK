//
//  ATTTBannerAdapter.m
//  AnyThinkTTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTBannerAdapter.h"
#import "ATTTBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Banner.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATPangleBaseManager.h"

@interface ATTTBannerAdapter()
@property(nonatomic, readonly) id<ATBUNativeExpressBannerView> expressBannerView;
@property(nonatomic, readonly) ATTTBannerCustomEvent *customEvent;
@end
@implementation ATTTBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATPangleBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}


-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BUNativeExpressBannerView") != nil) {
        _customEvent = [[ATTTBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL usesFilled = ([localInfo isKindOfClass:[NSDictionary class]] && localInfo[kATAdLoadingExtraBannerSizeUsesFilledKey] != nil) ? [localInfo[kATAdLoadingExtraBannerSizeUsesFilledKey] boolValue] : YES;
            
            id<ATBUSize> size = [NSClassFromString(@"BUSize") sizeBy:[serverInfo[@"media_size"] integerValue]];
            CGSize adSize = [self sizeToSizeType:serverInfo[@"size"]];
            CGFloat height = adSize.height;
            
            if (usesFilled) {
                if ([localInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
                    adSize = [localInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue];
                    height = adSize.width * size.height / size.width;
                }
            }
            
            if ([serverInfo[@"layout_type"] integerValue] == 1) {
                self->_expressBannerView = [[NSClassFromString(@"BUNativeExpressBannerView") alloc]initWithSlotID:serverInfo[@"slot_id"] rootViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]] adSize:CGSizeMake(adSize.width, height) IsSupportDeepLink:YES];
                self->_expressBannerView.frame = CGRectMake(.0f, .0f, adSize.width, height);
                self->_expressBannerView.delegate = self->_customEvent;
                [self->_expressBannerView loadAdData];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"TT"]}]);
    }
}

- (CGSize) sizeToSizeType:(NSString *)sizeStr {
    if ([sizeStr isEqualToString:@"600x90"]) {
        return CGSizeMake(300.0f, 45.0f);
    } else if ([sizeStr isEqualToString:@"600x150"]) {
        return CGSizeMake(300.0f, 75.0f);
    }  else if ([sizeStr isEqualToString:@"600x260"]) {
        return CGSizeMake(300.0f, 130.0f);
    }  else if ([sizeStr isEqualToString:@"600x300"]) {
        return CGSizeMake(300.0f, 150.0f);
    }  else if ([sizeStr isEqualToString:@"600x400"]) {
        return CGSizeMake(300.0f, 200.0f);
    }  else if ([sizeStr isEqualToString:@"600x500"]) {
        return CGSizeMake(300.0f, 250.0f);
    }  else if ([sizeStr isEqualToString:@"640x100"]) {
        return CGSizeMake(320.0f, 50.0f);
    } else if ([sizeStr isEqualToString:@"690x388"]) {
        return CGSizeMake(345.0f, 194.0f);
    } else {
        return CGSizeMake(320.0f, 50.0f);
    }
}


@end
