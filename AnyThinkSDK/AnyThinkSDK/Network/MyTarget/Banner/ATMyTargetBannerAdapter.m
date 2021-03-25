//
//  ATMyTargetBannerAdapter.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyTargetBannerAdapter.h"
#import "ATMyTargetBannerCustomEvent.h"
#import "ATBanner.h"
#import "ATMyTargetBaseManager.h"
#import "ATMyTargetAdViewApis.h"

@interface ATMyTargetBannerAdapter ()

@property(nonatomic, strong) id<ATMTRGAdView> adView;

@end

@implementation ATMyTargetBannerAdapter

// MARK:- basic methods
+ (NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
    NSArray *sizeValues = [unitGroupModel.content[@"size"] componentsSeparatedByString:@"x"];
    double width = [sizeValues.firstObject doubleValue];
    double height = [sizeValues.lastObject doubleValue];
    NSString *buyerID = [NSClassFromString(@"MTRGManager") getBidderToken];
    return @{@"display_manager_ver":[NSClassFromString(@"MTRGVersion") currentVersion],
             @"unit_id":unitGroupModel.content[@"slot_id"] ? unitGroupModel.content[@"slot_id"] : @"",
             @"app_id":unitGroupModel.content[@"app_id"] ? unitGroupModel.content[@"app_id"] : @"",
             @"buyeruid":buyerID ? buyerID : @"",
             @"ad_width":@(width),
             @"ad_height":@(height),
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"ad_format":@(ATAdFormatBanner).stringValue
    };
}

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMyTargetBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary* )localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError * ))completion {
    
    Class adClass = NSClassFromString(@"MTRGAdView");
    if (adClass == nil) {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"MyTarget"]}]);
        return;
    }
    NSArray *sizeValues = [serverInfo[@"size"] componentsSeparatedByString:@"x"];
    double width = [sizeValues.firstObject doubleValue];
    double height = [sizeValues.lastObject doubleValue];
    CGSize adSize = CGSizeMake(width, height);
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
    if (bidInfo.nURL) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; });
    }
    
    _customEvent = [[ATMyTargetBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.price = bidInfo ? bidInfo.price : unitGroupModel.price;
    _customEvent.bidID = bidInfo.bidId;

    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger slotID = [serverInfo[@"slot_id"] integerValue];
        self.adView = [adClass adViewWithSlotId:slotID];
        self.adView.adSize = [self sizeToMTGBannerSizeType:adSize];
        self.adView.delegate = self->_customEvent;
        self.adView.viewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:placementModel.placementID requestID:requestID];
        
        if (bidInfo.bidId) {
            [self.adView loadFromBid:bidInfo.bidId];
            [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            return;
        }
        [self.adView load];
    });
}

// private methods
- (id<ATMTRGAdSize>)sizeToMTGBannerSizeType:(CGSize)size {
    
    Class sizeClass = NSClassFromString(@"MTRGAdSize");
    
    if (size.width == 320 && size.height == 50) {
        return [sizeClass adSize320x50];
    } else if (size.width == 728 && size.height == 90) { // only for ipad
        return [sizeClass adSize728x90];
    } else if (size.width == 300 && size.height == 250) {
        return [sizeClass adSize300x250];
    }
    return [sizeClass adSizeForCurrentOrientation];
}

+ (void)showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    
    // set center ?
    CGSize adSize = banner.unitGroup.adSize;
    UIView *bannerView = banner.bannerView;
    UIView *bannerSuperView = banner.bannerView.superview;
    CGFloat x = CGRectGetWidth(bannerSuperView.frame)  - adSize.width;
    CGFloat y = CGRectGetHeight(bannerSuperView.frame) - adSize.height;
    bannerView.frame = CGRectMake(x/2, y/2, adSize.width, adSize.height);
}

+ (NSString*)adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel{
    return content[@"slot_id"];
}
@end
