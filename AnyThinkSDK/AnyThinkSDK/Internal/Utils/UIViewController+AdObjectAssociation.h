//
//  UIViewController+AdObjectAssociation.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//Use to keep the ad object around while it's being shown(in case clearCache's called on ATAdManager's shared instance or load ad's called for the same placement).
@interface UIViewController (AdObjectAssociation)
@property(nonatomic) id ad;
@end

NS_ASSUME_NONNULL_END
