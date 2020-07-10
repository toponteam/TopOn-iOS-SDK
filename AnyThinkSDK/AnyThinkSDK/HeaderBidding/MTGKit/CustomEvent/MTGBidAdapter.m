//
//  MTGBidAdapter.m
//  HeadBidingMediationSample
//
//  Created by CharkZhang on 2019/4/10.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "MTGBidAdapter.h"
#import <UIKit/UIKit.h>
#import "Utilities.h"
NSString * const MTGErrorDomain = @"com.anythink.headerbidding";

@implementation MTGBidAdapter

-(void)dealloc{
    DLog(@"");
}

-(void)getBidNetwork:(HBBidNetworkItem *)networkItem extra:(NSDictionary*)extra adFormat:(HBAdBidFormat)format responseCallback:(void (^)(HBAdBidResponse * _Nonnull))callback{

    id apiKeyObj = [networkItem.extraParams objectForKey:@"apiKey"];
    NSString *apiKey = [NSString stringWithFormat:@"%@",apiKeyObj];
    if (networkItem.appId.length == 0 || apiKey.length == 0 || networkItem.unitId.length == 0) {

        NSString *errorMsg = @"Require Input Params for Mintegral is invalid";
        NSError *error = [HBAdBidError errorWithDomain:MTGErrorDomain code:GDBidErrorInputParamersInvalid userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        HBAdBidResponse *response = [HBAdBidResponse buildResponseWithError:error withNetwork:networkItem];
        callback(response);
        return;
    }
    
    [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[extra jsonString_anythink] type:2 unitId:networkItem.unitId];
    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:networkItem.appId ApiKey:apiKey];
    if (format == HBAdBidFormatBanner) {
        id<HBMTGBiddingBannerRequestParameter> bannerRequestPara= [[NSClassFromString(@"MTGBiddingBannerRequestParameter") alloc]initWithPlacementId:networkItem.placementId unitId:networkItem.unitId basePrice:0 bannerSizeType:[MTGBidAdapter sizeToMTGBannerSizeType:networkItem.extraParams]];
        [NSClassFromString(@"MTGBiddingRequest") getBidWithRequestParameter:bannerRequestPara completionHandler:^(id<HBAdMTGBiddingResponse> _Nonnull bidResponse) {
            HBAdBidResponse *response = [self buildAdBidResponse:bidResponse networkItem:networkItem];
            callback(response);
        }];
    } else {
        [NSClassFromString(@"MTGBiddingRequest") getBidWithUnitId:networkItem.unitId basePrice:0 completionHandler:^(id<HBAdMTGBiddingResponse> _Nonnull bidResponse) {
            HBAdBidResponse *response = [self buildAdBidResponse:bidResponse networkItem:networkItem];
            callback(response);

        }];
    }
}

- (HBAdBidResponse *)buildAdBidResponse:(id<HBAdMTGBiddingResponse>)bidResponse networkItem:(HBBidNetworkItem *)networkItem{
    HBAdBidResponse *response = nil;
    if (!bidResponse.success) {
        NSString *errorMsg = bidResponse.error.debugDescription;
        NSError *error = [HBAdBidError errorWithDomain:MTGErrorDomain code:GDBidErrorNetworkBidFailed userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        response = [HBAdBidResponse buildResponseWithError:error withNetwork:networkItem];
        return response;
    }
    response = [HBAdBidResponse buildResponseWithPrice:bidResponse.price currency:bidResponse.currency payLoad:bidResponse.bidToken  network:networkItem adsRender:nil notifyWin:^{
        [bidResponse notifyWin];
    } notifyLoss:^{
        [bidResponse notifyLoss:(HBAdMTGBidLossedReasonCodeLowPrice)];
    }];
    return response;
}

+(HBMTGBannerSizeType) sizeToMTGBannerSizeType:(NSDictionary *)dic {
    return [@{@"320x50":@(MTGStandardBannerType320x50),
              @"320x90":@(MTGStandardBannerType320x50),
              @"300x250":@(MTGMediumRectangularBanner300x250),
              @"smart":@(MTGSmartBannerType)
            }[dic[@"size"]] integerValue];
}
@end
