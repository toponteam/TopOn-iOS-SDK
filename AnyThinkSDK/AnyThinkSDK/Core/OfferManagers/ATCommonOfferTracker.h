//
//  ATBaseTrackingKit.h
//  AnyThinkSDK
//
//  Created by stephen on 28/10/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//
#import "ATLogger.h"
#import <SafariServices/SFSafariViewController.h>
#import "ATOfferWebViewController.h"
#import "NSObject+KAKit.h"
#import <StoreKit/StoreKit.h>
#import "ATOfferModel.h"
#import "ATOfferSetting.h"

NS_ASSUME_NONNULL_BEGIN
@interface ATCommonOfferTracker : NSObject

+(instancetype) sharedTracker;

-(void) openWithDeepLinkUrl:(NSString*_Nullable)deepLinkUrl completionHandler:(void (^ __nullable)(BOOL success))completion;
-(void) openUrlWithInnerSafari:(NSString *_Nullable)urlStr parentCtrl:(UIViewController *_Nullable)pc;

-(void) openUrlInWebview:(NSString *_Nullable)urlStr storeUrlStr:(NSString *_Nullable)storeStr parentCtrl:(UIViewController *_Nullable)pc;
-(void) openUrlInWebview:(NSString *_Nullable)urlStr storeUrlStr:(NSString *_Nullable)storeStr parentCtrl:(UIViewController *_Nullable)pc openInSafariWhenFailed:(BOOL)open;

-(void) openUrlInSafari:(NSString *_Nullable)urlStr requestId:(NSString *_Nullable)requestId;
-(NSString *_Nonnull) urlString:(NSString *_Nonnull)urlStr appending:(NSString *_Nullable)requestId;
-(void) sendNoticeWithUrls:(NSArray *)urls completion:(void(^)(NSURL *finalURL, NSError *error))completion;
-(void) sendTKEventWithAddress:(NSString*)address parameters:(NSDictionary*)parameters retry:(BOOL)retry completionHandler:(void (^ __nullable)(BOOL retry))completion;
- (void)clickOfferWithOfferModel:(ATOfferModel *)offerModel setting:(ATOfferSetting *)setting circleID:(NSString *)circleId delegate:(id<SKStoreProductViewControllerDelegate>)delegate viewController:(UIViewController *)viewController extra:(NSDictionary*) extra clickCallbackHandler:(void (^ __nullable)(ATClickType clickType, BOOL isEnd, BOOL success)) clickCallback ;
- (void)showHud:(BOOL)sync;
- (void)hideHud:(BOOL)sync;

- (void)preloadStorekitForOfferModel:(ATOfferModel *)model setting:(ATOfferSetting *)setting  viewController:(UIViewController *)viewController circleId:(NSString *)cid skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate;

- (void)presentStorekitViewControllerWithCircleId:(NSString *)cid offerModel:(ATOfferModel *)offerModel pkgName:(NSString *)pkgName placementID:(NSString *)placementID offerID:(NSString *)offerID  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
