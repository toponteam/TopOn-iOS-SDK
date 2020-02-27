//
//  ATTapjoyRewardedVideoAdapter.h
//  AnyThinkTapjoyRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const kTapjoyRVCustomEventKey;
@interface ATTapjoyRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATTapjoy<NSObject>
+ (NSString*)getVersion;
+ (BOOL)isConnected;
+ (void)connect:(NSString *)sdkKey;
+ (void)setUserConsent:(NSString*) value;
+ (void)subjectToGDPR:(BOOL) gdprApplicability;
+ (void)setUserID:(NSString*)theUserID;
@end

typedef enum ATTJCActionRequestTypeEnum {
    ATTJActionRequestInAppPurchase = 1,
    ATTJActionRequestVirtualGood,
    ATTJActionRequestCurrency,
    ATTJActionRequestNavigation
} ATTJCActionRequestType;
@protocol ATTJActionRequest<NSObject>
@property (nonatomic,assign) ATTJCActionRequestType type;
- (void)completed;
- (void)cancelled;
@property (nonatomic, copy) id callback;
@property (nonatomic, copy) NSString* requestId;
@property (nonatomic, copy) NSString* token;
@end

@protocol ATTJPlacement;
@protocol ATTJPlacementDelegate <NSObject>
@optional
- (void)requestDidSucceed:(id<ATTJPlacement>)placement;
- (void)requestDidFail:(id<ATTJPlacement>)placement error:(NSError*)error;
- (void)contentIsReady:(id<ATTJPlacement>)placement;
- (void)contentDidAppear:(id<ATTJPlacement>)placement;
- (void)contentDidDisappear:(id<ATTJPlacement>)placement;
- (void)placement:(id<ATTJPlacement>)placement didRequestPurchase:(id<ATTJActionRequest>)request productId:(NSString*)productId;
- (void)placement:(id<ATTJPlacement>)placement didRequestReward:(id<ATTJActionRequest>)request itemId:(NSString*)itemId quantity:(int)quantity;
@end

@protocol ATTJPlacementVideoDelegate <NSObject>
@optional
- (void)videoDidStart:(id<ATTJPlacement>)placement;
- (void)videoDidComplete:(id<ATTJPlacement>)placement;
- (void)videoDidFail:(id<ATTJPlacement>)placement error:(NSString*)errorMsg;
@end

@protocol ATTJPlacement<NSObject>
@property (nonatomic, weak) id<ATTJPlacementDelegate> delegate;
@property (nonatomic, weak) id<ATTJPlacementDelegate> videoDelegate;
@property (nonatomic, copy) NSString *placementName;
@property (nonatomic, assign, readonly, getter=isContentReady) BOOL contentReady;
@property (nonatomic, assign, readonly, getter=isContentAvailable) BOOL contentAvailable;
@property (nonatomic, retain) UIViewController* presentationViewController;
+ (id)placementWithName:(NSString*)placementName delegate:(id<ATTJPlacementDelegate>)delegate;
- (void)requestContent;
- (void)showContentWithViewController:(UIViewController*)viewController;
+ (void)dismissContent;
@property (nonatomic, copy) NSString *mediationAgent;
@property (nonatomic, copy) NSString *mediationId;
+ (id)placementWithName:(NSString*)placementName mediationAgent:(NSString*)mediationAgent mediationId:(NSString*)mediationId delegate:(id<ATTJPlacementDelegate>)delegate;
@property (nonatomic, copy) NSString *adapterVersion;
@property (nonatomic, copy) NSDictionary *auctionData;
@end
