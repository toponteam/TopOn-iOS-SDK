//
//  ATFBBiddingManager.h
//  AnyThinkSDK
//
//  Created by Jason on 2021/1/5.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ATFBBKFacebookAdBidFormat) {
    ATFBBKFacebookAdBidFormatBanner_320_50,     // Bid For Banner 320x50
    ATFBBKFacebookAdBidFormatBanner_HEIGHT_50,  // Bid For Banner with flexible width and height 50
    ATFBBKFacebookAdBidFormatBanner_HEIGHT_90,  // Bid For Banner with flexible width and height 90
    ATFBBKFacebookAdBidFormatBanner_HEIGHT_250, // Bid For Banner with flexible width and height 250
    ATFBBKFacebookAdBidFormatInterstitial,      // Bid For Interstitial
    ATFBBKFacebookAdBidFormatInstreamVideo,     // Bid For Instream Video
    ATFBBKFacebookAdBidFormatRewardedVideo,     // Bid For Rewarded Video
    ATFBBKFacebookAdBidFormatNative,            // Bid For Native
    ATFBBKFacebookAdBidFormatNativeBanner,      // Bid For Native Banner
};

@class ATUnitGroupModel,ATBidInfo;

@interface ATFacebookBaseRequest : NSObject

@property(nonatomic, copy) NSString *appID;
@property(nonatomic, copy) NSString *placementID;
@property(nonatomic, copy) NSString *facebookPlacementID;
@property(nonatomic, copy) NSArray<ATUnitGroupModel *> *unitGroups; // waterfall A
@property(nonatomic, copy) void(^completion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);
@property(nonatomic) ATFBBKFacebookAdBidFormat format;
@property(nonatomic, strong) ATUnitGroupModel *unitGroup;
@property(nonatomic) NSInteger timeOut;

@end

@interface ATFBBiddingManager : NSObject

- (void)bidRequest:(ATFacebookBaseRequest *)request;

+ (instancetype)sharedManager;

/**
 ID: an ad's source id or unit id.
 */
- (void)notifyDisplayWinnerWithID:(NSString *)ID placementID:(NSString *)pID;

@end

// MARK:- protocols

@protocol ATFBBKConfiguration <NSObject>

@property(nonatomic) NSTimeInterval auctionTimeout;
@property (nonatomic, assign, getter = isVerboseLoggingEnabled) BOOL verboseLoggingEnabled;

@end

@protocol ATFBBKBid <NSObject>

/**
 * This method will return an unique name for this bidder.
 */
@property (nonatomic, readonly, copy) NSString *bidderName;
/**
 * This method will return an unique identifier for the place where this ad will be shown
 * It's different for different bidders.
 * Each ad network has a way of identifying an ad placement
 */
@property (nonatomic, readonly, nullable, copy) NSString *placementId;
/**
 * This method will return a bid payload, that can be used to show an ad.
 */
@property (nonatomic, readonly, copy) NSString *payload;
/**
 * Returns the price in cents offered by the current bidder.
 */
@property (nonatomic, readonly) double price;
/**
 * This method will return the currency for the current bid.
 * For most cases it should be "USD", unless specified otherwise by an ad network.
 */
@property (nonatomic, readonly, nullable, copy) NSString *currency;

@end

@protocol ATFBBKBiddingKit <NSObject>

+ (void)initializeWithConfiguration:(id<ATFBBKConfiguration>)config;

@end

@protocol ATFBBKFacebookBidderParameters <NSObject>

- (instancetype)initWithAppId:(NSString *)appId
                  placementId:(NSString *)placementId
                  adBidFormat:(ATFBBKFacebookAdBidFormat)adBidFormat
                     bidToken:(NSString *)bidToken;
@property (nonatomic, assign) BOOL standalone;
@property (nonatomic, assign) BOOL testMode;

@end

@protocol ATFBBKFacebookBidder <NSObject, ATFBBKBid>

- (instancetype)initWithParameters:(id<ATFBBKFacebookBidderParameters>)parameters;

@end

@protocol FBBKWaterfall,FBBKAuctionDelegate,FBBKWaterfallEntry;

@protocol FBBKAuction <NSObject>

@property (nonatomic, readonly) NSInteger auctionId;
@property(nonatomic, weak) id<FBBKAuctionDelegate> delegate;
- (instancetype)initWithBidders:(NSArray<id<ATFBBKFacebookBidder>> *)bidders;
- (void)startRemoteUsingWaterfall:(id<FBBKWaterfall>)waterfall url:(NSURL *)url;
- (void)notifyDisplayWinner:(id<FBBKWaterfallEntry>)winnerEntry;

@end

@protocol FBBKWaterfallEntry <NSObject>

@property (nonatomic, readonly, nullable) id<ATFBBKFacebookBidder> bid;

@property (nonatomic, readonly) double CPMCents;

@property (nonatomic, readonly) NSString *entryName;

@end

@protocol FBBKWaterfall <NSObject>

@property (nonatomic, readonly) NSArray<id<FBBKWaterfallEntry>> *entries;

@end

@protocol FBBKAuctionDelegate <NSObject>
@optional
/**
 * This method will be called when the auction is completed.
 *
 * @param auction Auction which notified about completion
 * @param waterfall The waterfall with the updated bidders.
 */
- (void)fbbkAuction:(id<FBBKAuction>)auction didCompleteWithWaterfall:(id<FBBKWaterfall>)waterfall;

/**
* This method will be called when there was an error during remote auction.
*
* @param auction Auction which notified about completion
* @param error The error object containing the error occured.
*/
- (void)fbbkAuction:(id<FBBKAuction>)auction didFailWithError:(NSError *)error;
@end
NS_ASSUME_NONNULL_END
