//
//  WindRewardVideoAdAdapter.h
//  WindSDK
//
//  Created by happyelements on 2018/4/9.
//  Copyright © 2018 Codi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WADStrategy;



@protocol WindRewardVideoAdConnector;

// Your adapter must conform to this protocol to provide reward based video ads.
@protocol WindRewardVideoAdAdapter<NSObject>

@required

- (instancetype)initWithWADRewardVideoAdConnector:(id<WindRewardVideoAdConnector>)connector;

- (void)setup:(NSDictionary *)options;


- (BOOL)isReadyWithStrategy:(WADStrategy *)strategy;

- (void)loadAd:(NSString *)placementId strategy:(WADStrategy *)strategy;

- (NSString *)sdkVersion;

- (void)presentRewardVideoAdWithViewController:(UIViewController *)controller
                                   placementId:(NSString *)placementId
                                      strategy:(WADStrategy *)strategy
                                        options:(NSDictionary *)options
                                         error:(NSError * __autoreleasing *)error;
@end




