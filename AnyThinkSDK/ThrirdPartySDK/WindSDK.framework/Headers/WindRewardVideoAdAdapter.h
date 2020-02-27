//
//  WindRewardVideoAdAdapter.h
//  WindSDK
//
//  Created by happyelements on 2018/4/9.
//  Copyright © 2018 Codi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WindRewardVideoAdConnector;

// Your adapter must conform to this protocol to provide reward based video ads.
@protocol WindRewardVideoAdAdapter<NSObject>

@required

- (instancetype)initWithWADRewardVideoAdConnector:(id<WindRewardVideoAdConnector>)connector;

- (void)setup:(NSDictionary *)options;

- (BOOL)isReady:(NSString *)placementId;

- (void)loadAd:(NSString *)placementId;

- (void)presentRewardVideoAdWithViewController:(UIViewController *)controller placementId:(NSString *)placementId error:(NSError * __autoreleasing *)error;


@end




