//
//  ATFBBiddingManager.m
//  AnyThinkSDK
//
//  Created by Jason on 2021/1/5.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATFBBiddingManager.h"
#import "ATUnitGroupModel.h"
#import "ATBidInfo.h"
#import "ATAppSettingManager.h"
#import "ATFBBKWaterfallEntryImpl.h"
#import "ATFBBKWaterfallImpl.h"
#import "ATAgentEvent.h"
#import "ATFaceBookBaseManager.h"
#import "Utilities.h"

@implementation ATFacebookBaseRequest

@end

@interface ATFBBiddingManager()<FBBKAuctionDelegate>

@property(nonatomic, strong) NSMutableDictionary *auctions;
@property(nonatomic, strong) NSMutableDictionary<NSString *, ATFacebookBaseRequest *> *requests;
@property(nonatomic) BOOL initialized;

@end

@implementation ATFBBiddingManager

+ (instancetype)sharedManager {
    static ATFBBiddingManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATFBBiddingManager alloc] init];
    });
    return sharedManager;
}

- (void)initializeFacebookBiddingKit:(ATFacebookBaseRequest *)request {
    if (self.requests == nil) {
        self.requests = [NSMutableDictionary dictionary];
    }
    Class configClass = NSClassFromString(@"FBBKConfiguration");
    Class bkClass = NSClassFromString(@"FBBKBiddingKit");
    if (configClass && bkClass) {
        id<ATFBBKConfiguration> config = [configClass new];
        config.auctionTimeout = request.timeOut;
        [(id<ATFBBKBiddingKit>)bkClass initializeWithConfiguration:config];
        
        self.auctions = [NSMutableDictionary dictionary];
    }
}

- (void)notifyDisplayWinnerWithID:(NSString *)ID placementID:(NSString *)pID {
    id<FBBKAuction> auction = self.auctions[pID];
    if (auction) {
        NSString *waterfallKey = [self getBidWaterfallWithPlacementID:pID];
        id<FBBKWaterfall> waterfall = self.auctions[waterfallKey];
        id<FBBKWaterfallEntry> entry = nil;
        for (id<FBBKWaterfallEntry> item in waterfall.entries) {
            if ([item.entryName isEqualToString:ID]) {
                entry = item;
                break;
            }
        }
        if (entry) {
            [auction notifyDisplayWinner:entry];
        }else { // facebook ad source
            id<FBBKWaterfallEntry> fbEntry = self.auctions[ID];
            if (fbEntry) {
                [auction notifyDisplayWinner:fbEntry];
                [self.auctions removeObjectForKey:ID];
            }
        }
    }
}

- (void)bidRequest:(ATFacebookBaseRequest *)request {
    
    if (self.initialized == NO) {
        [self initializeFacebookBiddingKit:request];
        self.initialized = YES;
    }
    Class paramClass = NSClassFromString(@"FBBKFacebookBidderParameters");
    Class tokenClass = NSClassFromString(@"FBAdSettings");
    if (paramClass == nil || tokenClass == nil) {
        if (request.completion) {
            request.completion( nil, [NSError errorWithDomain:@"com.anythink.FacebookHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"Facebook bidding kit is not imported"}]);
        }
        return;
    }
    
    Class settingClass = NSClassFromString(@"FBAdSettings");
    if (settingClass && [settingClass respondsToSelector:@selector(setAdvertiserTrackingEnabled:)]) {
        
        NSString *idfa = [[Utilities advertisingIdentifier] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        idfa = [idfa stringByReplacingOccurrencesOfString:@"0" withString:@""];
        [settingClass setAdvertiserTrackingEnabled:[Utilities isEmpty:idfa] == NO];
    }

    
    NSString *bidToken = [(id<ATFBAdSettings>)tokenClass bidderToken];
    id<ATFBBKFacebookBidderParameters> param = [[paramClass alloc] initWithAppId:request.appID placementId:request.facebookPlacementID adBidFormat:request.format bidToken:bidToken];
    param.standalone = NO;
    
    Class bidderClass = NSClassFromString(@"FBBKFacebookBidder");
    id<ATFBBKFacebookBidder> bidder = [[bidderClass alloc] initWithParameters:param];
    
    Class auctionImplClass = NSClassFromString(@"FBBKAuctionImpl");
    id<FBBKAuction> auction = [[auctionImplClass alloc] initWithBidders:@[bidder]];
    auction.delegate = self;
    [self.requests setValue:request forKey:@(auction.auctionId).stringValue];

    NSMutableArray<ATFBBKWaterfallEntryImpl *> *waterfallEntryImpl = [NSMutableArray arrayWithCapacity:request.unitGroups.count];
    for (ATUnitGroupModel *ug in request.unitGroups) {
//        NSString *entryName = [NSString stringWithFormat:@"%@_%@",ug.networkName,ug.unitID];
        NSString *price = ug.bidPrice ? ug.bidPrice : ug.price;
        ATFBBKWaterfallEntryImpl *impl = [[ATFBBKWaterfallEntryImpl alloc]initWithBid:bidder CPMCents:[price doubleValue]*100 entryName:ug.unitID];
        [waterfallEntryImpl addObject:impl];
    }
    
    ATFBBKWaterfallImpl *waterfallImpl = [[ATFBBKWaterfallImpl alloc]initWithEntries:waterfallEntryImpl];
    
    NSURL *url = [NSURL URLWithString:kATSDKInhouseBiddingUrl];
    if (url) {
        [auction startRemoteUsingWaterfall:waterfallImpl url:url];
    }
}

// MARK:- FBBKAuctionDelegate
- (void)fbbkAuction:(id<FBBKAuction>)auction didFailWithError:(NSError *)error {
    
    ATFacebookBaseRequest *request = self.requests[@(auction.auctionId).stringValue];
    if (request.completion) {
        request.completion(nil, error);
    }
}

- (void)fbbkAuction:(id<FBBKAuction>)auction didCompleteWithWaterfall:(id<FBBKWaterfall>)waterfall {
    
    NSString *auctionID = @(auction.auctionId).stringValue;
    ATFacebookBaseRequest *request = self.requests[auctionID];

    if (request.completion == NULL) {
        request.completion(nil, [NSError errorWithDomain:@"com.anythink.FBHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"The parameter 'completion' should not be null"}]);
        return;
    }
    
    @try {
        id<FBBKWaterfallEntry> winner = nil;
        for (id<FBBKWaterfallEntry> kwinner in waterfall.entries) {
            
            if ([kwinner.bid isKindOfClass:NSClassFromString(@"FBBKBid")] &&
                [kwinner.bid.placementId isEqualToString:request.facebookPlacementID]) {
                winner = kwinner;
                break;
            }
        }
        if (winner == nil) {
            request.completion(nil, [NSError errorWithDomain:@"com.anythink.FBHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"FB has failed to get bid info"}]);
            return;
        }
        
        NSString *unitID = request.unitGroup.unitID;
        ATBidInfo *info = [ATBidInfo bidInfoWithPlacementID:request.placementID unitGroupUnitID:unitID token:winner.bid.payload price:@(winner.CPMCents/100).stringValue expirationInterval:request.unitGroup.bidTokenTime customObject:nil];
        request.completion(info, nil);
        [self.auctions setValue:auction forKey:request.placementID];
        [self.auctions setValue:waterfall forKey:[self getBidWaterfallWithPlacementID:request.placementID]];
        [self.auctions setValue:winner forKey:request.unitGroup.unitID];
//        [self.auctions setValue:auction forKey:request.facebookPlacementID];
//        [self.auctions setValue:winner forKey:[self getWinnerWithID:request.facebookPlacementID]];
        [self.requests removeObjectForKey:auctionID];
    } @catch (NSException *exception) {
        NSString *reason = [NSString stringWithFormat:@"Some errors occurred: %@",exception.reason];
        request.completion(nil, [NSError errorWithDomain:@"com.anythink.FBHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:reason}]);
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyCrashInfoKey placementID:request.placementID unitGroupModel:request.unitGroup extraInfo:@{kAgentEventExtraInfoCrashReason: exception.reason, kAgentEventExtraInfoCallStackSymbols: [NSThread callStackSymbols].firstObject}];

    } @finally {
        
    }
}

- (NSString *)getBidWaterfallWithPlacementID:(NSString *)ID {
    return [NSString stringWithFormat:@"waterfall_%@",ID];
}
@end
