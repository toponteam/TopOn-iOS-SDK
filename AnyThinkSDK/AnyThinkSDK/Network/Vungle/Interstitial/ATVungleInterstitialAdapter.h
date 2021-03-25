//
//  ATVungleInterstitialAdapter.h
//  AnyThinkVungleInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kVungleInterstitialLoadNotification;
extern NSString *const kVungleInterstitialShowNotification;
extern NSString *const kVungleInterstitialClickNotification;
extern NSString *const kVungleInterstitialCloseNotification;
extern NSString *const kVungleInterstitialNotificationUserInfoPlacementIDKey;
@interface ATVungleInterstitialAdapter : NSObject
@end

NS_ASSUME_NONNULL_END
