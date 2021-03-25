//
//  ATStoreProductViewController.h
//  AnyThinkMyOffer
//
//  Created by stephen on 8/6/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//


#import <Foundation/Foundation.h>
#import<StoreKit/StoreKit.h>
#import "ATOfferModel.h"

@interface ATStoreProductViewController : UIViewController<SKStoreProductViewControllerDelegate>

+ (BOOL)useSystemStorekit;

@property (nonatomic, strong, readwrite) SKStoreProductViewController *storekit;

@property (nonatomic, assign, readwrite) BOOL loadSuccessed;

@property (nonatomic, assign) BOOL presented;


@property (nonatomic, assign) BOOL realtimeLoad;

@property(nonatomic, readwrite, weak) id<SKStoreProductViewControllerDelegate> skDelegate;

@property (nonatomic, weak) UIViewController *parentVC;


+ (instancetype)storekitWithPackageName:(NSString *)packageName skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate;
+ (void)at_presentStorekit:(ATStoreProductViewController *)presentedVC presenting:(UIViewController *)presentingVC;
+ (void)at_dismissStorekit:(ATStoreProductViewController *)presentedVC;

- (void)atLoadProductWithOfferModel:(ATOfferModel *)offerModel packageName:(NSString *)packageName placementID:(NSString *)placementID offerID:(NSString *)offerID pkgName:(NSString *)pkgName finished:(void (^)(BOOL result, NSError *error, NSTimeInterval loadTime))finished;

@end
