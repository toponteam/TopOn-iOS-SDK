//
//  NADFullBoard.h
//  NendAd
//
//  Copyright © 2016年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NADFullBoardView.h"

@class NADFullBoard;

@protocol NADFullBoardDelegate <NADFullBoardViewDelegate>

@optional

- (void)NADFullBoardDidShowAd:(NADFullBoard *)ad;
- (void)NADFullBoardDidDismissAd:(NADFullBoard *)ad;

@end

@interface NADFullBoard : NSObject

@property (nonatomic, weak) id<NADFullBoardDelegate> delegate;
@property (nonatomic, copy) UIColor *backgroundColor;

- (void)showFromViewController:(UIViewController *)viewController;
- (UIViewController<NADFullBoardView> *)fullBoardAdViewController;

@end
