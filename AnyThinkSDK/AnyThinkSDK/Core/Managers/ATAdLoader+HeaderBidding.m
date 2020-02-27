//
//  ATAdLoader+HeaderBidding.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/6/13.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATAdLoader+HeaderBidding.h"
#import "ATLogger.h"
#import <objc/runtime.h>
NSString *const kATHeaderBiddingExtraInfoTotalErrorKey = @"total_error";
NSString *const kATHeaderBiddingExtraInfoDetailErrorKey = @"detail_error";
NSString *const kATHeaderBiddingExtraInfoUnitGroupsUsingLatestBidInfoKey = @"unit_group_using_latest_bid_info";

NSString *const kATHeaderBiddingAdSourceInfoAppIDKey_internal = @"app_id";
NSString *const kATHeaderBiddingAdSourceInfoUnitIDKey_internal = @"unit_id";
@implementation ATAdLoader (HeaderBidding)
-(void) runHeaderBiddingWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID completion:(void(^)(NSDictionary *context))completion{
    NSMutableArray<ATUnitGroupModel*>* hbActiveUnitGroups = [ATAdLoader activeUnitGroupsInPlacementModel:placementModel unitGroups:placementModel.headerBiddingUnitGroups inactiveUnitGroupInfos:nil requestID:requestID];
    NSArray<ATUnitGroupModel*>* offerCachedHBActiveUnitGroups = [ATAdLoader offerCachedActiveUnitGroupsInPlacementModel:placementModel hbUnitGroups:hbActiveUnitGroups];
    
    [hbActiveUnitGroups removeObjectsInArray:offerCachedHBActiveUnitGroups];
    
    NSMutableArray<ATUnitGroupModel*>* activeUnitGroups = [ATAdLoader activeUnitGroupsInPlacementModel:placementModel unitGroups:placementModel.unitGroups inactiveUnitGroupInfos:nil requestID:requestID];
    [activeUnitGroups addObjectsFromArray:offerCachedHBActiveUnitGroups];
    
    [self sendHeaderBiddingRequestWithPlacementModel:placementModel nonHeaderBiddingUnitGroups:activeUnitGroups headerBiddingUnitGroups:hbActiveUnitGroups completion:^(NSArray<ATUnitGroupModel *> *sortedUnitGroups, NSDictionary *extraInfo) {
        if ([sortedUnitGroups count] > 0) {
            [sortedUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj updateBidInfoForRequestID:requestID];
            }];
            [placementModel updateUnitGroups:sortedUnitGroups forRequestID:requestID];
            dispatch_async(dispatch_get_main_queue(), ^{ completion(extraInfo); });
        } else {
            completion(extraInfo);
        }
    }];
}

-(void) sendHeaderBiddingRequestWithPlacementModel:(ATPlacementModel*)placementModel nonHeaderBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)nonHBUnitGroups headerBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)hbUnitGroups completion:(void(^)(NSArray<ATUnitGroupModel*>*, NSDictionary*))completion {
    if (placementModel.headerBiddingFormat != 0) {
        if (NSClassFromString(@"ATHeaderBiddingManager") != nil) {
            [[NSClassFromString(@"ATHeaderBiddingManager") sharedManager] runHeaderBiddingWithForamt:placementModel.headerBiddingFormat unitID:placementModel.placementID adSources:nonHBUnitGroups headerBiddingAdSources:hbUnitGroups timeout:placementModel.headerBiddingRequestTimeout completion:^(NSArray<ATUnitGroupModel*>* sortedUnitGroups, NSDictionary* extraInfo) {
                completion(sortedUnitGroups, extraInfo);
            }];
        } else {
            [ATLogger logError:@"ATHeaderBiddingManager's not being imported" type:ATLogTypeExternal];
            NSError *totalError = [NSError errorWithDomain:@"com.anythink.HeaderBiddingRequest" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Header bidding request failed", NSLocalizedDescriptionKey:@"ATHeaderBiddingManager's not being imported"}];
            completion(nonHBUnitGroups, @{kATHeaderBiddingExtraInfoTotalErrorKey:totalError});
        }
    } else {
        [ATLogger logError:@"This format is not header bidding supported." type:ATLogTypeExternal];
        NSError *totalError = [NSError errorWithDomain:@"com.anythink.HeaderBiddingRequest" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Header bidding request failed", NSLocalizedDescriptionKey:@"This format is not header bidding supported."}];
        completion(nonHBUnitGroups, @{kATHeaderBiddingExtraInfoTotalErrorKey:totalError});
    }
}

+(BOOL) headerBiddingSupported {
    return NSClassFromString(@"ATHeaderBiddingManager") != nil;
}
@end

NSString *const kUnitGroupBidInfoPriceKey = @"price";
NSString *const kUnitGroupBidInfoBidTokenKey = @"bid_token";
NSString *const kUnitGroupBidInfoBidTokenExpireDateKey = @"expire_date";
NSString *const kUnitGroupBidInfoBidTokenUsedFlagKey = @"used_flag";
@implementation ATPlacementModel (HeaderBidding)

-(NSInteger) headerBiddingFormat {
    return [@{@(ATAdFormatNative):@1, @(ATAdFormatInterstitial):@2, @(ATAdFormatRewardedVideo):@3 ,@(ATAdFormatBanner):@4}[@(self.format)] integerValue];
}
@end

@implementation ATUnitGroupModel (HeaderBidding)
-(NSInteger) network {
    return [@{@(1):@1, @(6):@2}[@(self.networkFirmID)] integerValue];
}

NSString* AppIDContentKey(NSInteger network) {
    return @{@(1):@"app_id", @(6):@"appid"}[@(network)];
}

NSString* UnitIDContentKey(NSInteger network) {
    return @{@(1):@"unit_id", @(6):@"unitid"}[@(network)];
}

-(NSDictionary*)adSrouceInfo {
    NSMutableDictionary *adSourceInfo = [NSMutableDictionary dictionary];
    if (self.content[AppIDContentKey(self.networkFirmID)] != nil) { adSourceInfo[kATHeaderBiddingAdSourceInfoAppIDKey_internal] = self.content[AppIDContentKey(self.networkFirmID)]; }
    if (self.content[UnitIDContentKey(self.networkFirmID)] != nil) { adSourceInfo[kATHeaderBiddingAdSourceInfoUnitIDKey_internal] = self.content[UnitIDContentKey(self.networkFirmID)]; }
    if (self.content[@"appkey"] != nil) { adSourceInfo[@"apiKey"] = self.content[@"appkey"]; }//for mtg
    if (self.content[@"size"] != nil) { adSourceInfo[@"size"] = self.content[@"size"]; } //for banenr
    return adSourceInfo;
}
@end
