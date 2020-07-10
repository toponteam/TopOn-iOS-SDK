//
//  FBBidAdapter.m
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/10.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "FBBidAdapter.h"

NSString * const FBErrorDomain = @"com.facebook";

@implementation FBBidAdapter


-(void)dealloc{
    DLog(@"");
}

-(void)getBidNetwork:(HBBidNetworkItem *)networkItem extra:(NSDictionary*)extra adFormat:(HBAdBidFormat)format responseCallback:(void (^)(HBAdBidResponse * _Nonnull))callback{

    __block HBAdFBAdBidFormat currentAdFormat;
    NSError *error = nil;
    if (format == HBAdBidFormatBanner) {
        currentAdFormat = [FBBidAdapter sizeToFBBannerSizeType:networkItem.extraParams];
    } else {
        [self convertWithHBAdBidFormat:format result:^(HBAdFBAdBidFormat fbFormat, NSError *error) {
            currentAdFormat = fbFormat;
        }];
    }
    if (error) {
        HBAdBidResponse *response = [HBAdBidResponse buildResponseWithError:error withNetwork:networkItem];
        callback(response);
        return;
    }

    if (networkItem.testMode) {

        [NSClassFromString(@"FBAdBidRequest") getAudienceNetworkTestBidForAppID:networkItem.appId
                                              placementID:networkItem.unitId
                                               platformID:networkItem.platformId
                                                 adFormat:currentAdFormat
                                             maxTimeoutMS:networkItem.maxTimeoutMS
                                         responseCallback:^(id<HBAdFBAdBidResponse> _Nonnull bidResponse) {
        
        HBAdBidResponse *response = [self buildAdBidResponse:bidResponse networkItem:networkItem];
        callback(response);
    }];
    }else{
        [NSClassFromString(@"FBAdBidRequest") getAudienceNetworkBidForAppID:networkItem.appId
                                          placementID:networkItem.unitId
                                           platformID:networkItem.platformId
                                             adFormat:currentAdFormat
                                     responseCallback:^(id<HBAdFBAdBidResponse> _Nonnull bidResponse) {

            HBAdBidResponse *response = [self buildAdBidResponse:bidResponse networkItem:networkItem];
            callback(response);
        }];
    }
}

- (HBAdBidResponse *)buildAdBidResponse:(id<HBAdFBAdBidResponse>)bidResponse networkItem:(HBBidNetworkItem *)networkItem{
    HBAdBidResponse *response = nil;
    if (!bidResponse.isSuccess) {
        NSString *errorMsg = [bidResponse getErrorMessage];
        NSError *error = [HBAdBidError errorWithDomain:FBErrorDomain code:GDBidErrorNetworkBidFailed userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        response = [HBAdBidResponse buildResponseWithError:error withNetwork:networkItem];
        return response;
    }
    response = [HBAdBidResponse buildResponseWithPrice:bidResponse.getPrice currency:bidResponse.getCurrency payLoad:bidResponse.getPayload network:networkItem adsRender:nil notifyWin:^{
        [bidResponse notifyWin];
    } notifyLoss:^{
        [bidResponse notifyLoss];
    }];
    return response;
}

- (void)convertWithHBAdBidFormat:(HBAdBidFormat)format result:(void(^)(HBAdFBAdBidFormat fbFormat,NSError *error))callback{
    
    HBAdFBAdBidFormat fbFormat;
    NSError *error = nil;
    switch (format) {
        case HBAdBidFormatNative:
            fbFormat = HBAdFBAdBidFormatNative;
            break;
        case HBAdBidFormatInterstitial:
            fbFormat = HBAdFBAdBidFormatInterstitial;
            break;
        case HBAdBidFormatRewardedVideo:
            fbFormat = HBAdFBAdBidFormatRewardedVideo;
            break;
        default:
        {
            NSString *errorMsg = @"Current network still not support this adFormat";
            error = [HBAdBidError errorWithDomain:FBErrorDomain code:GDBidErrorNetworkNotSupportCurrentAdFormat userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        }
            break;
    }

    callback(fbFormat,error);
}

+(HBAdFBAdBidFormat) sizeToFBBannerSizeType:(NSDictionary *)dic {
    return [@{@"320x50":@(HBAdFBAdBidFormatBanner_HEIGHT_50),
              @"320x90":@(HBAdFBAdBidFormatBanner_HEIGHT_90),
              @"320x250":@(HBAdFBAdBidFormatBanner_HEIGHT_250),
            }[dic[@"size"]] integerValue];
}
@end

