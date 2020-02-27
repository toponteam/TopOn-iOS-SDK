//
//  ATNativeAd.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 02/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeAd.h"
#import "ATAPI+Internal.h"

@implementation ATNativeAd
-(instancetype) initWithAssets:(NSDictionary*)assets {
    self = [super init];
    if (self != nil) {
        _advertiser = assets[kNativeADAssetsAdvertiserKey];
        _title = assets[kNativeADAssetsMainTitleKey];
        _mainText = assets[kNativeADAssetsMainTextKey];
        _icon = assets[kNativeADAssetsIconImageKey];
        _mainImage = assets[kNativeADAssetsMainImageKey];
        _ctaText = assets[kNativeADAssetsCTATextKey];
        _rating = assets[kNativeADAssetsRatingKey];
        _sponsorImage = assets[kNativeADAssetsSponsoredImageKey];
        _videoContents = [assets[kNativeADAssetsContainsVideoFlag] boolValue];
    }
    return self;
}
@end
