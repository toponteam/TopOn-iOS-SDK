//
//  WindSplashAdAdapter.h
//  WindSDK
//
//  Created by happyelements on 2018/8/1.
//  Copyright © 2018 Codi. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol WindSplashAdConnector;

@protocol WindSplashAdAdapter<NSObject>

- (instancetype)initWithWADSplashAdConnector:(id<WindSplashAdConnector>)connector;

- (void)setup;

- (void)loadAdAndShow;

-(void)loadAdAndShowWithBottomView:(UIView *)bottomView;

@end
