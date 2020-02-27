//
//  KSInterstitialAd.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/9/16.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSInterstitialAd : NSObject

/**
 Load interstitial ad datas.
 */
- (void)loadAdData;
/**
 Display interstitial ad.
 @param rootViewController : root view controller for displaying ad.
 @return : whether it is successfully displayed.
 */
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;


@end

NS_ASSUME_NONNULL_END
