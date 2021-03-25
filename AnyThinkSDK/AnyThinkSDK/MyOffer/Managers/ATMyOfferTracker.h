//
//  ATMyOfferTracker.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/30.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<StoreKit/StoreKit.h>

#import "ATMyOfferOfferManager.h"
typedef NS_ENUM(NSInteger, ATMyOfferTrackerEvent) {
    ATMyOfferTrackerEventVideoStart = 0,
    ATMyOfferTrackerEventVideo25Percent = 1,
    ATMyOfferTrackerEventVideo50Percent = 2,
    ATMyOfferTrackerEventVideo75Percent = 3,
    ATMyOfferTrackerEventVideoEnd = 4,
    ATMyOfferTrackerEventImpression = 5,
    ATMyOfferTrackerEventClick = 6,
    ATMyOfferTrackerEventEndCardShow = 7,
    ATMyOfferTrackerEventEndCardClose = 8
};

@interface ATMyOfferTracker : NSObject
+(instancetype) sharedTracker;
-(void) trackEvent:(ATMyOfferTrackerEvent)event offerModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra;
-(void) impressionOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra;
//-(void) clickOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting *)setting extra:(NSDictionary*)extra;
-(void) clickOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting *)setting extra:(NSDictionary*)extra skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *) viewController circleId:(NSString *) circleId;
-(void)preloadStorekitForOfferModel:(ATMyOfferOfferModel *)offerModel setting:(ATMyOfferSetting *) setting  viewController:(UIViewController *)viewController circleId:(NSString *) circleId skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate;
@end
